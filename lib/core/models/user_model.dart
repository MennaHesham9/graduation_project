class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'client' or 'coach'
  final String? country;
  final String? primaryGoal;
  final String? coachingCategory;
  final String? yearsOfExperience;

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
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'client',
      country: map['country'],
      primaryGoal: map['primaryGoal'],
      coachingCategory: map['coachingCategory'],
      yearsOfExperience: map['yearsOfExperience'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      if (country != null) 'country': country,
      if (primaryGoal != null) 'primaryGoal': primaryGoal,
      if (coachingCategory != null) 'coachingCategory': coachingCategory,
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
    };
  }
}