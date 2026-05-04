
/// Modèle utilisateur (simplifié)
class UserModel {
  final int id;
  final String email;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String userType; // 'customer', 'driver', 'admin'
  final bool phoneVerified;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    this.firstName,
    this.lastName,
    required this.userType,
    this.phoneVerified = false,
    this.profileImage,
  });

  /// Nom complet
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? email.split('@').first;
  }

  /// Factory depuis JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      userType: json['user_type'] as String,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      profileImage: json['profile_image'] as String?,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType,
      'phone_verified': phoneVerified,
      'profile_image': profileImage,
    };
  }

  /// Copie avec modifications
  UserModel copyWith({
    int? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? userType,
    bool? phoneVerified,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userType: userType ?? this.userType,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}