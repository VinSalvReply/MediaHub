import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import type { Database } from "./types.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DB_FILE = path.resolve(__dirname, "..", "data", "db.json");

function emptyDb(): Database {
  return {
    users: [],
    activities: {},
    events: {},
    global_events: [],
    contents: {},
    global_contents: [],
    trend: [],
    alerts: [],
    topUsers: [],
    strings: {
      errors: {
        resourceNotFound: "Risorsa non trovata",
        internalServerError: "Errore interno del server",
        invalidField: "Campo non valido",
        idLabel: "ID",
        userNotFound: "Utente non trovato",
        eventNotFound: "Evento non trovato",
        contentNotFound: "Contenuto non trovato",
        queryParamMustBeNumber: "Il parametro deve essere un numero",
        mediaUrlRequired: "URL del media richiesto",
        mediaUploadMissingFile: "File da caricare mancante",
        mediaImportFailed: "Importazione media non riuscita",
      },
      defaults: {
        untitled: "Evento senza titolo",
        untitledContent: "Contenuto senza titolo",
        userRole: "User",
        userSegment: "Casual",
        activityType: "login",
        activityDescription: "Accesso effettuato",
        device: "web",
        eventStatus: "upcoming",
        contentType: "post",
        contentStatus: "draft",
        alertType: "info",
        emailTemplate: "user{id}@mediahub.dev",
      },
      dashboard: {
        contentTypeImage: "Immagine",
        contentTypeVideo: "Video",
        contentTypePost: "Post",
        contentSubtitleTemplate: "{type} - {eventTitle}",
        eventLiveSubtitle: "Evento in diretta",
        eventPlannedSubtitle: "Evento pianificato",
        insightEventsWithContents: "Eventi con contenuti",
        insightPublishedContents: "Contenuti pubblicati",
        insightLiveCoverage: "Copertura eventi live",
        insightContentsWithMedia: "Contenuti con media",
      },
      logs: {
        serverListening: "MediaHub server listening on http://localhost:{port}",
        seededUsers: "Creati {count} utenti demo",
      },
      seed: {
        names: ["Luca", "Marco", "Giulia", "Francesca", "Alessandro", "Chiara", "Davide", "Elena"],
        lastNames: ["Rossi", "Bianchi", "Ferrari", "Romano", "Gallo", "Conti"],
        eventTitles: ["Flutter Meetup", "Tech Conference", "Design Sprint", "Hackathon", "Workshop UX"],
        contentTitles: ["Landing Page Design", "Promo Video", "User Interview", "Marketing Campaign", "Dashboard UI"],
        globalEventTitles: ["MediaHub Product Launch", "Community Live Q&A"],
        globalContentTitles: ["Summer Campaign Hero Video", "Product Launch Social Carousel"],
        entityPostTemplate: "Post #{id}",
        entityEventTemplate: "Event #{id}",
        entities: ["Profile update", "Media asset"],
        activityDescriptions: {
          login: "Accesso effettuato",
          edit: "Modifica contenuto",
          upload: "Caricamento asset",
          delete: "Eliminazione elemento",
        },
        emailTemplate: "user{id}@mediahub.dev",
      },
    },
  };
}

function withDefaults<T>(defaults: T, stored: unknown): T {
  if (Array.isArray(defaults)) {
    return Array.isArray(stored) && stored.length > 0 ? stored as T : defaults;
  }
  if (defaults !== null && typeof defaults === "object") {
    const values = stored !== null && typeof stored === "object" && !Array.isArray(stored)
      ? stored as Record<string, unknown>
      : {};
    return {
      ...values,
      ...Object.fromEntries(
        Object.entries(defaults).map(([key, value]) => [
          key,
          withDefaults(value, values[key]),
        ]),
      ),
    } as T;
  }
  return stored == null || (typeof stored === "string" && stored.trim() === "")
    ? defaults
    : stored as T;
}

export function loadDb(): Database {
  if (!fs.existsSync(DB_FILE)) return emptyDb();
  try {
    const parsed = JSON.parse(
      fs.readFileSync(DB_FILE, "utf8"),
    ) as Partial<Database>;
    const defaults = emptyDb();
    const strings = withDefaults(defaults.strings, parsed.strings);
    return {
      ...defaults,
      ...parsed,
      strings,
      global_events: (parsed.global_events ?? []).map((event) => ({
        ...event,
        title: event.title ?? strings.defaults.untitled,
      })),
      global_contents: parsed.global_contents ?? [],
    } as Database;
  } catch {
    return emptyDb();
  }
}

export function saveDb(db: Database): void {
  fs.mkdirSync(path.dirname(DB_FILE), { recursive: true });
  fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2), "utf8");
}

export function nextId(list: { id: number }[]): number {
  return list.reduce((max, item) => Math.max(max, item.id), 0) + 1;
}
