import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/routes/app_router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  bool _isSelected(BuildContext context, String route) {
    final current = GoRouterState.of(context).uri.toString();
    return current == route;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: defaultColor,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            "MediaHub",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          SidebarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            selected: _isSelected(context, AppRoutes.dashboard),
            onTap: () => context.go(AppRoutes.dashboard),
          ),

          SidebarItem(
            icon: Icons.people,
            label: "Users",
            selected: _isSelected(context, AppRoutes.users),
            onTap: () => context.go(AppRoutes.users),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected ? defaultColorLight : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(color: backgroundColor),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
