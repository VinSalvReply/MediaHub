class UserDto {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String role;
  final bool isActive;
  final String createdAt;
  final String? lastLogin;

  UserDto({
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
      id: json['id'],
      name: json['name'],
      lastName: json['last_name'],
      email: json['email'],
      role: json['role'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      lastLogin: json['last_login'],
    );
  }
}
