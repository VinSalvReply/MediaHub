class UserDto {
  final int id;

  final String name;
  final String last_name;
  final String email;

  final String role;

  final bool is_active;
  final String created_at;
  final String? last_login;

  final List<int>? assigned_events;

  UserDto({
    required this.id,
    required this.name,
    required this.last_name,
    required this.email,
    required this.role,
    required this.is_active,
    required this.created_at,
    this.last_login,
    this.assigned_events,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      name: json['name'],
      last_name: json['last_name'],
      email: json['email'],
      role: json['role'],
      is_active: json['is_active'],
      created_at: json['created_at'],
      last_login: json['last_login'],
      assigned_events: (json['assigned_events'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );
  }
}
