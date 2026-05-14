class User {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });
}
