import { Router } from "express";
import { dashboardRepository } from "../repositories/dashboard.repository.js";

export const dashboardRouter: Router = Router();

dashboardRouter.get("/trend", (_req, res) => {
  res.json(dashboardRepository.trend());
});

dashboardRouter.get("/alerts", (_req, res) => {
  res.json(dashboardRepository.alerts());
});

dashboardRouter.post("/alerts", (req, res) => {
  res.status(201).json(dashboardRepository.addAlert(req.body));
});

dashboardRouter.get("/top-users", (_req, res) => {
  res.json(dashboardRepository.topUsers());
});
