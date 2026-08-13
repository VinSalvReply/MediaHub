import 'package:flutter/material.dart';
import 'package:mediahub/routes/app_router.dart';

/// A single navigation destination with its icon, display label, and route path.
class NavEntry {
  final IconData icon;
  final String label;
  final String route;

  const NavEntry({
    required this.icon,
    required this.label,
    required this.route,
  });
}

/// Ordered list of all top-level navigation destinations.
const navEntries = <NavEntry>[
  NavEntry(
    icon: Icons.dashboard_rounded,
    label: 'Dashboard',
    route: AppRoutes.dashboard,
  ),
  NavEntry(
    icon: Icons.people_alt_rounded,
    label: 'Utenti',
    route: AppRoutes.users,
  ),
  NavEntry(icon: Icons.event_rounded, label: 'Eventi', route: AppRoutes.events),
];
