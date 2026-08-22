// lib/features/client/providers/mood_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry_model.dart';

enum MoodStatus { idle, loading, saving, success, error }

class MoodProvider extends ChangeNotifier {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  List<MoodEntry> _entries  = [];
  MoodStatus      _status   = MoodStatus.idle;
  String?         _errorMsg;

  List<MoodEntry> get entries   => _entries;
  MoodStatus      get status    => _status;
  String?         get errorMsg  => _errorMsg;
  bool get isLoading  => _status == MoodStatus.loading;
  bool get isSaving   => _status == MoodStatus.saving;

  // Convenience: today's entry if it exists
  MoodEntry? get todayEntry {
    final today = DateTime.now().toLocal();
    try {
      return _entries.firstWhere((e) {
        final d = e.createdAt.toLocal();
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      });
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('mood_entries');

  String? get _uid => _auth.currentUser?.uid;

  // ── Fetch recent entries (last 30) ───────────────────────────────────────
  Future<void> fetchEntries() async {
    final uid = _uid;
    if (uid == null) return;

    _status   = MoodStatus.loading;
    _errorMsg = null;
    notifyListeners();

    try {
      final snap = await _col
          .where('clientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      _entries = snap.docs
          .map((d) => MoodEntry.fromMap(d.id, d.data()))
          .toList();
      _status = MoodStatus.success;
    } catch (e) {
      debugPrint('❌ MoodProvider.fetchEntries: $e');
      _errorMsg = 'Failed to load mood entries.';
      _status   = MoodStatus.error;
    }
    notifyListeners();
  }

  // ── Save or update today's entry ─────────────────────────────────────────
  /// If the client already logged a mood today, this updates it.
  /// Otherwise it creates a new document.
  Future<bool> saveTodayEntry({
    required int    moodValue,
    required String moodLabel,
    required String moodEmoji,
    required String note,
  }) async {
    final uid = _uid;
    if (uid == null) return false;

    _status   = MoodStatus.saving;
    _errorMsg = null;
    notifyListeners();

    try {
      final now      = DateTime.now().toUtc();
      final existing = todayEntry;

      if (existing != null) {
        // ── Update ──────────────────────────────────────────────────────
        final updated = existing.copyWith(
          moodValue: moodValue,
          moodLabel: moodLabel,
          moodEmoji: moodEmoji,
          note:      note,
          updatedAt: now,
        );
        await _col.doc(existing.id).update({
          'moodValue': moodValue,
          'moodLabel': moodLabel,
          'moodEmoji': moodEmoji,
          'note':      note,
          'updatedAt': Timestamp.fromDate(now),
        });
        final idx = _entries.indexWhere((e) => e.id == existing.id);
        if (idx != -1) _entries[idx] = updated;
      } else {
        // ── Create ──────────────────────────────────────────────────────
        final entry = MoodEntry(
          id:        '',
          clientId:  uid,
          moodValue: moodValue,
          moodLabel: moodLabel,
          moodEmoji: moodEmoji,
          note:      note,
          createdAt: now,
          updatedAt: now,
        );
        final ref = await _col.add(entry.toMap());
        _entries.insert(0, MoodEntry.fromMap(ref.id, entry.toMap()));
      }

      _status = MoodStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ MoodProvider.saveTodayEntry: $e');
      _errorMsg = 'Failed to save mood entry.';
      _status   = MoodStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Delete an entry ───────────────────────────────────────────────────────
  Future<void> deleteEntry(String entryId) async {
    try {
      await _col.doc(entryId).delete();
      _entries.removeWhere((e) => e.id == entryId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ MoodProvider.deleteEntry: $e');
    }
  }

  void clearError() {
    _errorMsg = null;
    if (_status == MoodStatus.error) _status = MoodStatus.idle;
    notifyListeners();
  }
}