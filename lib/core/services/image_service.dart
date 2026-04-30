// lib/core/services/image_service.dart
//
// Stores profile photos as Base64 strings directly in Firestore.
// This avoids Firebase Storage entirely — compatible with the free Spark plan.
//
// Firestore document limit: 1 MB per document.
// A compressed 200×200 JPEG is ~15–30 KB as Base64 — well within limits.

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // ── Pick & encode a profile picture ──────────────────────────────────────
  // Returns a Base64-encoded JPEG string, or null if the user cancelled.
  Future<String?> pickAndEncodeProfileImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return null;

      final bytes = await picked.readAsBytes();
      final compressed = await _compressImage(bytes);
      return base64Encode(compressed);
    } catch (e) {
      debugPrint('❌ ImageService.pickAndEncodeProfileImage: $e');
      return null;
    }
  }

  // ── Compress to ≤ 200 KB ──────────────────────────────────────────────────
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    // Decode
    img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    // Resize so longest side ≤ 400 px (plenty for an avatar)
    if (decoded.width > 400 || decoded.height > 400) {
      decoded = img.copyResize(
        decoded,
        width: decoded.width > decoded.height ? 400 : -1,
        height: decoded.height >= decoded.width ? 400 : -1,
      );
    }

    // Encode as JPEG with quality 75 — typically 10–30 KB
    final compressed = Uint8List.fromList(img.encodeJpg(decoded, quality: 75));
    return compressed;
  }

  // ── Build an ImageProvider from a stored Base64 string ───────────────────
  // Use this in CircleAvatar / Image widgets.
  static ImageProvider? imageFromBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    // Support both raw Base64 and data-URI prefix
    String raw = base64String;
    if (raw.contains(',')) raw = raw.split(',').last;
    try {
      return MemoryImage(base64Decode(raw));
    } catch (_) {
      return null;
    }
  }

  // ── Show source chooser (gallery / camera) ────────────────────────────────
  static Future<ImageSource?> showSourceDialog(context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}