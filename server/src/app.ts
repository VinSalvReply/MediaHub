import cors from "cors";
import express, { type Express } from "express";
import { errorHandler } from "./http.js";
import { artificialLatency } from "./middleware/latency.js";
import { adminRouter } from "./routes/admin.routes.js";
import { contentsRouter } from "./routes/contents.routes.js";
import { dashboardRouter } from "./routes/dashboard.routes.js";
import { eventsRouter } from "./routes/events.routes.js";
import { usersRouter } from "./routes/users.routes.js";

export function createApp(): Express {
  const app = express();
  app.use(cors());
  app.use(express.json());

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

  app.use(errorHandler);
  return app;
}
