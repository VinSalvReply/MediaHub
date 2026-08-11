import { store } from "../store.js";
import { getString } from "../strings.js";
import type { Activity } from "../types.js";

export type ActivityInput = Partial<Activity>;

export const activityRepository = {
  list(userId: number): Activity[] {
    return store.data.activities[userId] ?? [];
  },

  create(userId: number, input: ActivityInput): Activity {
    const activity: Activity = {
      type: input.type ?? store.data.strings.defaults.activityType,
      description:
        input.description ?? getString("defaults.activityDescription"),
      entity: input.entity ?? null,
      device: input.device ?? store.data.strings.defaults.device,
      date: input.date ?? new Date().toISOString(),
    };
    const list = (store.data.activities[userId] ??= []);
    list.unshift(activity);
    store.persist();
    return activity;
  },
};
