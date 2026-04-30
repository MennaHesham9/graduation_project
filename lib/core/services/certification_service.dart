// lib/core/services/certification_service.dart
//
// Handles picking certification files (PDF, JPG, PNG) and encoding them
// as Base64 strings for storage directly in Firestore.
//
// Size limit per cert: ~700 KB raw → ~950 KB Base64.
// Firestore document limit: 1 MB. With multiple certs the total document
// can approach the limit, so we enforce a 500 KB cap per file and warn
// the user if they try to exceed it.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class CertificationService {
  static const int _maxFileSizeBytes = 500 * 1024; // 500 KB

  // ── Pick a single certification file ─────────────────────────────────────
  // Returns a [CertFile] with name, size label, and Base64 data,
  // or null if the user cancelled or the file is too large.
  Future<CertFile?> pickCertification() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true, // load bytes immediately
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return null;

      if (bytes.length > _maxFileSizeBytes) {
        return CertFile.oversized(file.name, bytes.length);
      }

      final base64Data = base64Encode(bytes);
      final sizeLabel = _sizeLabel(bytes.length);

      return CertFile(
        name: file.name,
        sizeLabel: sizeLabel,
        base64Data: base64Data,
        extension: file.extension ?? 'pdf',
      );
    } catch (e) {
      debugPrint('❌ CertificationService.pickCertification: $e');
      return null;
    }
  }

  String _sizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ── Data model for a certification file ─────────────────────────────────────
class CertFile {
  final String name;
  final String sizeLabel;
  final String? base64Data; // null if oversized
  final String extension;
  final bool isOversized;
  final String? status; // 'Pending' | 'Verified' — set by admin

  const CertFile({
    required this.name,
    required this.sizeLabel,
    this.base64Data,
    required this.extension,
    this.isOversized = false,
    this.status = 'Pending',
  });

  factory CertFile.oversized(String name, int bytes) => CertFile(
    name: name,
    sizeLabel: '${(bytes / 1024).toStringAsFixed(0)} KB',
    extension: name.split('.').last,
    isOversized: true,
    status: null,
  );

  // ── Firestore serialization ───────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'name': name,
    'sizeLabel': sizeLabel,
    'base64Data': base64Data ?? '',
    'extension': extension,
    'status': status ?? 'Pending',
  };

  factory CertFile.fromMap(Map<String, dynamic> m) => CertFile(
    name: m['name'] as String? ?? 'Certificate',
    sizeLabel: m['sizeLabel'] as String? ?? '',
    base64Data: m['base64Data'] as String?,
    extension: m['extension'] as String? ?? 'pdf',
    status: m['status'] as String? ?? 'Pending',
  );
}