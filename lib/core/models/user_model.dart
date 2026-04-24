// lib/core/models/user_model.dart

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  // Client fields
  final String? country;
  final String? primaryGoal;

  // Coach fields
  final String? coachingCategory;       // signup category (kept for compat)
  final String? yearsOfExperience;
  final String? professionalTitle;
  final String? bio;
  final String? photoUrl;
  final String? timezone;
  final String? coachCountry;
  final List<String>? coachingCategories;  // multi-select from edit screen
  final List<String>? languages;
  final bool? isAvailable;

  // Session & Pricing
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
    this.country,
    this.primaryGoal,
    this.coachingCategory,
    this.yearsOfExperience,
    this.professionalTitle,
    this.bio,
    this.photoUrl,
    this.timezone,
    this.coachCountry,
    this.coachingCategories,
    this.languages,
    this.isAvailable,
    this.sessionDuration,
    this.currency,
    this.videoPrice,
    this.audioPrice,
    this.packagePrice,
  });

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'role': role,
    if (country != null) 'country': country,
    if (primaryGoal != null) 'primaryGoal': primaryGoal,
    if (coachingCategory != null) 'coachingCategory': coachingCategory,
    if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
    if (professionalTitle != null) 'professionalTitle': professionalTitle,
    if (bio != null) 'bio': bio,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (timezone != null) 'timezone': timezone,
    if (coachCountry != null) 'coachCountry': coachCountry,
    if (coachingCategories != null) 'coachingCategories': coachingCategories,
    if (languages != null) 'languages': languages,
    if (isAvailable != null) 'isAvailable': isAvailable,
    if (sessionDuration != null) 'sessionDuration': sessionDuration,
    if (currency != null) 'currency': currency,
    if (videoPrice != null) 'videoPrice': videoPrice,
    if (audioPrice != null) 'audioPrice': audioPrice,
    if (packagePrice != null) 'packagePrice': packagePrice,
  };

  factory UserModel.fromMap(String uid, Map<String, dynamic> m) => UserModel(
    uid: uid,
    fullName: m['fullName'] ?? '',
    email: m['email'] ?? '',
    phone: m['phone'] ?? '',
    role: m['role'] ?? '',
    country: m['country'],
    primaryGoal: m['primaryGoal'],
    coachingCategory: m['coachingCategory'],
    yearsOfExperience: m['yearsOfExperience'],
    professionalTitle: m['professionalTitle'],
    bio: m['bio'],
    photoUrl: m['photoUrl'],
    timezone: m['timezone'],
    coachCountry: m['coachCountry'],
    coachingCategories: (m['coachingCategories'] as List?)?.cast<String>(),
    languages: (m['languages'] as List?)?.cast<String>(),
    isAvailable: m['isAvailable'],
    sessionDuration: m['sessionDuration'],
    currency: m['currency'],
    videoPrice: (m['videoPrice'] as num?)?.toDouble(),
    audioPrice: (m['audioPrice'] as num?)?.toDouble(),
    packagePrice: (m['packagePrice'] as num?)?.toDouble(),
  );

  // copyWith — used in AuthProvider after saving
  UserModel copyWith({
    String? fullName,
    String? phone,
    String? professionalTitle,
    String? bio,
    String? photoUrl,
    String? timezone,
    String? coachCountry,
    List<String>? coachingCategories,
    List<String>? languages,
    String? yearsOfExperience,
    bool? isAvailable,
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
        country: country,
        primaryGoal: primaryGoal,
        coachingCategory: coachingCategory,
        yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
        professionalTitle: professionalTitle ?? this.professionalTitle,
        bio: bio ?? this.bio,
        photoUrl: photoUrl ?? this.photoUrl,
        timezone: timezone ?? this.timezone,
        coachCountry: coachCountry ?? this.coachCountry,
        coachingCategories: coachingCategories ?? this.coachingCategories,
        languages: languages ?? this.languages,
        isAvailable: isAvailable ?? this.isAvailable,
        sessionDuration: sessionDuration ?? this.sessionDuration,
        currency: currency ?? this.currency,
        videoPrice: videoPrice ?? this.videoPrice,
        audioPrice: audioPrice ?? this.audioPrice,
        packagePrice: packagePrice ?? this.packagePrice,
      );
}