import { Router } from "express";
import { activityRepository } from "../repositories/activity.repository.js";
import { contentRepository } from "../repositories/content.repository.js";
import { eventRepository } from "../repositories/event.repository.js";
import { userRepository } from "../repositories/user.repository.js";
import { HttpError, notFound, parseId } from "../http.js";
import { getString } from "../strings.js";

export const usersRouter: Router = Router();

function requireUser(id: number) {
  const user = userRepository.find(id);
  if (!user) throw new HttpError(404, getString("errors.userNotFound"));
  return user;
}

// ---------- users ----------

usersRouter.get("/", (_req, res) => {
  res.json(userRepository.list());
});

usersRouter.get("/:id", (req, res) => {
  const id = parseId(req.params.id);
  const user = userRepository.find(id);
  if (!user) notFound(getString("errors.userNotFound"));
  res.json(user);
});

usersRouter.post("/", (req, res) => {
  const user = userRepository.create(req.body);
  res.status(201).json(user);
});

usersRouter.put("/:id", (req, res) => {
  const id = parseId(req.params.id);
  const user = userRepository.update(id, req.body);
  if (!user) notFound(getString("errors.userNotFound"));
  res.json(user);
});

usersRouter.delete("/:id", (req, res) => {
  const id = parseId(req.params.id);
  if (!userRepository.remove(id)) notFound(getString("errors.userNotFound"));
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
  res.json(eventRepository.listGlobal(id));
});

usersRouter.post("/:id/events", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res
    .status(201)
    .json(eventRepository.createGlobal({ ...req.body, user_id: id }));
});

usersRouter.put("/:userId/events/:eventId", (req, res) => {
  const userId = parseId(req.params.userId, "userId");
  const eventId = parseId(req.params.eventId, "eventId");
  requireUser(userId);
  const existing = eventRepository
    .listGlobal(userId)
    .find((event) => event.id === eventId);
  if (!existing) notFound(getString("errors.eventNotFound"));
  const updated = eventRepository.updateGlobal(eventId, {
    ...req.body,
    user_id: userId,
  });
  if (!updated) notFound(getString("errors.eventNotFound"));
  res.json(updated);
});

usersRouter.delete("/:userId/events/:eventId", (req, res) => {
  const userId = parseId(req.params.userId, "userId");
  const eventId = parseId(req.params.eventId, "eventId");
  requireUser(userId);
  const existing = eventRepository
    .listGlobal(userId)
    .find((event) => event.id === eventId);
  if (!existing) notFound(getString("errors.eventNotFound"));
  if (!eventRepository.removeGlobal(eventId)) {
    notFound(getString("errors.eventNotFound"));
  }
  res.status(204).end();
});

// ---------- contents ----------

usersRouter.get("/:id/content", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res.json(contentRepository.listGlobal({ userId: id }));
});

usersRouter.post("/:id/content", (req, res) => {
  const id = parseId(req.params.id);
  requireUser(id);
  res
    .status(201)
    .json(contentRepository.createGlobal({ ...req.body, user_id: id }));
});

usersRouter.put("/:userId/content/:itemId", (req, res) => {
  const userId = parseId(req.params.userId, "userId");
  const itemId = parseId(req.params.itemId, "itemId");
  requireUser(userId);
  const existing = contentRepository
    .listGlobal({ userId })
    .find((item) => item.id === itemId);
  if (!existing) notFound(getString("errors.contentNotFound"));
  const updated = contentRepository.updateGlobal(itemId, {
    ...req.body,
    user_id: userId,
  });
  if (!updated) notFound(getString("errors.contentNotFound"));
  res.json(updated);
});

usersRouter.delete("/:userId/content/:itemId", (req, res) => {
  const userId = parseId(req.params.userId, "userId");
  const itemId = parseId(req.params.itemId, "itemId");
  requireUser(userId);
  const existing = contentRepository
    .listGlobal({ userId })
    .find((item) => item.id === itemId);
  if (!existing) notFound(getString("errors.contentNotFound"));
  if (!contentRepository.removeGlobal(itemId)) {
    notFound(getString("errors.contentNotFound"));
  }
  res.status(204).end();
});
