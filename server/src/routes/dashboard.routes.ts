import { Router } from "express";
import { dashboardRepository } from "../repositories/dashboard.repository.js";

export const dashboardRouter: Router = Router();

dashboardRouter.get("/", (_req, res) => {
  res.json(dashboardRepository.getDashboard());
});

dashboardRouter.post("/alerts", (req, res) => {
  res.status(201).json(dashboardRepository.addAlert(req.body));
});
