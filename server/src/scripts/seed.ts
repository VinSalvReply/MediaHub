import { loadDb, saveDb } from "../db.js";
import { buildSeed } from "../seed.js";

const seeded = buildSeed();
saveDb(seeded);
const reloaded = loadDb();
console.log(`Seeded ${reloaded.users.length} users.`);
