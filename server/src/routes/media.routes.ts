import { execFile } from "node:child_process";
import { randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";
import { Router, type Request } from "express";
import ffmpegPath from "ffmpeg-static";
import multer from "multer";
import { HttpError, asyncHandler } from "../http.js";
import {
  buildThumbnailFilename,
  ensureMediaDirectory,
  mediaDirectory,
} from "../media-storage.js";
import { getString } from "../strings.js";
const upload = multer({ storage: multer.memoryStorage() });
const execFileAsync = promisify(execFile);
const videoExtensions = new Set([".mp4", ".mov", ".webm", ".m4v"]);

export const mediaRouter: Router = Router();

mediaRouter.post(
  "/upload",
  upload.single("file"),
  asyncHandler(async (req, res) => {
    const file = req.file;
    if (!file || file.buffer.length === 0) {
      throw new HttpError(400, getString("errors.mediaUploadMissingFile"));
    }

    const storedName = buildStoredFilename(file.originalname);
    await persistMedia(file.buffer, storedName);
    const thumbnailName = await createThumbnailIfNeeded(storedName);

    res.status(201).json({
      url: buildMediaUrl(req, storedName),
      thumbnailUrl:
        thumbnailName == null ? null : buildMediaUrl(req, thumbnailName),
    });
  }),
);

mediaRouter.post(
  "/import",
  asyncHandler(async (req, res) => {
    const sourceUrl =
      typeof req.body?.url === "string" ? req.body.url.trim() : "";
    if (sourceUrl.length === 0) {
      throw new HttpError(400, getString("errors.mediaUrlRequired"));
    }

    let remoteUrl: URL;
    try {
      remoteUrl = new URL(sourceUrl);
    } catch {
      throw new HttpError(400, getString("errors.mediaUrlRequired"));
    }

    const response = await fetch(remoteUrl);
    if (!response.ok) {
      throw new HttpError(400, getString("errors.mediaImportFailed"));
    }

    const arrayBuffer = await response.arrayBuffer();
    const bytes = Buffer.from(arrayBuffer);
    if (bytes.length === 0) {
      throw new HttpError(400, getString("errors.mediaImportFailed"));
    }

    const storedName = buildStoredFilename(
      extractFilename(remoteUrl, response.headers.get("content-type")),
    );
    await persistMedia(bytes, storedName);
    const thumbnailName = await createThumbnailIfNeeded(storedName);

    res.status(201).json({
      url: buildMediaUrl(req, storedName),
      thumbnailUrl:
        thumbnailName == null ? null : buildMediaUrl(req, thumbnailName),
    });
  }),
);

function buildMediaUrl(req: Request, filename: string): string {
  return `${req.protocol}://${req.get("host")}/media/${filename}`;
}

async function persistMedia(bytes: Buffer, filename: string): Promise<void> {
  ensureMediaDirectory();
  await writeFile(path.join(mediaDirectory, filename), bytes);
}

async function createThumbnailIfNeeded(
  mediaFilename: string,
): Promise<string | null> {
  if (!ffmpegPath || !isVideoFilename(mediaFilename)) {
    return null;
  }

  const inputPath = path.join(mediaDirectory, mediaFilename);
  const thumbnailFilename = buildThumbnailFilename(mediaFilename);
  const outputPath = path.join(mediaDirectory, thumbnailFilename);

  try {
    await execFileAsync(ffmpegPath, [
      "-y",
      "-ss",
      "00:00:00.200",
      "-i",
      inputPath,
      "-frames:v",
      "1",
      "-vf",
      "scale=320:-1",
      outputPath,
    ]);
    return thumbnailFilename;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error("Failed to generate video thumbnail", error);
    return null;
  }
}

function buildStoredFilename(originalName: string): string {
  const safeBase = path.basename(originalName).replace(/[^a-zA-Z0-9._-]/g, "-");
  const extension = path.extname(safeBase);
  const stem =
    extension.length > 0 ? safeBase.slice(0, -extension.length) : safeBase;
  const normalizedStem = stem.trim().replace(/-+/g, "-") || "media";
  return `${randomUUID()}-${normalizedStem}${normalizeExtension(extension)}`;
}

function extractFilename(remoteUrl: URL, contentType: string | null): string {
  const pathname =
    remoteUrl.pathname.split("/").filter(Boolean).pop() ?? "media";
  const extension = path.extname(pathname);
  if (extension) return pathname;
  return `${pathname}${extensionFromContentType(contentType)}`;
}

function extensionFromContentType(contentType: string | null): string {
  const normalized = contentType?.split(";").at(0)?.trim().toLowerCase();
  switch (normalized) {
    case "image/jpeg":
      return ".jpg";
    case "image/png":
      return ".png";
    case "image/gif":
      return ".gif";
    case "image/webp":
      return ".webp";
    case "video/mp4":
      return ".mp4";
    case "video/webm":
      return ".webm";
    case "video/quicktime":
      return ".mov";
    default:
      return "";
  }
}

function normalizeExtension(extension: string): string {
  return extension ? extension.toLowerCase() : "";
}

function isVideoFilename(filename: string): boolean {
  return videoExtensions.has(path.extname(filename).toLowerCase());
}
