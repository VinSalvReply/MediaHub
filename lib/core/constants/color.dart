import 'package:flutter/material.dart';

const Color appBackgroundColor = Color(0xFFF5F7FB);
const Color surfaceColor = Colors.white;
const Color borderColor = Color(0xFFE7EAF0);
const Color textPrimaryColor = Color(0xFF111827);
const Color textMutedColor = Color(0xFF6B7280);
const Color textSubtleColor = Color(0xFF9CA3AF);

const Color primaryColor = Color(0xFF4F46E5);
const Color successColor = Color(0xFF14B8A6);
const Color accentPinkColor = Color(0xFFEC4899);
const Color warningColor = Color(0xFFF59E0B);
const Color dangerColor = Color(0xFFEF4444);

const Color defaultColor = Color(0xFF263238);
const Color defaultColorLight = Color(0xFF455A64);

const Color greyLight = Color(0xFF616161);

// Dashboard-specific colors shared by its extracted widgets.
const Color dashboardSubtleSurfaceColor = Color(0xFFF8FAFC);
const Color dashboardActivitySurfaceColor = Color(0xFFFDFDFE);
const Color dashboardNeutralColor = Color(0xFF64748B);
const Color dashboardSkeletonColor = Color(0xFFE6E6E6);
const Color dashboardPublishedColor = Color(0xFF22C55E);
const Color dashboardSoftShadowColor = Color(0x08000000);
const Color dashboardMediumShadowColor = Color(0x12000000);

// Shared color for event surfaces.
const Color eventDropActiveSurfaceColor = Color(0xFFEEF2FF);
const Color eventCardShadowColor = Color(0x0A000000);
const Color eventContentAccentColor = Color(0xFFBE185D);
const Color eventInputSurfaceColor = Color(0xFFFAFAFA);
const Color eventAssignedBorderColor = Color(0xFFE5E7EB);
const Color eventSheetDividerColor = Color(0xFFF3F4F6);
const Color eventSheetTitleColor = Color(0xFF1F2937);
const Color eventSheetShadowColor = Color(0x15000000);

// Content management colors.
const Color contentDropSurfaceColor = Color(0xFFFFF7ED);
const Color contentDropBorderColor = Color(0xFFF59E0B);
const Color contentDropIconColor = Color(0xFFB45309);
const Color contentUnassignSurfaceColor = Color(0xFFFFEDD5);
const Color contentUnassignActiveColor = Color(0xFFEA580C);
const Color contentUnassignTextColor = Color(0xFF7C2D12);
const Color contentMediaSurfaceColor = Color(0xFFF9FAFB);
const Color contentMediaBorderColor = Color(0xFFE5E7EB);
const Color contentOverlayColor = Color(0xAA111827);
const Color contentDividerColor = Color(0xFFF3F4F6);
const Color contentTagForegroundColor = Color(0xFF0F766E);
const Color contentEventForegroundColor = Color(0xFFB45309);
const Color contentMediaColor = Color(0xFF0EA5E9);
const Color contentMediaForegroundColor = Color(0xFF0369A1);
const Color contentTagColor = Color(0xFF10B981);
const Color contentTagTextColor = Color(0xFF047857);
const Color contentPreviewBorderColor = Color(0xFFE5E7EB);
const Color contentPreviewSurfaceColor = Color(0xFFF9FAFB);
const Color contentScrimColor = Color(0x33000000);

/// Semantic aliases used by dashboard widgets.
abstract final class DashboardColors {
  static const Color border = borderColor;
  static const Color mutedText = textMutedColor;
  static const Color subtleSurface = dashboardSubtleSurfaceColor;
  static const Color activitySurface = dashboardActivitySurfaceColor;
  static const Color neutral = dashboardNeutralColor;
  static const Color primaryText = textPrimaryColor;
  static const Color secondaryText = textSubtleColor;
  static const Color skeleton = dashboardSkeletonColor;
  static const Color activeUsers = primaryColor;
  static const Color contentCreated = accentPinkColor;
  static const Color live = dangerColor;
  static const Color event = warningColor;
  static const Color media = successColor;
  static const Color published = dashboardPublishedColor;
  static const Color softShadow = dashboardSoftShadowColor;
  static const Color mediumShadow = dashboardMediumShadowColor;
}

const List<Color> cardColors = <Color>[
  Color(0xFF1B5E20),
  Color(0xFF4A148C),
  Color(0xFFBF360C),
  Color(0xFFB71C1C),
];
