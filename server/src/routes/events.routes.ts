import { Router } from "express";
import { HttpError, notFound, parseId } from "../http.js";
import { eventRepository } from "../repositories/event.repository.js";
import { userRepository } from "../repositories/user.repository.js";

export const eventsRouter: Router = Router();

function parseOptionalUserId(value: unknown): number | undefined {
  if (value === undefined || value === null || value === "") return undefined;
  if (Array.isArray(value))
    throw new HttpError(400, "userId query param must be a number");
  return parseId(String(value), "userId");
}

eventsRouter.get("/", (req, res) => {
  const userId = parseOptionalUserId(req.query.userId);
  if (typeof userId === "number" && !userRepository.find(userId)) {
    notFound("User not found");
  }
  res.json(eventRepository.listGlobal(userId));
});

eventsRouter.post("/", (req, res) => {
  const userId = req.body?.user_id;
  if (typeof userId === "number" && !userRepository.find(userId)) {
    notFound("User not found");
  }
  res.status(201).json(eventRepository.createGlobal(req.body));
});

eventsRouter.put("/:eventId", (req, res) => {
  const eventId = parseId(req.params.eventId, "eventId");
  const userId = req.body?.user_id;
  if (typeof userId === "number" && !userRepository.find(userId)) {
    notFound("User not found");
  }
  const updated = eventRepository.updateGlobal(eventId, req.body);
  if (!updated) notFound("Event not found");
  res.json(updated);
});

eventsRouter.delete("/:eventId", (req, res) => {
  const eventId = parseId(req.params.eventId, "eventId");
  if (!eventRepository.removeGlobal(eventId)) notFound("Event not found");
  res.status(204).end();
});
