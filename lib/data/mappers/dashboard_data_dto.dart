import 'package:mediahub/features/dashboard/models/dashboard_data.dart';
import 'package:mediahub/data/dtos/dashboard_data_dto.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/event.dart';

class DashboardMapper {
  static DashboardData toDashboard({
    required List<User> users,
    required List<Event> events,
    required List<DashboardTrendDto> trend,
    required List<DashboardAlertDto> alerts,
  }) {
    final now = DateTime.now();
    final weekLimit = now.add(const Duration(days: 7));
    final contents = events.expand((event) => event.contents).toList();
    final liveEvents = events
        .where((event) => event.status == EventStatus.live)
        .length;
    final upcomingThisWeek = events
        .where(
          (event) =>
              event.date.isAfter(now) &&
              event.date.isBefore(weekLimit) &&
              event.status != EventStatus.ended,
        )
        .length;
    final publishedContents = contents
        .where((content) => content.status == 'published')
        .length;
    final totalMediaAssets = contents.fold<int>(
      0,
      (sum, content) => sum + content.mediaUrls.length,
    );
    final eventsWithoutContents = events
        .where((event) => event.contents.isEmpty)
        .length;

    final recentContentActivities = events
        .expand(
          (event) => event.contents.map(
            (content) => DashboardActivity(
              title: content.title,
              subtitle:
                  'Contenuto ${_contentTypeLabel(content.type)} in ${event.title}',
              type: content.type,
              date: content.createdAt,
            ),
          ),
        )
        .toList();

    final recentEventActivities = events
        .map(
          (event) => DashboardActivity(
            title: event.title,
            subtitle: event.status == EventStatus.live
                ? 'Evento live in corso'
                : 'Evento pianificato',
            type: event.status == EventStatus.live ? 'live' : 'event',
            date: event.date,
          ),
        )
        .toList();

    final activityFeed = [...recentContentActivities, ...recentEventActivities]
      ..sort((a, b) => b.date.compareTo(a.date));

    final eventsWithContents = events
        .where((event) => event.contents.isNotEmpty)
        .length;
    final eventsLiveCovered = events
        .where(
          (event) =>
              event.status == EventStatus.live && event.contents.isNotEmpty,
        )
        .length;
    final contentsWithMedia = contents
        .where((content) => content.mediaUrls.isNotEmpty)
        .length;

    final focusEvents = [...events]
      ..sort((a, b) {
        int score(Event event) {
          final missingContents = event.contents.isEmpty ? 3 : 0;
          final draftContents = event.contents
              .where((content) => content.status != 'published')
              .length;
          final upcomingBoost = event.date.isAfter(now) ? 1 : 0;
          return missingContents + draftContents + upcomingBoost;
        }

        return score(b).compareTo(score(a));
      });

    return DashboardData(
      metrics: DashboardMetrics(
        totalEvents: events.length,
        liveEvents: liveEvents,
        upcomingThisWeek: upcomingThisWeek,
        totalContents: contents.length,
        publishedContents: publishedContents,
        totalMediaAssets: totalMediaAssets,
        eventsWithoutContents: eventsWithoutContents,
      ),

      activities: activityFeed.take(8).toList(),

      insights: [
        DashboardInsight(
          label: 'Eventi con contenuti',
          value: events.isEmpty ? 0 : eventsWithContents / events.length,
        ),
        DashboardInsight(
          label: 'Contenuti pubblicati',
          value: contents.isEmpty ? 0 : publishedContents / contents.length,
        ),
        DashboardInsight(
          label: 'Eventi live coperti',
          value: liveEvents == 0 ? 0 : eventsLiveCovered / liveEvents,
        ),
        DashboardInsight(
          label: 'Contenuti con media',
          value: contents.isEmpty ? 0 : contentsWithMedia / contents.length,
        ),
      ],

      trend: trend
          .map(
            (t) => DashboardTrendPoint(
              date: t.date,
              activeUsers: t.activeUsers,
              contentCreated: t.contentCreated,
            ),
          )
          .toList(),

      alerts: alerts
          .map((a) => DashboardAlert(type: a.type, message: a.message))
          .toList(),

      focusEvents: focusEvents
          .take(5)
          .map(
            (event) => DashboardFocusEvent(
              title: event.title,
              date: event.date,
              status: event.status.name,
              contentCount: event.contents.length,
              publishedCount: event.contents
                  .where((content) => content.status == 'published')
                  .length,
              mediaCount: event.contents.fold<int>(
                0,
                (sum, content) => sum + content.mediaUrls.length,
              ),
              needsAttention:
                  event.contents.isEmpty ||
                  event.contents.any(
                    (content) => content.status != 'published',
                  ),
            ),
          )
          .toList(),
    );
  }
}

String _contentTypeLabel(String type) {
  switch (type) {
    case 'image':
      return 'immagine';
    case 'video':
      return 'video';
    case 'post':
    default:
      return 'post';
  }
}
