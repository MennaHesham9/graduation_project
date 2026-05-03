// lib/core/providers/profile_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

enum ProfileStatus { idle, loading, saving, success, error }

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _profile;
  ProfileStatus _status = ProfileStatus.idle;
  String? _errorMessage;

  UserModel? get profile => _profile;
  ProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isSaving => _status == ProfileStatus.saving;

  // ── Fetch profile from Firestore ─────────────────────────────────────────
  Future<void> fetchProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _profile = UserModel.fromMap(uid, doc.data()!);
        _status = ProfileStatus.success;
      } else {
        _errorMessage = 'Profile not found.';
        _status = ProfileStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
      _status = ProfileStatus.error;
    }
    notifyListeners();
  }

  // ── Update profile fields in Firestore ───────────────────────────────────
  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    String? country,
    String? dateOfBirth,
    String? language,
    String? timezone,
    String? primaryGoal,
    bool? showPhotoToCoach,
    bool? allowMoodTracking,
    bool? allowSessionAnalysis,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    _status = ProfileStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      final updates = <String, dynamic>{
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        if (country != null && country.trim().isNotEmpty)
          'country': country.trim(),
        if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty)
          'dateOfBirth': dateOfBirth.trim(),
        if (language != null && language.trim().isNotEmpty)
          'language': language.trim(),
        if (timezone != null && timezone.trim().isNotEmpty)
          'timezone': timezone.trim(),
        if (primaryGoal != null && primaryGoal.trim().isNotEmpty)
          'primaryGoal': primaryGoal.trim(),
        if (showPhotoToCoach != null) 'showPhotoToCoach': showPhotoToCoach,
        if (allowMoodTracking != null) 'allowMoodTracking': allowMoodTracking,
        if (allowSessionAnalysis != null)
          'allowSessionAnalysis': allowSessionAnalysis,
      };

      await _db.collection('users').doc(uid).update(updates);

      // Update local copy immediately so UI reflects changes without refetch
      if (_profile != null) {
        _profile = _profile!.copyWith(
          fullName: fullName.trim(),
          phone: phone.trim(),
          country: country?.trim().isNotEmpty == true ? country!.trim() : _profile!.country,
          dateOfBirth: dateOfBirth?.trim().isNotEmpty == true ? dateOfBirth!.trim() : _profile!.dateOfBirth,
          language: language?.trim().isNotEmpty == true ? language!.trim() : _profile!.language,
          timezone: timezone?.trim().isNotEmpty == true ? timezone!.trim() : _profile!.timezone,
          primaryGoal: primaryGoal?.trim().isNotEmpty == true ? primaryGoal!.trim() : _profile!.primaryGoal,
          showPhotoToCoach: showPhotoToCoach ?? _profile!.showPhotoToCoach,
          allowMoodTracking: allowMoodTracking ?? _profile!.allowMoodTracking,
          allowSessionAnalysis: allowSessionAnalysis ?? _profile!.allowSessionAnalysis,
        );
      }

      _status = ProfileStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save profile.';
      _status = ProfileStatus.error;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    _status = ProfileStatus.idle;
    notifyListeners();
  }

  // ── Update profile photo (Base64 stored directly in Firestore) ────────────
  Future<bool> updateProfilePhoto(String base64Photo) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    _status = ProfileStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      await _db.collection('users').doc(uid).update({'photoUrl': base64Photo});
      if (_profile != null) {
        _profile = _profile!.copyWith(photoUrl: base64Photo);
      }
      _status = ProfileStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update photo.';
      _status = ProfileStatus.error;
      notifyListeners();
      return false;
    }
  }
}