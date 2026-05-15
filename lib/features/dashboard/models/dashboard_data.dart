import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/user_activity.dart';

class DashboardData {
  final List<User> users;
  final List<UserActivity> activities;
  final List<Event> events;
  final List<ContentItem> contents;

  DashboardData({
    required this.users,
    required this.activities,
    required this.events,
    required this.contents,
  });
}
