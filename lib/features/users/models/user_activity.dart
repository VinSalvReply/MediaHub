/// Stores a single user activity entry for the detail view.
class UserActivity {
  final String type;
  final String description;
  final DateTime date;

  const UserActivity({
    required this.type,
    required this.description,
    required this.date,
  });
}
