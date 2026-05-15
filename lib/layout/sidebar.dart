import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/routes/app_router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 280,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 30,
            offset: Offset(0, 12),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BrandHeader(),
            const SizedBox(height: 24),

            _SidebarTile(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              selected: location == AppRoutes.dashboard,
              onTap: () => context.go(AppRoutes.dashboard),
            ),

            _SidebarTile(
              icon: Icons.people_alt_rounded,
              label: 'Users',
              selected: location == AppRoutes.users,
              onTap: () => context.go(AppRoutes.users),
            ),

            _SidebarTile(
              icon: Icons.event_rounded,
              label: 'Events',
              selected: location == AppRoutes.events,
              onTap: () => context.go(AppRoutes.events),
            ),

            _SidebarTile(
              icon: Icons.layers_rounded,
              label: 'Contents',
              selected: location == AppRoutes.contents,
              onTap: () => context.go(AppRoutes.contents),
            ),

            _SidebarTile(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: location == AppRoutes.profile,
              onTap: () => context.go(AppRoutes.profile),
            ),

            const Spacer(),

            const _SidebarFooter(),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
            ),
          ),
          child: const Icon(Icons.grid_view_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MediaHub',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Admin Console',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;

    final bg = active
        ? const Color(0xFF4F46E5).withValues(alpha: 0.12)
        : hovered
        ? defaultColorLight!.withValues(alpha: 0.1)
        : Colors.transparent;

    final fg = active ? const Color(0xFF4F46E5) : const Color(0xFF111827);

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(widget.icon, color: fg),
          title: Text(
            widget.label,
            style: TextStyle(
              color: fg,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 16, child: Text('A')),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin user',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Live Reply demo',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
