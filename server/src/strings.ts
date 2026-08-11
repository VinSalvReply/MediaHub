import { store } from "./store.js";

function resolvePath(path: string): unknown {
  return path.split(".").reduce<unknown>((acc, key) => {
    if (acc && typeof acc === "object" && key in acc) {
      return (acc as Record<string, unknown>)[key];
    }
    return undefined;
  }, store.data.strings as unknown);
}

export function getString(path: string): string {
  const value = resolvePath(path);
  return typeof value === "string" ? value : "";
}

export function getStringList(path: string): string[] {
  const value = resolvePath(path);
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string")
    : [];
}

export function getStringMap(path: string): Record<string, string> {
  const value = resolvePath(path);
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return {};
  }
  return Object.fromEntries(
    Object.entries(value).filter((entry): entry is [string, string] => {
      return typeof entry[1] === "string";
    }),
  );
}

export function formatString(
  path: string,
  values: Record<string, string | number>,
): string {
  const template = getString(path);
  return Object.entries(values).reduce((text, [key, value]) => {
    return text.split(`{${key}}`).join(String(value));
  }, template);
}
