import { store } from "../store.js";
import type { Alert, TopUser, TrendPoint } from "../types.js";

export const dashboardRepository = {
  trend(): TrendPoint[] {
    return store.data.trend;
  },

  alerts(): Alert[] {
    return store.data.alerts;
  },

  topUsers(): TopUser[] {
    return store.data.topUsers;
  },

  addAlert(input: Partial<Alert>): Alert {
    const alert: Alert = {
      type: input.type ?? "info",
      message: input.message ?? "",
    };
    store.data.alerts.push(alert);
    store.persist();
    return alert;
  },
};
