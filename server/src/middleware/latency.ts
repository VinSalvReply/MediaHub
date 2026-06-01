import type { NextFunction, Request, Response } from "express";

/**
 * Aggiunge una latenza artificiale (in ms) ad ogni risposta per simulare
 * un backend reale. Configurabile con env `LATENCY_MIN_MS` / `LATENCY_MAX_MS`.
 * Disattivabile esportando `LATENCY_MAX_MS=0`.
 */
export function artificialLatency(
  minMs = Number(process.env.LATENCY_MIN_MS ?? 1000),
  maxMs = Number(process.env.LATENCY_MAX_MS ?? 2000),
) {
  return (_req: Request, _res: Response, next: NextFunction): void => {
    if (maxMs <= 0) return next();
    const lo = Math.max(0, Math.min(minMs, maxMs));
    const hi = Math.max(lo, maxMs);
    const delay = lo + Math.floor(Math.random() * (hi - lo + 1));
    setTimeout(next, delay);
  };
}
