import cors from "cors";
import express, { type Express } from "express";
import { mkdirSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { errorHandler } from "./http.js";
import { artificialLatency } from "./middleware/latency.js";
import { mediaRouter } from "./routes/media.routes.js";
import { adminRouter } from "./routes/admin.routes.js";
import { contentsRouter } from "./routes/contents.routes.js";
import { dashboardRouter } from "./routes/dashboard.routes.js";
import { eventsRouter } from "./routes/events.routes.js";
import { usersRouter } from "./routes/users.routes.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const mediaDirectory = path.resolve(__dirname, "../media");

export function createApp(): Express {
  const app = express();
  mkdirSync(mediaDirectory, { recursive: true });

  app.use(cors());
  app.use(express.json());
  app.use("/media", express.static(mediaDirectory));

  app.get("/health", (_req, res) => {
    res.json({ ok: true });
  });

  // Simula la latenza di rete (configurabile via env LATENCY_MIN_MS / LATENCY_MAX_MS).
  app.use(artificialLatency());

  app.use("/users", usersRouter);
  app.use("/events", eventsRouter);
  app.use("/contents", contentsRouter);
  app.use("/dashboard", dashboardRouter);
  app.use("/admin", adminRouter);
  app.use("/media", mediaRouter);

  app.use(errorHandler);
  return app;
}
