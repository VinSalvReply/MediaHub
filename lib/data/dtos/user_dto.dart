class UserDto {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String role;
  final bool isActive;
  final String createdAt;
  final String? lastLogin;

  const UserDto({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      lastLogin: json['last_login'] as String?,
    );
  }
}
