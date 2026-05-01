class Session {
  final String doctorName;
  final String time;
  final String? sessionId;

  const Session({
    required this.doctorName,
    required this.time,
    this.sessionId,
  });
}
