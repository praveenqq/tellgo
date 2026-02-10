class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? photoUrl;
  final bool emailVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImageUrl,
    this.photoUrl,
    this.emailVerified = false,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    String? photoUrl,
    bool? emailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
