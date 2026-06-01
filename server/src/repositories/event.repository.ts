import { nextId } from "../db.js";
import { store } from "../store.js";
import type { UserEvent } from "../types.js";

export type EventCreateInput = Partial<Omit<UserEvent, "id">>;
export type EventUpdateInput = Partial<Omit<UserEvent, "id">>;

export const eventRepository = {
  list(userId: number): UserEvent[] {
    return store.data.events[userId] ?? [];
  },

  create(userId: number, input: EventCreateInput): UserEvent {
    const list = (store.data.events[userId] ??= []);
    const event: UserEvent = {
      id: nextId(list),
      title: input.title ?? "Untitled",
      date: input.date ?? new Date().toISOString(),
      attendees: input.attendees ?? 0,
      status: input.status ?? "upcoming",
    };
    list.push(event);
    store.persist();
    return event;
  },

  update(
    userId: number,
    eventId: number,
    patch: EventUpdateInput,
  ): UserEvent | undefined {
    const list = store.data.events[userId];
    if (!list) return undefined;
    const idx = list.findIndex((e) => e.id === eventId);
    if (idx === -1) return undefined;
    const existing = list[idx]!;
    const updated: UserEvent = { ...existing, ...patch, id: eventId };
    list[idx] = updated;
    store.persist();
    return updated;
  },

  remove(userId: number, eventId: number): boolean {
    const list = store.data.events[userId];
    if (!list) return false;
    const before = list.length;
    store.data.events[userId] = list.filter((e) => e.id !== eventId);
    if (store.data.events[userId]!.length === before) return false;
    store.persist();
    return true;
  },
};
