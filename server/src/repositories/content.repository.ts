import { nextId } from "../db.js";
import { store } from "../store.js";
import type { ContentItem } from "../types.js";

export type ContentCreateInput = Partial<Omit<ContentItem, "id">>;
export type ContentUpdateInput = Partial<Omit<ContentItem, "id">>;

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
};
