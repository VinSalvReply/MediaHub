import { loadDb, saveDb } from "../db.js";
import { buildSeed } from "../seed.js";
import { formatString } from "../strings.js";

const seeded = buildSeed();
saveDb(seeded);
const reloaded = loadDb();
console.log(
  formatString("logs.seededUsers", {
    count: reloaded.users.length,
  }),
);
