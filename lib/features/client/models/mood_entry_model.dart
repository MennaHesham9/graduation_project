// lib/features/client/models/mood_entry_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final String clientId;
  final int moodValue;      // 0–4
  final String moodLabel;   // 'Very Sad' … 'Great'
  final String moodEmoji;   // '😢' … '😊'
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodEntry({
    required this.id,
    required this.clientId,
    required this.moodValue,
    required this.moodLabel,
    required this.moodEmoji,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Firestore serialisation ──────────────────────────────────────────────

  factory MoodEntry.fromMap(String id, Map<String, dynamic> m) => MoodEntry(
    id:         id,
    clientId:   m['clientId']  as String,
    moodValue:  m['moodValue'] as int,
    moodLabel:  m['moodLabel'] as String,
    moodEmoji:  m['moodEmoji'] as String,
    note:       m['note']      as String? ?? '',
    createdAt:  (m['createdAt'] as Timestamp).toDate(),
    updatedAt:  (m['updatedAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'clientId':  clientId,
    'moodValue': moodValue,
    'moodLabel': moodLabel,
    'moodEmoji': moodEmoji,
    'note':      note,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  MoodEntry copyWith({
    int?      moodValue,
    String?   moodLabel,
    String?   moodEmoji,
    String?   note,
    DateTime? updatedAt,
  }) =>
      MoodEntry(
        id:        id,
        clientId:  clientId,
        moodValue: moodValue  ?? this.moodValue,
        moodLabel: moodLabel  ?? this.moodLabel,
        moodEmoji: moodEmoji  ?? this.moodEmoji,
        note:      note       ?? this.note,
        createdAt: createdAt,
        updatedAt: updatedAt  ?? this.updatedAt,
      );

  /// Formatted display date, e.g. "Jun 3" or "Jun 3, 2024"
  String get displayDate {
    final now = DateTime.now();
    final d   = createdAt.toLocal();
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    final base = '${months[d.month - 1]} ${d.day}';
    return d.year == now.year ? base : '$base, ${d.year}';
  }
}