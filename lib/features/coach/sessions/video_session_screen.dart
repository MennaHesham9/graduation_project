// lib/features/coach/sessions/video_session_screen.dart
// FIX: onRemoteUserConnected is now set BEFORE initAndJoin() so the callback
// is not missed if the client is already in the channel when the coach joins.

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/agora_provider.dart';
import '../../../core/providers/emotion_provider.dart';
import '../../../core/services/emotion_analyzer.dart';
import 'emotion_summary_screen.dart';

class VideoSessionScreen extends StatefulWidget {
  final String bookingId;
  final String channelName;
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
      // 1. Permissions
      await [Permission.camera, Permission.microphone].request();
      if (!mounted) return;

      // 2. Warm up ML Kit detector
      if (widget.allowSessionAnalysis) {
        final agoraService = context.read<AgoraProvider>().service;
        await context.read<EmotionProvider>().startDetection(agoraService);
        if (!mounted) return;
      }

      // 3. *** FIX: set onRemoteUserConnected BEFORE joining the channel ***
      //    The original code set this AFTER initAndJoin(), so if the client was
      //    already in the channel the onUserJoined callback fired during the
      //    join and this hook was never called → zero frames captured.
      if (widget.allowSessionAnalysis) {
        context.read<AgoraProvider>().onRemoteUserConnected = () {
          if (mounted) {
            context.read<EmotionProvider>().activateFrameCapture();
          }
        };
      }

      if (!mounted) return;

      // 4. Join channel — onRemoteUserConnected may fire here now that it's set
      await context.read<AgoraProvider>().initAndJoin(widget.channelName);
    });
  }

  Future<void> _endSession() async {
    if (widget.allowSessionAnalysis) {
      await context.read<EmotionProvider>().stopAndSave(widget.bookingId);
    }
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
                  Text('Connecting...',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
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
                    Text(agora.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white)),
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
              _RemoteVideo(agora: agora),
              if (agora.service.engine != null)
                Positioned(
                    top: 60,
                    right: 16,
                    child: _LocalPreview(agora: agora)),
              if (widget.allowSessionAnalysis)
                Positioned(
                    top: 60,
                    left: 16,
                    child: _EmotionBadge(emotion: emotion)),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _SessionControls(agora: agora, onEndCall: _endSession),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
            Text('Waiting for client to join...',
                style: TextStyle(color: Colors.white, fontSize: 16)),
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
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
      ),
    );
  }
}

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
            Text(reading.emotion.name.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(DetectedEmotion e) => switch (e) {
        DetectedEmotion.happy => Colors.green.shade600,
        DetectedEmotion.calm => const Color(0xFF2F8F9D),
        DetectedEmotion.tense => Colors.orange.shade700,
        DetectedEmotion.distracted => Colors.grey.shade600,
        DetectedEmotion.sad => Colors.blue.shade700,
        DetectedEmotion.neutral => Colors.grey.shade500,
      };

  String _emoji(DetectedEmotion e) => switch (e) {
        DetectedEmotion.happy => '😊',
        DetectedEmotion.calm => '😌',
        DetectedEmotion.tense => '😟',
        DetectedEmotion.distracted => '👀',
        DetectedEmotion.sad => '😔',
        DetectedEmotion.neutral => '😐',
      };
}

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
