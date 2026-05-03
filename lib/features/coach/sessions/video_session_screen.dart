// lib/features/coach/sessions/video_session_screen.dart

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/agora_provider.dart';
import '../../../core/providers/emotion_provider.dart';
import '../../../core/services/emotion_analyzer.dart';
import 'emotion_summary_screen.dart';

/// The main screen the coach sees during a live video session.
///
/// Shows:
///   • Client's video feed (full screen)
///   • Coach's own small preview (top-right)
///   • Live emotion badge (top-left) — only when [allowSessionAnalysis] is on
///   • Session controls: mute, end call, camera toggle (bottom)
///
/// [allowSessionAnalysis] must be read from the *client's* user profile (stored
/// on the booking document or fetched separately). Do NOT use
/// [AuthProvider.user] here — that returns the coach's own profile.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => VideoSessionScreen(
///     bookingId: booking.id,
///     channelName: 'session_${booking.id}',
///     allowSessionAnalysis: booking.clientAllowsAnalysis, // from booking
///   ),
/// ));
/// ```
class VideoSessionScreen extends StatefulWidget {
  final String bookingId;

  /// Must match the channel name used by the client app.
  /// Convention: `'session_${bookingId}'`
  final String channelName;

  /// Whether the *client* has opted into emotion analysis.
  /// Read from the booking document — NOT from [AuthProvider.user],
  /// which would return the coach's own setting.
  final bool allowSessionAnalysis;

  const VideoSessionScreen({
    super.key,
    required this.bookingId,
    required this.channelName,
    required this.allowSessionAnalysis,
  });

  @override
  State<VideoSessionScreen> createState() => _VideoSessionScreenState();
}

class _VideoSessionScreenState extends State<VideoSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Request camera + mic permissions before touching Agora or ML Kit
      await [Permission.camera, Permission.microphone].request();

      if (!mounted) return;

      // 2. Warm up emotion detector now (fast, no camera/Agora needed) so
      //    ML Kit is ready the instant the first remote frame arrives.
      if (widget.allowSessionAnalysis) {
        final agoraService = context.read<AgoraProvider>().service;
        await context.read<EmotionProvider>().startDetection(agoraService);
      }

      if (!mounted) return;

      // 3. Hook into AgoraProvider so frame capture starts the moment the
      //    remote client joins — not before. Registering the frame observer
      //    before the remote peer joins delivers zero frames.
      if (widget.allowSessionAnalysis) {
        context.read<AgoraProvider>().onRemoteUserConnected = () {
          context.read<EmotionProvider>().activateFrameCapture();
        };
      }

      if (!mounted) return;

      // 4. Join the Agora channel. onRemoteUserConnected fires automatically
      //    once the client joins, which triggers activateFrameCapture().
      await context.read<AgoraProvider>().initAndJoin(widget.channelName);
    });
  }

  Future<void> _endSession() async {
    // Stop detection first (saves summary) then leave the Agora channel.
    await context.read<EmotionProvider>().stopAndSave(widget.bookingId);
    await context.read<AgoraProvider>().endCall();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EmotionSummaryScreen(bookingId: widget.bookingId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<AgoraProvider, EmotionProvider>(
        builder: (context, agora, emotion, _) {
          if (agora.isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Connecting...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (agora.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      agora.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back',
                          style: TextStyle(color: Color(0xFF2F8F9D))),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              // ── Client's video feed — fills the screen ─────────────────
              _RemoteVideo(agora: agora),

              // ── Coach's own small preview — top-right ──────────────────
              if (agora.service.engine != null)
                Positioned(
                  top: 60,
                  right: 16,
                  child: _LocalPreview(agora: agora),
                ),

              // ── Live emotion badge — top-left ──────────────────────────
              // Only rendered when analysis is active (badge hides itself
              // when currentEmotion is null, so no extra guard needed).
              Positioned(
                top: 60,
                left: 16,
                child: _EmotionBadge(emotion: emotion),
              ),

              // ── Session controls — bottom ──────────────────────────────
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _SessionControls(
                  agora: agora,
                  onEndCall: _endSession,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Remote video ─────────────────────────────────────────────────────────────

class _RemoteVideo extends StatelessWidget {
  final AgoraProvider agora;
  const _RemoteVideo({required this.agora});

  @override
  Widget build(BuildContext context) {
    if (!agora.remoteUserConnected ||
        agora.remoteUid == null ||
        agora.service.engine == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Waiting for client to join...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: agora.service.engine!,
        canvas: VideoCanvas(uid: agora.remoteUid),
        connection: const RtcConnection(channelId: ''),
      ),
    );
  }
}

// ── Local preview (coach) ─────────────────────────────────────────────────────

class _LocalPreview extends StatelessWidget {
  final AgoraProvider agora;
  const _LocalPreview({required this.agora});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 100,
        height: 140,
        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: agora.service.engine!,
            canvas: const VideoCanvas(uid: 0), // 0 = local user
          ),
        ),
      ),
    );
  }
}

// ── Live emotion badge ────────────────────────────────────────────────────────

class _EmotionBadge extends StatelessWidget {
  final EmotionProvider emotion;
  const _EmotionBadge({required this.emotion});

  @override
  Widget build(BuildContext context) {
    final reading = emotion.currentEmotion;
    if (reading == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(reading.emotion),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _badgeColor(reading.emotion).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji(reading.emotion),
                style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              reading.emotion.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(DetectedEmotion e) {
    switch (e) {
      case DetectedEmotion.happy:
        return Colors.green.shade600;
      case DetectedEmotion.calm:
        return const Color(0xFF2F8F9D);
      case DetectedEmotion.tense:
        return Colors.orange.shade700;
      case DetectedEmotion.distracted:
        return Colors.grey.shade600;
      case DetectedEmotion.sad:
        return Colors.blue.shade700;
      case DetectedEmotion.neutral:
        return Colors.grey.shade500;
    }
  }

  String _emoji(DetectedEmotion e) {
    switch (e) {
      case DetectedEmotion.happy:
        return '😊';
      case DetectedEmotion.calm:
        return '😌';
      case DetectedEmotion.tense:
        return '😟';
      case DetectedEmotion.distracted:
        return '👀';
      case DetectedEmotion.sad:
        return '😔';
      case DetectedEmotion.neutral:
        return '😐';
    }
  }
}

// ── Session controls ──────────────────────────────────────────────────────────

class _SessionControls extends StatelessWidget {
  final AgoraProvider agora;
  final VoidCallback onEndCall;
  const _SessionControls({required this.agora, required this.onEndCall});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: agora.isMicMuted ? Icons.mic_off : Icons.mic,
          color: agora.isMicMuted ? Colors.red : Colors.white,
          onTap: () => context.read<AgoraProvider>().toggleMic(),
        ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: Icons.call_end,
          color: Colors.white,
          background: Colors.red,
          onTap: onEndCall,
          size: 64,
        ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: agora.isCameraOff ? Icons.videocam_off : Icons.videocam,
          color: agora.isCameraOff ? Colors.red : Colors.white,
          onTap: () => context.read<AgoraProvider>().toggleCamera(),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.background = const Color(0x66000000),
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}
