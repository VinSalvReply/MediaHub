import { nextId } from "../db.js";
import { store } from "../store.js";
import type { ContentItem, GlobalContentItem } from "../types.js";

export type ContentCreateInput = Partial<Omit<ContentItem, "id">>;
export type ContentUpdateInput = Partial<Omit<ContentItem, "id">>;
export type GlobalContentCreateInput = Partial<Omit<GlobalContentItem, "id">>;
export type GlobalContentUpdateInput = Partial<Omit<GlobalContentItem, "id">>;

export const contentRepository = {
  list(userId: number): ContentItem[] {
    return store.data.contents[userId] ?? [];
  },

  create(userId: number, input: ContentCreateInput): ContentItem {
    const list = (store.data.contents[userId] ??= []);
    const item: ContentItem = {
      id: nextId(list),
      title: input.title ?? "Untitled",
      type: input.type ?? "post",
      status: input.status ?? "draft",
      created_at: input.created_at ?? new Date().toISOString(),
      media_urls: input.media_urls ?? [],
      post_body: input.post_body ?? null,
      cta_label: input.cta_label ?? null,
      cta_url: input.cta_url ?? null,
      tags: input.tags ?? [],
    };
    list.push(item);
    store.persist();
    return item;
  },

  update(
    userId: number,
    itemId: number,
    patch: ContentUpdateInput,
  ): ContentItem | undefined {
    const list = store.data.contents[userId];
    if (!list) return undefined;
    const idx = list.findIndex((c) => c.id === itemId);
    if (idx === -1) return undefined;
    const existing = list[idx]!;
    const updated: ContentItem = { ...existing, ...patch, id: itemId };
    list[idx] = updated;
    store.persist();
    return updated;
  },

  remove(userId: number, itemId: number): boolean {
    const list = store.data.contents[userId];
    if (!list) return false;
    const before = list.length;
    store.data.contents[userId] = list.filter((c) => c.id !== itemId);
    if (store.data.contents[userId]!.length === before) return false;
    store.persist();
    return true;
  },

  listGlobal(filters?: {
    userId?: number;
    eventId?: number;
  }): GlobalContentItem[] {
    const { userId, eventId } = filters ?? {};
    return store.data.global_contents.filter((item) => {
      if (typeof userId === "number" && item.user_id !== userId) return false;
      if (typeof eventId === "number" && item.event_id !== eventId)
        return false;
      return true;
    });
  },

  createGlobal(input: GlobalContentCreateInput): GlobalContentItem {
    const item: GlobalContentItem = {
      id: nextId(store.data.global_contents),
      title: input.title ?? "Untitled",
      type: input.type ?? "post",
      status: input.status ?? "draft",
      created_at: input.created_at ?? new Date().toISOString(),
      user_id: input.user_id ?? null,
      event_id: input.event_id ?? null,
      media_urls: input.media_urls ?? [],
      post_body: input.post_body ?? null,
      cta_label: input.cta_label ?? null,
      cta_url: input.cta_url ?? null,
      tags: input.tags ?? [],
    };
    store.data.global_contents.push(item);
    store.persist();
    return item;
  },

  updateGlobal(
    itemId: number,
    patch: GlobalContentUpdateInput,
  ): GlobalContentItem | undefined {
    const idx = store.data.global_contents.findIndex((c) => c.id === itemId);
    if (idx === -1) return undefined;
    const existing = store.data.global_contents[idx]!;
    const updated: GlobalContentItem = { ...existing, ...patch, id: itemId };
    store.data.global_contents[idx] = updated;
    store.persist();
    return updated;
  },

  removeGlobal(itemId: number): boolean {
    const before = store.data.global_contents.length;
    store.data.global_contents = store.data.global_contents.filter(
      (c) => c.id !== itemId,
    );
    if (store.data.global_contents.length === before) return false;
    store.persist();
    return true;
  },
};
