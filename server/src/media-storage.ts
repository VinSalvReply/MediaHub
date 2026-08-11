import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const mediaDirectory = path.resolve(__dirname, "../media");

export function ensureMediaDirectory(): void {
  fs.mkdirSync(mediaDirectory, { recursive: true });
}

export function buildThumbnailFilename(mediaFilename: string): string {
  const extension = path.extname(mediaFilename);
  const stem =
    extension.length > 0
      ? mediaFilename.slice(0, -extension.length)
      : mediaFilename;
  return `${stem}.poster.jpg`;
}

export function cleanupUnreferencedManagedMedia(
  candidates: readonly string[],
  referencedMediaUrls: readonly string[],
): void {
  const referenced = new Set(referencedMediaUrls);
  const uniqueCandidates = new Set(candidates);

  for (const mediaUrl of uniqueCandidates) {
    if (referenced.has(mediaUrl)) continue;

    const filename = filenameFromManagedMediaUrl(mediaUrl);
    if (filename == null) continue;

    deleteIfExists(path.join(mediaDirectory, filename));
    deleteIfExists(path.join(mediaDirectory, buildThumbnailFilename(filename)));
  }
}

function filenameFromManagedMediaUrl(mediaUrl: string): string | null {
  try {
    const parsed = new URL(mediaUrl);
    if (!parsed.pathname.startsWith("/media/")) {
      return null;
    }

    const filename = parsed.pathname.slice("/media/".length);
    if (!filename || filename.includes("..") || filename.includes("/")) {
      return null;
    }

    return decodeURIComponent(filename);
  } catch {
    return null;
  }
}

function deleteIfExists(filePath: string): void {
  if (!fs.existsSync(filePath)) return;
  fs.unlinkSync(filePath);
}
