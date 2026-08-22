class Session {
  final String doctorName;
  final String time;
  final String? sessionId;
  final DateTime? scheduledAt;
  final String? sessionType; // 'video' or 'audio'

  const Session({
    required this.doctorName,
    required this.time,
    this.sessionId,
    this.scheduledAt,
    this.sessionType,
  });
}