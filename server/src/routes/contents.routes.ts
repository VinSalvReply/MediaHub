import { Router } from "express";
import { HttpError, notFound, parseId } from "../http.js";
import { contentRepository } from "../repositories/content.repository.js";
import { eventRepository } from "../repositories/event.repository.js";
import { userRepository } from "../repositories/user.repository.js";

export const contentsRouter: Router = Router();

function parseOptionalId(value: unknown, name: string): number | undefined {
  if (value === undefined || value === null || value === "") return undefined;
  if (Array.isArray(value)) {
    throw new HttpError(400, `${name} query param must be a number`);
  }
  return parseId(String(value), name);
}

function validateLinks(userId?: number, eventId?: number): void {
  if (typeof userId === "number" && !userRepository.find(userId)) {
    notFound("User not found");
  }
  if (typeof eventId === "number") {
    const eventExists = eventRepository
      .listGlobal()
      .some((event) => event.id === eventId);
    if (!eventExists) notFound("Event not found");
  }
}

contentsRouter.get("/", (req, res) => {
  const userId = parseOptionalId(req.query.userId, "userId");
  const eventId = parseOptionalId(req.query.eventId, "eventId");
  validateLinks(userId, eventId);
  res.json(contentRepository.listGlobal({ userId, eventId }));
});

contentsRouter.post("/", (req, res) => {
  const userId =
    typeof req.body?.user_id === "number" ? req.body.user_id : undefined;
  const eventId =
    typeof req.body?.event_id === "number" ? req.body.event_id : undefined;
  validateLinks(userId, eventId);
  res.status(201).json(contentRepository.createGlobal(req.body));
});

contentsRouter.put("/:contentId", (req, res) => {
  const contentId = parseId(req.params.contentId, "contentId");
  const userId =
    typeof req.body?.user_id === "number" ? req.body.user_id : undefined;
  const eventId =
    typeof req.body?.event_id === "number" ? req.body.event_id : undefined;
  validateLinks(userId, eventId);
  const updated = contentRepository.updateGlobal(contentId, req.body);
  if (!updated) notFound("Content not found");
  res.json(updated);
});

contentsRouter.delete("/:contentId", (req, res) => {
  const contentId = parseId(req.params.contentId, "contentId");
  if (!contentRepository.removeGlobal(contentId)) notFound("Content not found");
  res.status(204).end();
});
