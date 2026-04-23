import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Current Firebase user stream ──────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<UserModel?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return _fetchUserModel(cred.user!.uid);
  }

  // ── Sign Up Client ────────────────────────────────────────────────────────
  Future<UserModel?> signUpClient({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? country,
    String? primaryGoal,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = UserModel(
      uid: cred.user!.uid,
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: 'client',
      country: country,
      primaryGoal: primaryGoal,
    );
    await _db.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  // ── Sign Up Coach ─────────────────────────────────────────────────────────
  Future<UserModel?> signUpCoach({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? coachingCategory,
    String? yearsOfExperience,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = UserModel(
      uid: cred.user!.uid,
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: 'coach',
      coachingCategory: coachingCategory,
      yearsOfExperience: yearsOfExperience,
    );
    await _db.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Fetch user model from Firestore ───────────────────────────────────────
  Future<UserModel?> _fetchUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  // ── Password Reset ────────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}