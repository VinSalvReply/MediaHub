import 'package:mediahub/features/contents/models/content_item.dart';
import 'package:mediahub/features/events/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/user_activity.dart';

/// Aggregates all data needed to render a user detail screen.
class UserDetailData {
  final User user;
  final List<UserActivity> activities;
  final List<Event> events;
  final List<ContentItem> contents;

  const UserDetailData({
    required this.user,
    required this.activities,
    required this.events,
    required this.contents,
  });
}
