import { nextId } from "../db.js";
import { store } from "../store.js";
import type { User } from "../types.js";

export type UserCreateInput = Partial<Omit<User, "id" | "created_at">>;
export type UserUpdateInput = Partial<Omit<User, "id" | "created_at">>;

export const userRepository = {
  list(): User[] {
    return store.data.users;
  },

  find(id: number): User | undefined {
    return store.data.users.find((u) => u.id === id);
  },

  create(input: UserCreateInput): User {
    const id = nextId(store.data.users);
    const user: User = {
      id,
      name: input.name ?? "",
      last_name: input.last_name ?? "",
      email: input.email ?? `user${id}@mediahub.dev`,
      role: input.role ?? "User",
      segment: input.segment ?? "Casual",
      is_active: input.is_active ?? true,
      created_at: new Date().toISOString(),
      last_login: input.last_login ?? null,
    };
    store.data.users.push(user);
    store.data.activities[id] ??= [];
    store.data.events[id] ??= [];
    store.data.contents[id] ??= [];
    store.persist();
    return user;
  },

  update(id: number, patch: UserUpdateInput): User | undefined {
    const idx = store.data.users.findIndex((u) => u.id === id);
    if (idx === -1) return undefined;
    const existing = store.data.users[idx]!;
    const updated: User = {
      ...existing,
      ...patch,
      id,
      created_at: existing.created_at,
    };
    store.data.users[idx] = updated;
    store.persist();
    return updated;
  },

  remove(id: number): boolean {
    const before = store.data.users.length;
    store.data.users = store.data.users.filter((u) => u.id !== id);
    if (store.data.users.length === before) return false;
    store.data.global_events = store.data.global_events.map((event) =>
      event.user_id === id ? { ...event, user_id: null } : event,
    );
    store.data.global_contents = store.data.global_contents.map((item) =>
      item.user_id === id ? { ...item, user_id: null } : item,
    );
    delete store.data.activities[id];
    delete store.data.events[id];
    delete store.data.contents[id];
    store.persist();
    return true;
  },
};
