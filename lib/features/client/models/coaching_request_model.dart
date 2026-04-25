
class CoachingRequestModel {
final String id;
final String clientId;
final String clientName;
final String coachId;
final String primaryGoal;
final String currentChallenges;
final String frequency;
final String preferredTime;
final String? additionalNotes;
final String status; // 'pending', 'accepted', 'declined'
final DateTime createdAt;

CoachingRequestModel({
required this.id,
required this.clientId,
required this.clientName,
required this.coachId,
required this.primaryGoal,
required this.currentChallenges,
required this.frequency,
required this.preferredTime,
this.additionalNotes,
this.status = 'pending',
required this.createdAt,
});

Map<String, dynamic> toMap() => {
'id': id,
'clientId': clientId,
'clientName': clientName,
'coachId': coachId,
'primaryGoal': primaryGoal,
'currentChallenges': currentChallenges,
'frequency': frequency,
'preferredTime': preferredTime,
'additionalNotes': additionalNotes ?? '',
'status': status,
'createdAt': createdAt.toIso8601String(),
};
}