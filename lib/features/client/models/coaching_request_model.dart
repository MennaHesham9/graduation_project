import 'package:cloud_firestore/cloud_firestore.dart';

class CoachingRequestModel {
  final String id;
  final String clientId;
  final String clientName;
  final String coachId;
  final String coachName;        // ✅ ADD THIS
  final String primaryGoal;
  final String currentChallenges;
  final String frequency;
  final String preferredTime;
  final String? additionalNotes;
  final String status;
  final DateTime createdAt;

  CoachingRequestModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.coachId,
    required this.coachName,     // ✅ ADD THIS
    required this.primaryGoal,
    required this.currentChallenges,
    required this.frequency,
    required this.preferredTime,
    this.additionalNotes,
    this.status = 'pending',
    required this.createdAt,
  });

  factory CoachingRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return CoachingRequestModel(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      coachId: map['coachId'] ?? '',
      coachName: map['coachName'] ?? '',   // ✅ ADD THIS
      primaryGoal: map['primaryGoal'] ?? '',
      currentChallenges: map['currentChallenges'] ?? '',
      frequency: map['frequency'] ?? '',
      preferredTime: map['preferredTime'] ?? '',
      additionalNotes: map['additionalNotes'],
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'clientName': clientName,
    'coachId': coachId,
    'coachName': coachName,      // ✅ ADD THIS
    'primaryGoal': primaryGoal,
    'currentChallenges': currentChallenges,
    'frequency': frequency,
    'preferredTime': preferredTime,
    'additionalNotes': additionalNotes ?? '',
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  CoachingRequestModel copyWith({String? status}) {
    return CoachingRequestModel(
      id: id,
      clientId: clientId,
      clientName: clientName,
      coachId: coachId,
      coachName: coachName,      // ✅ ADD THIS
      primaryGoal: primaryGoal,
      currentChallenges: currentChallenges,
      frequency: frequency,
      preferredTime: preferredTime,
      additionalNotes: additionalNotes,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}