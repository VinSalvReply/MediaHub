import { Router } from "express";
import { store } from "../store.js";

export const adminRouter: Router = Router();

adminRouter.post("/reseed", (_req, res) => {
  store.reset();
  res.json({ ok: true, users: store.data.users.length });
});
