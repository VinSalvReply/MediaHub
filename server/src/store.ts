import { loadDb, saveDb } from "./db.js";
import { buildSeed } from "./seed.js";
import type { Database } from "./types.js";

class Store {
  private db: Database;

  constructor() {
    this.db = loadDb();
    if (this.db.users.length === 0) {
      this.db = buildSeed();
      this.persist();
    }
  }

  get data(): Database {
    return this.db;
  }

  persist(): void {
    saveDb(this.db);
  }

  reset(): void {
    this.db = buildSeed();
    this.persist();
  }
}

export const store = new Store();
