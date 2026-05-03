import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';

class CoachService {
  final _db = FirebaseFirestore.instance;

  /// Fetch all users where role == 'coach'
  Future<List<UserModel>> fetchCoaches() async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'coach')
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))  // ✅ pass doc.id + doc.data()
        .toList();
  }
}