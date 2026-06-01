import { store } from "../store.js";
import type { Activity } from "../types.js";

export type ActivityInput = Partial<Activity>;

export const activityRepository = {
  list(userId: number): Activity[] {
    return store.data.activities[userId] ?? [];
  },

  create(userId: number, input: ActivityInput): Activity {
    const activity: Activity = {
      type: input.type ?? "login",
      description: input.description ?? "",
      entity: input.entity ?? null,
      device: input.device ?? "web",
      date: input.date ?? new Date().toISOString(),
    };
    const list = (store.data.activities[userId] ??= []);
    list.unshift(activity);
    store.persist();
    return activity;
  },
};
