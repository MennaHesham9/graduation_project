import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

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
      final user = await _service.signIn(email, password);
      if (user == null) { _setError('User not found.'); return false; }
      _setSuccess(user);
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
      _setSuccess(user);
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
      _setSuccess(user);
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e.toString()));
      return false;
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

  // ── Convert Firebase error codes to readable messages ─────────────────────
  String _friendlyError(String raw) {
    if (raw.contains('user-not-found'))      return 'No account found with this email.';
    if (raw.contains('wrong-password'))      return 'Incorrect password. Please try again.';
    if (raw.contains('email-already-in-use')) return 'An account already exists with this email.';
    if (raw.contains('weak-password'))       return 'Password must be at least 6 characters.';
    if (raw.contains('invalid-email'))       return 'Please enter a valid email address.';
    if (raw.contains('network-request-failed')) return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }
}