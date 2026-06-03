import { nextId } from "../db.js";
import { store } from "../store.js";
import type { ContentItem, GlobalEvent, UserEvent } from "../types.js";

export type EventCreateInput = Partial<Omit<UserEvent, "id">>;
export type EventUpdateInput = Partial<Omit<UserEvent, "id">>;
export type GlobalEventCreateInput = Partial<Omit<GlobalEvent, "id">>;
export type GlobalEventUpdateInput = Partial<Omit<GlobalEvent, "id">>;

export const eventRepository = {
  normalizeContents(inputContents: ContentItem[] | undefined): ContentItem[] {
    return (inputContents ?? []).map((content, index) => ({
      id: content.id ?? index + 1,
      title: content.title ?? "Contenuto senza titolo",
      type: content.type ?? "post",
      status: content.status ?? "draft",
      created_at: content.created_at ?? new Date().toISOString(),
      media_urls: content.media_urls ?? [],
      post_body: content.post_body ?? null,
      cta_label: content.cta_label ?? null,
      cta_url: content.cta_url ?? null,
      tags: content.tags ?? [],
    }));
  },

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
      contents: eventRepository.normalizeContents(input.contents),
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

  listGlobal(userId?: number): GlobalEvent[] {
    if (typeof userId !== "number") return store.data.global_events;
    return store.data.global_events.filter((e) => e.user_id === userId);
  },

  createGlobal(input: GlobalEventCreateInput): GlobalEvent {
    const event: GlobalEvent = {
      id: nextId(store.data.global_events),
      title: input.title ?? "Untitled",
      date: input.date ?? new Date().toISOString(),
      attendees: input.attendees ?? 0,
      status: input.status ?? "upcoming",
      user_id: input.user_id ?? null,
      contents: eventRepository.normalizeContents(input.contents),
    };
    store.data.global_events.push(event);
    store.persist();
    return event;
  },

  updateGlobal(
    eventId: number,
    patch: GlobalEventUpdateInput,
  ): GlobalEvent | undefined {
    const idx = store.data.global_events.findIndex((e) => e.id === eventId);
    if (idx === -1) return undefined;
    const existing = store.data.global_events[idx]!;
    const updated: GlobalEvent = { ...existing, ...patch, id: eventId };
    store.data.global_events[idx] = updated;
    store.persist();
    return updated;
  },

  removeGlobal(eventId: number): boolean {
    const before = store.data.global_events.length;
    store.data.global_events = store.data.global_events.filter(
      (e) => e.id !== eventId,
    );
    if (store.data.global_events.length === before) return false;
    store.persist();
    return true;
  },
};
