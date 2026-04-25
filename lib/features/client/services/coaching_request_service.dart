import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coaching_request_model.dart';

class CoachingRequestService {
  final _db = FirebaseFirestore.instance;

  Future<void> sendRequest(CoachingRequestModel request) async {
    // Save under coachingRequests collection
    await _db
        .collection('coachingRequests')
        .doc(request.id)
        .set(request.toMap());
  }
}