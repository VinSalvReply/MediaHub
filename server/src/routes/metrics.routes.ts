import { Router } from "express";
import { appendFileSync, mkdirSync, readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const metricsRouter: Router = Router();

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const metricsDirectory = path.resolve(__dirname, "..", "..", "data");
const metricsFile = path.join(metricsDirectory, "web-vitals.jsonl");

type WebVitalPayload = {
  name?: unknown;
  value?: unknown;
  rating?: unknown;
  delta?: unknown;
  id?: unknown;
  navigationType?: unknown;
  url?: unknown;
  userAgent?: unknown;
  timestamp?: unknown;
  build?: unknown;
  formFactor?: unknown;
  viewportWidth?: unknown;
  viewportHeight?: unknown;
  devicePixelRatio?: unknown;
};

metricsRouter.post("/", (req, res) => {
  const payload = req.body as WebVitalPayload;
  const metric = {
    receivedAt: new Date().toISOString(),
    name: typeof payload.name === "string" ? payload.name : "unknown",
    value: typeof payload.value === "number" ? payload.value : null,
    rating: typeof payload.rating === "string" ? payload.rating : null,
    delta: typeof payload.delta === "number" ? payload.delta : null,
    id: typeof payload.id === "string" ? payload.id : null,
    navigationType:
      typeof payload.navigationType === "string"
        ? payload.navigationType
        : null,
    url: typeof payload.url === "string" ? payload.url : null,
    userAgent: typeof payload.userAgent === "string" ? payload.userAgent : null,
    timestamp: typeof payload.timestamp === "number" ? payload.timestamp : null,
    build: typeof payload.build === "string" ? payload.build : "unknown",
    formFactor:
      typeof payload.formFactor === "string" ? payload.formFactor : "unknown",
    viewportWidth:
      typeof payload.viewportWidth === "number" ? payload.viewportWidth : null,
    viewportHeight:
      typeof payload.viewportHeight === "number"
        ? payload.viewportHeight
        : null,
    devicePixelRatio:
      typeof payload.devicePixelRatio === "number"
        ? payload.devicePixelRatio
        : null,
  };

  mkdirSync(metricsDirectory, { recursive: true });
  appendFileSync(metricsFile, `${JSON.stringify(metric)}\n`, "utf8");
  res.status(204).end();
});

metricsRouter.get("/", (req, res) => {
  const limit = Math.min(Number(req.query.limit ?? 100), 1000);
  const build = typeof req.query.build === "string" ? req.query.build : null;
  const formFactor = typeof req.query.form === "string" ? req.query.form : null;

  try {
    const entries = readFileSync(metricsFile, "utf8")
      .trim()
      .split("\n")
      .filter(Boolean)
      .map((line) => JSON.parse(line))
      .filter((entry) => !build || entry.build === build)
      .filter((entry) => !formFactor || entry.formFactor === formFactor)
      .slice(-limit);

    res.json(entries);
  } catch {
    res.json([]);
  }
});
