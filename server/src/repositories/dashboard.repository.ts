import { store } from "../store.js";
import { formatString, getString } from "../strings.js";
import type { Alert, GlobalEvent } from "../types.js";

function contentTypeLabel(type: string): string {
  switch (type) {
    case "image":
      return getString("dashboard.contentTypeImage");
    case "video":
      return getString("dashboard.contentTypeVideo");
    default:
      return getString("dashboard.contentTypePost");
  }
}

function eventScore(event: GlobalEvent, now: Date): number {
  const missing = !(event.contents ?? []).length ? 3 : 0;
  const draft = (event.contents ?? []).filter(
    (c) => c.status !== "published",
  ).length;
  const upcoming = new Date(event.date) > now ? 1 : 0;
  return missing + draft + upcoming;
}

export const dashboardRepository = {
  getDashboard() {
    const { global_events, trend, alerts } = store.data;
    const now = new Date();
    const weekLimit = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

    const contents = global_events.flatMap((e) => e.contents ?? []);
    const liveCount = global_events.filter((e) => e.status === "live").length;
    const upcomingThisWeek = global_events.filter((e) => {
      const d = new Date(e.date);
      return d > now && d < weekLimit && e.status !== "ended";
    }).length;
    const publishedContents = contents.filter(
      (c) => c.status === "published",
    ).length;
    const totalMediaAssets = contents.reduce(
      (sum, c) => sum + (c.media_urls?.length ?? 0),
      0,
    );
    const eventsWithoutContents = global_events.filter(
      (e) => !(e.contents ?? []).length,
    ).length;
    const eventsWithContents = global_events.filter(
      (e) => (e.contents ?? []).length > 0,
    ).length;
    const eventsLiveCovered = global_events.filter(
      (e) => e.status === "live" && (e.contents ?? []).length > 0,
    ).length;
    const contentsWithMedia = contents.filter(
      (c) => (c.media_urls ?? []).length > 0,
    ).length;

    const contentActivities = global_events.flatMap((event) =>
      (event.contents ?? []).map((content) => ({
        title: content.title,
        subtitle: formatString("dashboard.contentSubtitleTemplate", {
          type: contentTypeLabel(content.type),
          eventTitle: event.title,
        }),
        type: content.type,
        date: content.created_at,
      })),
    );
    const eventActivities = global_events.map((event) => ({
      title: event.title,
      subtitle:
        event.status === "live"
          ? getString("dashboard.eventLiveSubtitle")
          : getString("dashboard.eventPlannedSubtitle"),
      type: event.status === "live" ? "live" : "event",
      date: event.date,
    }));
    const activities = [...contentActivities, ...eventActivities]
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
      .slice(0, 8);

    const focusEvents = [...global_events]
      .sort((a, b) => eventScore(b, now) - eventScore(a, now))
      .slice(0, 5)
      .map((event) => ({
        title: event.title,
        date: event.date,
        status: event.status,
        contentCount: (event.contents ?? []).length,
        publishedCount: (event.contents ?? []).filter(
          (c) => c.status === "published",
        ).length,
        mediaCount: (event.contents ?? []).reduce(
          (sum, c) => sum + (c.media_urls?.length ?? 0),
          0,
        ),
        needsAttention:
          !(event.contents ?? []).length ||
          (event.contents ?? []).some((c) => c.status !== "published"),
      }));

    return {
      metrics: {
        totalEvents: global_events.length,
        liveEvents: liveCount,
        upcomingThisWeek,
        totalContents: contents.length,
        publishedContents,
        totalMediaAssets,
        eventsWithoutContents,
      },
      activities,
      insights: [
        {
          label: getString("dashboard.insightEventsWithContents"),
          value:
            global_events.length === 0
              ? 0
              : eventsWithContents / global_events.length,
        },
        {
          label: getString("dashboard.insightPublishedContents"),
          value:
            contents.length === 0 ? 0 : publishedContents / contents.length,
        },
        {
          label: getString("dashboard.insightLiveCoverage"),
          value: liveCount === 0 ? 0 : eventsLiveCovered / liveCount,
        },
        {
          label: getString("dashboard.insightContentsWithMedia"),
          value:
            contents.length === 0 ? 0 : contentsWithMedia / contents.length,
        },
      ],
      trend,
      alerts,
      focusEvents,
    };
  },

  addAlert(input: Partial<Alert>): Alert {
    const alert: Alert = {
      type: input.type ?? store.data.strings.defaults.alertType,
      message: input.message ?? "",
    };
    store.data.alerts.push(alert);
    store.persist();
    return alert;
  },
};
