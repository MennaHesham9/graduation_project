class Goals {
  /// 0..1 progress values
  final double communication;
  final double confidence;

  /// Real goal titles from Firestore (optional fallback to defaults)
  final String label1;
  final String label2;

  const Goals({
    required this.communication,
    required this.confidence,
    this.label1 = 'Improve Communication',
    this.label2 = 'Build Confidence',
  });
}
