export type Role = "Admin" | "Editor" | "User";
export type Segment = "Power user" | "Casual" | "Inactive";
export type Device = "web" | "mobile" | "desktop";
export type ActivityType = "login" | "edit" | "upload" | "delete";
export type EventStatus = "upcoming" | "live" | "ended";
export type ContentType = "image" | "video" | "post";
export type ContentStatus = "draft" | "published" | "archived";
export type AlertType = "info" | "warning" | "error" | "success";

export interface User {
  id: number;
  name: string;
  last_name: string;
  email: string;
  role: Role;
  segment: Segment;
  is_active: boolean;
  created_at: string;
  last_login: string | null;
}

export interface Activity {
  type: ActivityType;
  description: string;
  entity: string | null;
  device: Device;
  date: string;
}

export interface UserEvent {
  id: number;
  title: string;
  date: string;
  attendees: number;
  status: EventStatus;
}

export interface GlobalEvent extends UserEvent {
  user_id: number | null;
}

export interface ContentItem {
  id: number;
  title: string;
  type: ContentType;
  status: ContentStatus;
  created_at: string;
}

export interface GlobalContentItem extends ContentItem {
  user_id: number | null;
  event_id: number | null;
}

export interface TrendPoint {
  date: string;
  active_users: number;
  content_created: number;
}

export interface Alert {
  type: AlertType;
  message: string;
}

export interface TopUser {
  name: string;
  score: number;
}

export interface Database {
  users: User[];
  activities: Record<number, Activity[]>;
  events: Record<number, UserEvent[]>;
  global_events: GlobalEvent[];
  contents: Record<number, ContentItem[]>;
  global_contents: GlobalContentItem[];
  trend: TrendPoint[];
  alerts: Alert[];
  topUsers: TopUser[];
}
