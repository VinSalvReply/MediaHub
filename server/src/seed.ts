import type {
  Activity,
  ActivityType,
  Alert,
  ContentItem,
  ContentStatus,
  ContentType,
  Database,
  Device,
  EventStatus,
  GlobalContentItem,
  Role,
  Segment,
  TopUser,
  TrendPoint,
  User,
  UserEvent,
  GlobalEvent,
} from "./types.js";
import { loadDb } from "./db.js";

const ROLES: Role[] = ["Admin", "Editor", "User"];
const SEGMENTS: Segment[] = ["Power user", "Casual", "Inactive"];
const ACTIVITY_TYPES: ActivityType[] = ["login", "edit", "upload", "delete"];
const DEVICES: Device[] = ["web", "mobile", "desktop"];
const EVENT_STATUS: EventStatus[] = ["upcoming", "live", "ended"];
const CONTENT_TYPES: ContentType[] = ["image", "video", "post"];
const CONTENT_STATUS: ContentStatus[] = ["draft", "published", "archived"];

function loadSeedCatalog() {
  return loadDb().strings.seed;
}

function pick<T>(list: readonly T[]): T {
  return list[Math.floor(Math.random() * list.length)]!;
}
function rand(n: number): number {
  return Math.floor(Math.random() * n);
}
function pastDate(): string {
  const d = new Date();
  d.setDate(d.getDate() - rand(30));
  d.setHours(d.getHours() - rand(24));
  return d.toISOString();
}
function futureDate(): string {
  const d = new Date();
  d.setDate(d.getDate() + rand(60));
  return d.toISOString();
}

function applyTemplate(
  template: string,
  values: Record<string, number>,
): string {
  return Object.entries(values).reduce((text, [key, value]) => {
    return text.split(`{${key}}`).join(String(value));
  }, template);
}

function rolePool(dbUsers: User[]): Role[] {
  const pool = Array.from(new Set(dbUsers.map((user) => user.role)));
  return pool.length > 0 ? pool : ROLES;
}

function segmentPool(dbUsers: User[]): Segment[] {
  const pool = Array.from(new Set(dbUsers.map((user) => user.segment)));
  return pool.length > 0 ? pool : SEGMENTS;
}

export function buildSeed(): Database {
  const catalog = loadSeedCatalog();
  const currentDb = loadDb();
  const seedNames = catalog.names.length
    ? catalog.names
    : currentDb.users.map((user) => user.name);
  const seedLastNames = catalog.lastNames.length
    ? catalog.lastNames
    : currentDb.users.map((user) => user.last_name);
  const seedEventTitles = catalog.eventTitles.length
    ? catalog.eventTitles
    : currentDb.global_events.map((event) => event.title);
  const seedContentTitles = catalog.contentTitles.length
    ? catalog.contentTitles
    : currentDb.global_contents.map((content) => content.title);
  const seedGlobalEventTitles =
    catalog.globalEventTitles.length > 1
      ? catalog.globalEventTitles
      : seedEventTitles;
  const seedGlobalContentTitles =
    catalog.globalContentTitles.length > 1
      ? catalog.globalContentTitles
      : seedContentTitles;
  const seedEntities = catalog.entities.length
    ? catalog.entities
    : currentDb.users.map((user) => user.email);
  const activityDescriptions = catalog.activityDescriptions;
  const roleValues = rolePool(currentDb.users);
  const segmentValues = segmentPool(currentDb.users);

  const users: User[] = Array.from({ length: 20 }, (_, i) => {
    const isActive = Math.random() < 0.5;
    return {
      id: i + 1,
      name: seedNames[i % seedNames.length] ?? "",
      last_name: seedLastNames[i % seedLastNames.length] ?? "",
      email: applyTemplate(catalog.emailTemplate, { id: i + 1 }),
      role: roleValues[i % roleValues.length]!,
      segment: pick(segmentValues),
      is_active: isActive,
      created_at: pastDate(),
      last_login: isActive || Math.random() < 0.5 ? pastDate() : null,
    };
  });

  const activities: Record<number, Activity[]> = {};
  const events: Record<number, UserEvent[]> = {};
  const global_events: GlobalEvent[] = [];
  const contents: Record<number, ContentItem[]> = {};
  const global_contents: GlobalContentItem[] = [];

  for (const u of users) {
    activities[u.id] = Array.from({ length: 12 + rand(10) }, () => {
      const type = pick(ACTIVITY_TYPES);
      return {
        type,
        description: activityDescriptions[type] ?? "",
        entity: pick([
          applyTemplate(catalog.entityPostTemplate, { id: rand(100) }),
          applyTemplate(catalog.entityEventTemplate, { id: rand(50) }),
          pick(seedEntities),
        ]),
        device: pick(DEVICES),
        date: pastDate(),
      };
    });

    events[u.id] = Array.from({ length: 4 + rand(6) }, (_, i) => ({
      id: i + 1,
      title: pick(seedEventTitles),
      date: futureDate(),
      attendees: 20 + rand(200),
      status: pick(EVENT_STATUS),
    }));

    for (const e of events[u.id]!) {
      if (Math.random() < 0.55) {
        global_events.push({
          id: global_events.length + 1,
          title: e.title,
          date: e.date,
          attendees: e.attendees,
          status: e.status,
          user_id: u.id,
        });
      }
    }

    contents[u.id] = Array.from({ length: 10 + rand(12) }, (_, i) => ({
      id: i + 1,
      title: pick(seedContentTitles),
      type: pick(CONTENT_TYPES),
      status: pick(CONTENT_STATUS),
      created_at: pastDate(),
    }));

    for (const c of contents[u.id]!) {
      const candidates = global_events.filter(
        (event) => event.user_id === u.id,
      );
      const linkedEvent =
        candidates.length > 0 && Math.random() < 0.45 ? pick(candidates) : null;
      global_contents.push({
        id: global_contents.length + 1,
        title: c.title,
        type: c.type,
        status: c.status,
        created_at: c.created_at,
        user_id: u.id,
        event_id: linkedEvent?.id ?? null,
      });
    }
  }

  const trend: TrendPoint[] = Array.from({ length: 14 }, (_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - i);
    return {
      date: d.toISOString(),
      active_users: 40 + rand(80),
      content_created: 10 + rand(40),
    };
  }).reverse();

  const alerts: Alert[] = [];

  const topUsers: TopUser[] = Array.from({ length: 5 }, () => ({
    name: pick(seedNames),
    score: 200 + rand(800),
  }));

  global_events.push(
    {
      id: global_events.length + 1,
      title: seedGlobalEventTitles[0] ?? "",
      date: futureDate(),
      attendees: 350,
      status: "upcoming",
      user_id: null,
    },
    {
      id: global_events.length + 2,
      title: seedGlobalEventTitles[1] ?? "",
      date: futureDate(),
      attendees: 120,
      status: "live",
      user_id: null,
    },
  );

  global_contents.push(
    {
      id: global_contents.length + 1,
      title: seedGlobalContentTitles[0] ?? "",
      type: "video",
      status: "draft",
      created_at: pastDate(),
      user_id: null,
      event_id: null,
    },
    {
      id: global_contents.length + 2,
      title: seedGlobalContentTitles[1] ?? "",
      type: "image",
      status: "published",
      created_at: pastDate(),
      user_id: null,
      event_id: global_events[0]?.id ?? null,
    },
  );

  return {
    users,
    activities,
    events,
    global_events,
    contents,
    global_contents,
    trend,
    alerts,
    topUsers,
    strings: currentDb.strings,
  };
}
