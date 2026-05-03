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
  final String? language;
  final String? timezone;
  final String? dateOfBirth;
  final DateTime? createdAt;

  // ── Client-only fields ────────────────────────────────────────────────────
  final String? primaryGoal;

  // ── Privacy toggles (client) ──────────────────────────────────────────────
  final bool showPhotoToCoach;
  final bool allowMoodTracking;
  final bool allowSessionAnalysis;

  // ── Relationship arrays ───────────────────────────────────────────────────
  /// UIDs of coaches this client is linked to (populated on request accept).
  final List<String> myCoaches;

  /// UIDs of clients this coach is linked to (populated on request accept).
  final List<String> myClients;

  // ── Coach-only fields ─────────────────────────────────────────────────────
  final String? coachingCategory;
  final List<String>? coachingCategories;
  final String? yearsOfExperience;
  final String? professionalTitle;
  final String? bio;
  final String? coachCountry;
  final List<String>? languages;
  final bool? isAvailable;

  // ── Certifications (coach) ────────────────────────────────────────────────
  // Each entry is a map with keys: name, sizeLabel, base64Data, extension, status
  final List<Map<String, dynamic>>? certifications;

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
    // Relationship arrays
    this.myCoaches = const [],
    this.myClients = const [],
    // Coach
    this.coachingCategory,
    this.coachingCategories,
    this.yearsOfExperience,
    this.professionalTitle,
    this.bio,
    this.coachCountry,
    this.languages,
    this.isAvailable,
    // Certifications
    this.certifications,
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
    // Relationship arrays — default to empty list if absent in Firestore
    myCoaches: (m['myCoaches'] as List?)?.cast<String>() ?? const [],
    myClients: (m['myClients'] as List?)?.cast<String>() ?? const [],
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
    certifications: (m['certifications'] as List?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList(),
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
    // Relationship arrays — always write so they exist on every document
    'myCoaches': myCoaches,
    'myClients': myClients,
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
    if (certifications != null) 'certifications': certifications,
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
    // Relationship arrays
    List<String>? myCoaches,
    List<String>? myClients,
    // Coach
    String? coachingCategory,
    List<String>? coachingCategories,
    String? yearsOfExperience,
    String? professionalTitle,
    String? bio,
    String? coachCountry,
    List<String>? languages,
    bool? isAvailable,
    // Certifications
    List<Map<String, dynamic>>? certifications,
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
        // Relationship arrays
        myCoaches: myCoaches ?? this.myCoaches,
        myClients: myClients ?? this.myClients,
        // Coach
        coachingCategory: coachingCategory ?? this.coachingCategory,
        coachingCategories: coachingCategories ?? this.coachingCategories,
        yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
        professionalTitle: professionalTitle ?? this.professionalTitle,
        bio: bio ?? this.bio,
        coachCountry: coachCountry ?? this.coachCountry,
        languages: languages ?? this.languages,
        isAvailable: isAvailable ?? this.isAvailable,
        // Certifications
        certifications: certifications ?? this.certifications,
        // Session & Pricing
        sessionDuration: sessionDuration ?? this.sessionDuration,
        currency: currency ?? this.currency,
        videoPrice: videoPrice ?? this.videoPrice,
        audioPrice: audioPrice ?? this.audioPrice,
        packagePrice: packagePrice ?? this.packagePrice,
      );

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get memberSinceLabel {
    if (createdAt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Member since ${months[createdAt!.month - 1]} ${createdAt!.year}';
  }
  String get initials {
    final parts = fullName.trim().split(' ')
        .where((p) => p.isNotEmpty)   // ✅ drop empty segments
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // // In UserModel — ADD these two helpers (no Firestore field change needed)
  // double get singleAudioPrice => audioPrice ?? 0;
  // double get singleVideoPrice => videoPrice ?? 0;
  // double get package4Price => packagePrice ?? ((audioPrice ?? 0) * 4 * 0.93); // 7% discount
  // double get package8Price => (audioPrice ?? 0) * 8 * 0.85; // 15% discount
  // bool get isAvailableForBooking => (isAvailable ?? true) && role == 'coach';
  // Add these getters anywhere inside the UserModel class:
  double get singleAudioPrice => (audioPrice ?? 0).toDouble();
  double get singleVideoPrice => (videoPrice ?? 0).toDouble();
  double get package4Price => (packagePrice ?? (singleAudioPrice * 4 * 0.93)).toDouble();
  double get package8Price => (singleAudioPrice * 8 * 0.85).toDouble();
  bool get isAvailableForBooking => (isAvailable ?? true) && role == 'coach';
}