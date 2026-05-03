// lib/features/client/sessions/client_video_session_screen.dart

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/agora_provider.dart';


class ClientVideoSessionScreen extends StatefulWidget {
  final String bookingId;
  final String channelName;
  final String coachName;

  const ClientVideoSessionScreen({
    super.key,
    required this.bookingId,
    required this.channelName,
    required this.coachName,
  });

  @override
  State<ClientVideoSessionScreen> createState() =>
      _ClientVideoSessionScreenState();
}

class _ClientVideoSessionScreenState
    extends State<ClientVideoSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await [Permission.camera, Permission.microphone].request();
      if (!mounted) return;
      await context.read<AgoraProvider>().initAndJoin(widget.channelName);
    });
  }

  Future<void> _leaveSession() async {
    await context.read<AgoraProvider>().endCall();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AgoraProvider>(
        builder: (context, agora, _) {
          if (agora.isLoading) {
            return const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('Connecting to your coach...',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ]),
            );
          }

          return Stack(
            children: [
              // Coach's feed — full screen
              if (agora.remoteUserConnected && agora.remoteUid != null &&
                  agora.service.engine != null)
                AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: agora.service.engine!,
                    canvas: VideoCanvas(uid: agora.remoteUid),
                    connection: const RtcConnection(channelId: ''),
                  ),
                )
              else
                Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text('Waiting for ${widget.coachName}...',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16)),
                  ]),
                ),

              // Client's own small preview — top-right
              if (agora.service.engine != null)
                Positioned(
                  top: 60, right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 100, height: 140,
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: agora.service.engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
                  ),
                ),

              // Coach name label — top-left
              Positioned(
                top: 60, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(widget.coachName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),

              // Controls — bottom
              Positioned(
                bottom: 40, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Btn(
                      icon: agora.isMicMuted ? Icons.mic_off : Icons.mic,
                      color: agora.isMicMuted ? Colors.red : Colors.white,
                      onTap: () =>
                          context.read<AgoraProvider>().toggleMic(),
                    ),
                    const SizedBox(width: 24),
                    _Btn(
                      icon: Icons.call_end,
                      color: Colors.white,
                      background: Colors.red,
                      size: 64,
                      onTap: _leaveSession,
                    ),
                    const SizedBox(width: 24),
                    _Btn(
                      icon: agora.isCameraOff
                          ? Icons.videocam_off
                          : Icons.videocam,
                      color:
                      agora.isCameraOff ? Colors.red : Colors.white,
                      onTap: () =>
                          context.read<AgoraProvider>().toggleCamera(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final double size;

  const _Btn({
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
        width: size, height: size,
        decoration: BoxDecoration(
            color: background, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}