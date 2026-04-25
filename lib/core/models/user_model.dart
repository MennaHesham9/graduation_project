// lib/core/models/user_model.dart

class UserModel {
  // ── Core ──────────────────────────────────────────────────────────────────
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'client' | 'coach'

  // ── Shared optional fields ────────────────────────────────────────────────
  final String? country;
  final String? photoUrl;
  final String? language;   // single preferred language (user preference)
  final String? timezone;
  final String? dateOfBirth;
  final DateTime? createdAt;

  // ── Client-only fields ────────────────────────────────────────────────────
  final String? primaryGoal;

  // ── Privacy toggles (client) ──────────────────────────────────────────────
  final bool showPhotoToCoach;
  final bool allowMoodTracking;
  final bool allowSessionAnalysis;

  // ── Coach-only fields ─────────────────────────────────────────────────────
  final String? coachingCategory;       // signup category (kept for compat)
  final List<String>? coachingCategories; // multi-select from edit screen
  final String? yearsOfExperience;
  final String? professionalTitle;
  final String? bio;
  final String? coachCountry;
  final List<String>? languages;        // languages a coach speaks (list)
  final bool? isAvailable;

  // ── Session & Pricing (coach) ─────────────────────────────────────────────
  final int? sessionDuration;
  final String? currency;
  final double? videoPrice;
  final double? audioPrice;
  final double? packagePrice;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    // Shared
    this.country,
    this.photoUrl,
    this.language,
    this.timezone,
    this.dateOfBirth,
    this.createdAt,
    // Client
    this.primaryGoal,
    this.showPhotoToCoach = true,
    this.allowMoodTracking = true,
    this.allowSessionAnalysis = false,
    // Coach
    this.coachingCategory,
    this.coachingCategories,
    this.yearsOfExperience,
    this.professionalTitle,
    this.bio,
    this.coachCountry,
    this.languages,
    this.isAvailable,
    // Session & Pricing
    this.sessionDuration,
    this.currency,
    this.videoPrice,
    this.audioPrice,
    this.packagePrice,
  });

  // ── Firestore → UserModel ─────────────────────────────────────────────────
  factory UserModel.fromMap(String uid, Map<String, dynamic> m) => UserModel(
    uid: uid,
    fullName: m['fullName'] as String? ?? '',
    email: m['email'] as String? ?? '',
    phone: m['phone'] as String? ?? '',
    role: m['role'] as String? ?? 'client',
    // Shared
    country: m['country'] as String?,
    photoUrl: m['photoUrl'] as String?,
    language: m['language'] as String?,
    timezone: m['timezone'] as String?,
    dateOfBirth: m['dateOfBirth'] as String?,
    createdAt: m['createdAt'] != null
        ? DateTime.tryParse(m['createdAt'] as String)
        : null,
    // Client
    primaryGoal: m['primaryGoal'] as String?,
    showPhotoToCoach: m['showPhotoToCoach'] as bool? ?? true,
    allowMoodTracking: m['allowMoodTracking'] as bool? ?? true,
    allowSessionAnalysis: m['allowSessionAnalysis'] as bool? ?? false,
    // Coach
    coachingCategory: m['coachingCategory'] as String?,
    coachingCategories:
    (m['coachingCategories'] as List?)?.cast<String>(),
    yearsOfExperience: m['yearsOfExperience'] as String?,
    professionalTitle: m['professionalTitle'] as String?,
    bio: m['bio'] as String?,
    coachCountry: m['coachCountry'] as String?,
    languages: (m['languages'] as List?)?.cast<String>(),
    isAvailable: m['isAvailable'] as bool?,
    // Session & Pricing
    sessionDuration: m['sessionDuration'] as int?,
    currency: m['currency'] as String?,
    videoPrice: (m['videoPrice'] as num?)?.toDouble(),
    audioPrice: (m['audioPrice'] as num?)?.toDouble(),
    packagePrice: (m['packagePrice'] as num?)?.toDouble(),
  );

  // ── UserModel → Firestore ─────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'role': role,
    // Shared
    if (country != null) 'country': country,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (language != null) 'language': language,
    if (timezone != null) 'timezone': timezone,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    // Client
    if (primaryGoal != null) 'primaryGoal': primaryGoal,
    'showPhotoToCoach': showPhotoToCoach,
    'allowMoodTracking': allowMoodTracking,
    'allowSessionAnalysis': allowSessionAnalysis,
    // Coach
    if (coachingCategory != null) 'coachingCategory': coachingCategory,
    if (coachingCategories != null)
      'coachingCategories': coachingCategories,
    if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
    if (professionalTitle != null) 'professionalTitle': professionalTitle,
    if (bio != null) 'bio': bio,
    if (coachCountry != null) 'coachCountry': coachCountry,
    if (languages != null) 'languages': languages,
    if (isAvailable != null) 'isAvailable': isAvailable,
    // Session & Pricing
    if (sessionDuration != null) 'sessionDuration': sessionDuration,
    if (currency != null) 'currency': currency,
    if (videoPrice != null) 'videoPrice': videoPrice,
    if (audioPrice != null) 'audioPrice': audioPrice,
    if (packagePrice != null) 'packagePrice': packagePrice,
  };

  // ── copyWith ──────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? fullName,
    String? phone,
    // Shared
    String? country,
    String? photoUrl,
    String? language,
    String? timezone,
    String? dateOfBirth,
    // Client
    String? primaryGoal,
    bool? showPhotoToCoach,
    bool? allowMoodTracking,
    bool? allowSessionAnalysis,
    // Coach
    String? coachingCategory,
    List<String>? coachingCategories,
    String? yearsOfExperience,
    String? professionalTitle,
    String? bio,
    String? coachCountry,
    List<String>? languages,
    bool? isAvailable,
    // Session & Pricing
    int? sessionDuration,
    String? currency,
    double? videoPrice,
    double? audioPrice,
    double? packagePrice,
  }) =>
      UserModel(
        uid: uid,
        fullName: fullName ?? this.fullName,
        email: email,
        phone: phone ?? this.phone,
        role: role,
        // Shared
        country: country ?? this.country,
        photoUrl: photoUrl ?? this.photoUrl,
        language: language ?? this.language,
        timezone: timezone ?? this.timezone,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        createdAt: createdAt,
        // Client
        primaryGoal: primaryGoal ?? this.primaryGoal,
        showPhotoToCoach: showPhotoToCoach ?? this.showPhotoToCoach,
        allowMoodTracking: allowMoodTracking ?? this.allowMoodTracking,
        allowSessionAnalysis: allowSessionAnalysis ?? this.allowSessionAnalysis,
        // Coach
        coachingCategory: coachingCategory ?? this.coachingCategory,
        coachingCategories: coachingCategories ?? this.coachingCategories,
        yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
        professionalTitle: professionalTitle ?? this.professionalTitle,
        bio: bio ?? this.bio,
        coachCountry: coachCountry ?? this.coachCountry,
        languages: languages ?? this.languages,
        isAvailable: isAvailable ?? this.isAvailable,
        // Session & Pricing
        sessionDuration: sessionDuration ?? this.sessionDuration,
        currency: currency ?? this.currency,
        videoPrice: videoPrice ?? this.videoPrice,
        audioPrice: audioPrice ?? this.audioPrice,
        packagePrice: packagePrice ?? this.packagePrice,
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns "Member since MMM YYYY" or empty string if createdAt is null.
  String get memberSinceLabel {
    if (createdAt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Member since ${months[createdAt!.month - 1]} ${createdAt!.year}';
  }

  /// Returns up to two initials from fullName (e.g. "John Doe" → "JD").
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}