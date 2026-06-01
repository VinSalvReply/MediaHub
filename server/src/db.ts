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
  };
}

export function loadDb(): Database {
  if (!fs.existsSync(DB_FILE)) return emptyDb();
  try {
    const parsed = JSON.parse(
      fs.readFileSync(DB_FILE, "utf8"),
    ) as Partial<Database>;
    return {
      ...emptyDb(),
      ...parsed,
      global_events: parsed.global_events ?? [],
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
