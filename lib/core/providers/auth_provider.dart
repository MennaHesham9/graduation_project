import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isClient => _user?.role == 'client';
  bool get isCoach => _user?.role == 'coach';

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = AuthStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  void _setSuccess(UserModel user) {
    _user = user;
    _status = AuthStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    _setLoading();
    try {
      final userModel = await _service.signIn(email, password);
      await FcmService().initToken(_user!.uid);

      if (!_service.isEmailVerified()) {
        _setError('Please verify your email before signing in.');
        await _service.sendEmailVerification();
        return false;
      }

      if (userModel == null) { _setError('User not found.'); return false; }
      _setSuccess(userModel);
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    }
  }

  // ── Sign Up Client ────────────────────────────────────────────────────────
  Future<bool> signUpClient({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? country,
    String? primaryGoal,
  }) async {
    _setLoading();
    try {
      debugPrint('🔥 signUpClient called with email: $email');
      final user = await _service.signUpClient(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        country: country,
        primaryGoal: primaryGoal,
      );
      if (user == null) { _setError('Sign up failed.'); return false; }
      debugPrint('✅ signUpClient success: ${user.uid}');

      // Send verification email but don't log them in yet
      await _service.sendEmailVerification();

      // Keep status as success so the screen knows signup worked
      // but don't set _user so they can't access the app yet
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      debugPrint('❌ signUpClient error: $e');
      _setError(_friendlyError(e.toString()));
      return false;
    }
  }

  // ── Sign Up Coach ─────────────────────────────────────────────────────────
  Future<bool> signUpCoach({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? coachingCategory,
    String? yearsOfExperience,
  }) async {
    _setLoading();
    try {
      final user = await _service.signUpCoach(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        coachingCategory: coachingCategory,
        yearsOfExperience: yearsOfExperience,
      );
      if (user == null) { _setError('Sign up failed.'); return false; }

      // Send verification email but don't log them in yet
      await _service.sendEmailVerification();

      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return false;
    _setLoading();
    try {
      final updated = await _service.updateProfile(_user!.uid, data);
      if (updated == null) { _setError('Update failed.'); return false; }
      _setSuccess(updated);
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    }
  }

  // ── Refresh user from Firestore ───────────────────────────────────────────
  // Called after editing profile so all screens reflect the new data instantly
  Future<void> refreshUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(uid, doc.data()!);  // ✅ fixed
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ refreshUser error: $e');
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // ── Password Reset ────────────────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _service.sendPasswordReset(email);
      _status = AuthStatus.idle;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
    }
  }

  // ── Friendly error messages ───────────────────────────────────────────────
  String _friendlyError(String raw) {
    if (raw.contains('user-not-found'))         return 'No account found with this email.';
    if (raw.contains('wrong-password'))         return 'Incorrect password. Please try again.';
    if (raw.contains('email-already-in-use'))   return 'An account already exists with this email.';
    if (raw.contains('weak-password'))          return 'Password must be at least 6 characters.';
    if (raw.contains('invalid-email'))          return 'Please enter a valid email address.';
    if (raw.contains('network-request-failed')) return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }
}