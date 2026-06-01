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
  Role,
  Segment,
  TopUser,
  TrendPoint,
  User,
  UserEvent,
} from "./types.js";

const NAMES = [
  "Luca",
  "Marco",
  "Giulia",
  "Francesca",
  "Alessandro",
  "Chiara",
  "Davide",
  "Elena",
];
const LAST_NAMES = ["Rossi", "Bianchi", "Ferrari", "Romano", "Gallo", "Conti"];
const ROLES: Role[] = ["Admin", "Editor", "User"];
const SEGMENTS: Segment[] = ["Power user", "Casual", "Inactive"];
const ACTIVITY_TYPES: ActivityType[] = ["login", "edit", "upload", "delete"];
const DEVICES: Device[] = ["web", "mobile", "desktop"];
const EVENT_TITLES = [
  "Flutter Meetup",
  "Tech Conference",
  "Design Sprint",
  "Hackathon",
  "Workshop UX",
];
const EVENT_STATUS: EventStatus[] = ["upcoming", "live", "ended"];
const CONTENT_TYPES: ContentType[] = ["image", "video", "post"];
const CONTENT_STATUS: ContentStatus[] = ["draft", "published", "archived"];
const CONTENT_TITLES = [
  "Landing Page Design",
  "Promo Video",
  "User Interview",
  "Marketing Campaign",
  "Dashboard UI",
];

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
function activityDescription(type: ActivityType): string {
  switch (type) {
    case "login":
      return "Accesso effettuato";
    case "edit":
      return "Modifica contenuto";
    case "upload":
      return "Caricamento asset";
    case "delete":
      return "Eliminazione elemento";
  }
}
function randomEntity(): string {
  return pick([
    `Post #${rand(100)}`,
    `Event #${rand(50)}`,
    "Profile update",
    "Media asset",
  ]);
}

export function buildSeed(): Database {
  const users: User[] = Array.from({ length: 20 }, (_, i) => {
    const isActive = Math.random() < 0.5;
    return {
      id: i + 1,
      name: NAMES[i % NAMES.length]!,
      last_name: LAST_NAMES[i % LAST_NAMES.length]!,
      email: `user${i + 1}@mediahub.dev`,
      role: ROLES[i % ROLES.length]!,
      segment: pick(SEGMENTS),
      is_active: isActive,
      created_at: pastDate(),
      last_login: isActive || Math.random() < 0.5 ? pastDate() : null,
    };
  });

  const activities: Record<number, Activity[]> = {};
  const events: Record<number, UserEvent[]> = {};
  const contents: Record<number, ContentItem[]> = {};

  for (const u of users) {
    activities[u.id] = Array.from({ length: 12 + rand(10) }, () => {
      const type = pick(ACTIVITY_TYPES);
      return {
        type,
        description: activityDescription(type),
        entity: randomEntity(),
        device: pick(DEVICES),
        date: pastDate(),
      };
    });

    events[u.id] = Array.from({ length: 4 + rand(6) }, (_, i) => ({
      id: i + 1,
      title: pick(EVENT_TITLES),
      date: futureDate(),
      attendees: 20 + rand(200),
      status: pick(EVENT_STATUS),
    }));

    contents[u.id] = Array.from({ length: 10 + rand(12) }, (_, i) => ({
      id: i + 1,
      title: pick(CONTENT_TITLES),
      type: pick(CONTENT_TYPES),
      status: pick(CONTENT_STATUS),
      created_at: pastDate(),
    }));
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

  const alerts: Alert[] = [
    { type: "warning", message: "High inactive users rate" },
    { type: "info", message: "New event starting soon" },
  ];

  const topUsers: TopUser[] = Array.from({ length: 5 }, () => ({
    name: pick(NAMES),
    score: 200 + rand(800),
  }));

  return { users, activities, events, contents, trend, alerts, topUsers };
}
