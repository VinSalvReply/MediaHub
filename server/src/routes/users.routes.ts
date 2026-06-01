import { Router } from "express";
import { activityRepository } from "../repositories/activity.repository.js";
import { contentRepository } from "../repositories/content.repository.js";
import { eventRepository } from "../repositories/event.repository.js";
import { userRepository } from "../repositories/user.repository.js";
import { HttpError, notFound, parseId } from "../http.js";

export const usersRouter: Router = Router();

function requireUser(id: number) {
  const user = userRepository.find(id);
  if (!user) throw new HttpError(404, "User not found");
  return user;
}

// ---------- users ----------

usersRouter.get("/", (_req, res) => {
  res.json(userRepository.list());
});

usersRouter.get("/:id", (req, res) => {
  const id = parseId(req.params.id);
  const user = userRepository.find(id);
  if (!user) notFound("User not found");
  res.json(user);
});

usersRouter.post("/", (req, res) => {
  const user = userRepository.create(req.body);
  res.status(201).json(user);
});

usersRouter.put("/:id", (req, res) => {
  const id = parseId(req.params.id);
  const user = userRepository.update(id, req.body);
  if (!user) notFound("User not found");
  res.json(user);
});

usersRouter.delete("/:id", (req, res) => {
  const id = parseId(req.params.id);
  if (!userRepository.remove(id)) notFound("User not found");
  res.status(204).end();
});

// ---------- activity ----------

usersRouter.get("/:id/activity", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res.json(activityRepository.list(id));
});

usersRouter.post("/:id/activity", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res.status(201).json(activityRepository.create(id, req.body));
});

// ---------- events ----------

usersRouter.get("/:id/events", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res.json(eventRepository.list(id));
});

usersRouter.post("/:id/events", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res.status(201).json(eventRepository.create(id, req.body));
});

usersRouter.put("/:userId/events/:eventId", (req, res) => {
  const userId = parseId(req.params.userId, "userId");
  const eventId = parseId(req.params.eventId, "eventId");
  requireUser(userId);
  const updated = eventRepository.update(userId, eventId, req.body);
  if (!updated) notFound("Event not found");
  res.json(updated);
});

usersRouter.delete("/:userId/events/:eventId", (req, res) => {
  const userId = parseId(req.params.userId, "userId");
  const eventId = parseId(req.params.eventId, "eventId");
  requireUser(userId);
  if (!eventRepository.remove(userId, eventId)) notFound("Event not found");
  res.status(204).end();
});

// ---------- contents ----------

usersRouter.get("/:id/content", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res.json(contentRepository.list(id));
});

usersRouter.post("/:id/content", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res.status(201).json(contentRepository.create(id, req.body));
});

usersRouter.put("/:userId/content/:itemId", (req, res) => {
  const userId = parseId(req.params.userId, "userId");
  const itemId = parseId(req.params.itemId, "itemId");
  requireUser(userId);
  const updated = contentRepository.update(userId, itemId, req.body);
  if (!updated) notFound("Content not found");
  res.json(updated);
});

usersRouter.delete("/:userId/content/:itemId", (req, res) => {
  const userId = parseId(req.params.userId, "userId");
  const itemId = parseId(req.params.itemId, "itemId");
  requireUser(userId);
  if (!contentRepository.remove(userId, itemId)) notFound("Content not found");
  res.status(204).end();
});
