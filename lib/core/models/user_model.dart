// lib/core/models/user_model.dart

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'client' | 'coach'

  // Optional shared fields
  final String? country;
  final String? photoUrl;
  final String? language;
  final String? timezone;
  final String? dateOfBirth;
  final DateTime? createdAt;

  // Client-only fields
  final String? primaryGoal;

  // Coach-only fields
  final String? coachingCategory;
  final String? yearsOfExperience;

  // Privacy toggles (client)
  final bool showPhotoToCoach;
  final bool allowMoodTracking;
  final bool allowSessionAnalysis;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.country,
    this.photoUrl,
    this.language,
    this.timezone,
    this.dateOfBirth,
    this.createdAt,
    this.primaryGoal,
    this.coachingCategory,
    this.yearsOfExperience,
    this.showPhotoToCoach = true,
    this.allowMoodTracking = true,
    this.allowSessionAnalysis = false,
  });

  // ── Firestore → UserModel ─────────────────────────────────────────────────
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'client',
      country: map['country'] as String?,
      photoUrl: map['photoUrl'] as String?,
      language: map['language'] as String?,
      timezone: map['timezone'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      primaryGoal: map['primaryGoal'] as String?,
      coachingCategory: map['coachingCategory'] as String?,
      yearsOfExperience: map['yearsOfExperience'] as String?,
      showPhotoToCoach: map['showPhotoToCoach'] as bool? ?? true,
      allowMoodTracking: map['allowMoodTracking'] as bool? ?? true,
      allowSessionAnalysis: map['allowSessionAnalysis'] as bool? ?? false,
    );
  }

  // ── UserModel → Firestore ─────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      if (country != null) 'country': country,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (language != null) 'language': language,
      if (timezone != null) 'timezone': timezone,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (primaryGoal != null) 'primaryGoal': primaryGoal,
      if (coachingCategory != null) 'coachingCategory': coachingCategory,
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
      'showPhotoToCoach': showPhotoToCoach,
      'allowMoodTracking': allowMoodTracking,
      'allowSessionAnalysis': allowSessionAnalysis,
    };
  }

  // ── copyWith ──────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? fullName,
    String? phone,
    String? country,
    String? photoUrl,
    String? language,
    String? timezone,
    String? dateOfBirth,
    String? primaryGoal,
    String? coachingCategory,
    String? yearsOfExperience,
    bool? showPhotoToCoach,
    bool? allowMoodTracking,
    bool? allowSessionAnalysis,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      country: country ?? this.country,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      coachingCategory: coachingCategory ?? this.coachingCategory,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      showPhotoToCoach: showPhotoToCoach ?? this.showPhotoToCoach,
      allowMoodTracking: allowMoodTracking ?? this.allowMoodTracking,
      allowSessionAnalysis: allowSessionAnalysis ?? this.allowSessionAnalysis,
    );
  }

  // ── Helper: formatted member since ───────────────────────────────────────
  String get memberSinceLabel {
    if (createdAt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Member since ${months[createdAt!.month - 1]} ${createdAt!.year}';
  }

  // ── Helper: initials ──────────────────────────────────────────────────────
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}