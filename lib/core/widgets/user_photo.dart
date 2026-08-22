// lib/core/widgets/user_photo.dart
//
// Universal photo widget that works with:
//   • Base64 strings (stored in Firestore, free-plan compatible)
//   • Legacy http/https URLs (if you ever migrate to Storage)
//   • null / empty  →  shows initials fallback
//
// Usage examples:
//   UserPhoto(photoUrl: user.photoUrl, initials: user.initials, radius: 34)
//   UserPhoto.square(photoUrl: coach.photoUrl, initials: coach.initials, size: 90, borderRadius: 20)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserPhoto extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double radius;           // for circular shape
  final Color backgroundColor;
  final TextStyle? initialsStyle;

  const UserPhoto({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.radius = 34,
    this.backgroundColor = const Color(0xFF5BB8C9),
    this.initialsStyle,
  });

  // ── Rectangular / rounded-corner variant ──────────────────────────────────
  static Widget square({
    Key? key,
    required String? photoUrl,
    required String initials,
    required double size,
    double borderRadius = 12,
    Color backgroundColor = const Color(0xFF5BB8C9),
    TextStyle? initialsStyle,
    BoxFit fit = BoxFit.cover,
  }) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildContent(
          photoUrl: photoUrl,
          initials: initials,
          backgroundColor: backgroundColor,
          fit: fit,
          initialsStyle: initialsStyle ??
              TextStyle(
                fontSize: size * 0.35,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
          isSquare: true,
          size: size,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = (radius * 0.55).clamp(12, 40).toDouble();
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: _resolveImageProvider(photoUrl),
      child: _resolveImageProvider(photoUrl) == null
          ? Text(
              initials.isNotEmpty ? initials : '?',
              style: initialsStyle ??
                  TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            )
          : null,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static ImageProvider? _resolveImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    }
    // Base64 — strip data-URI prefix if present
    try {
      final raw = photoUrl.contains(',') ? photoUrl.split(',').last : photoUrl;
      return MemoryImage(base64Decode(raw));
    } catch (e) {
      debugPrint('UserPhoto: failed to decode base64 — $e');
      return null;
    }
  }

  static Widget _buildContent({
    required String? photoUrl,
    required String initials,
    required Color backgroundColor,
    required BoxFit fit,
    required TextStyle initialsStyle,
    required bool isSquare,
    required double size,
  }) {
    final provider = _resolveImageProvider(photoUrl);
    if (provider != null) {
      return Image(image: provider, fit: fit, width: size, height: size,
        errorBuilder: (_, __, ___) => _initialsBox(
          initials: initials,
          backgroundColor: backgroundColor,
          style: initialsStyle,
        ),
      );
    }
    return _initialsBox(
      initials: initials,
      backgroundColor: backgroundColor,
      style: initialsStyle,
    );
  }

  static Widget _initialsBox({
    required String initials,
    required Color backgroundColor,
    required TextStyle style,
  }) =>
      Container(
        color: backgroundColor,
        alignment: Alignment.center,
        child: Text(initials.isNotEmpty ? initials : '?', style: style),
      );
}