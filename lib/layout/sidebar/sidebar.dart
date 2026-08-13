import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/layout/sidebar/nav_entries.dart';
import 'package:mediahub/layout/sidebar/widgets/profile_popup.dart';
import 'package:mediahub/routes/app_router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    String location = AppRoutes.dashboard;
    try {
      location = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      // GoRouter not available in widget tree, use default
    }

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
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BrandHeader(),
            const SizedBox(height: 24),
            ...navEntries.map(
              (entry) => _SidebarTile(
                icon: entry.icon,
                label: entry.label,
                selected: location == entry.route,
                onTap: () => context.go(entry.route),
              ),
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
    final bool active = widget.selected;

    final Color bg = active
        ? const Color(0xFF4F46E5).withValues(alpha: 0.12)
        : hovered
        ? defaultColorLight!.withValues(alpha: 0.1)
        : Colors.transparent;

    final Color fg = active ? const Color(0xFF4F46E5) : const Color(0xFF111827);

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      cursor: SystemMouseCursors.click,
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: AnimationConfig.hoverDuration,
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
      ),
    );
  }
}

class _SidebarFooter extends StatefulWidget {
  const _SidebarFooter();

  @override
  State<_SidebarFooter> createState() => _SidebarFooterState();
}

class _SidebarFooterState extends State<_SidebarFooter> {
  bool hovered = false;

  Future<void> _openProfilePopup() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: AnimationConfig.heroForwardDuration,
        reverseTransitionDuration: AnimationConfig.heroReverseDuration,
        // opaque: false keeps the route transparent so the dimmed backdrop shows.
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ProfilePopupRoute(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF4F46E5);

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: AnimationConfig.hoverDuration,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hovered ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hovered
              ? const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x12000000),
                  ),
                ]
              : const [],
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => hovered = true),
          onExit: (_) => setState(() => hovered = false),
          cursor: SystemMouseCursors.click,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _openProfilePopup,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Hero(
                    tag: 'sidebar-profile-avatar',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: accent.withValues(alpha: 0.12),
                      child: const Text(
                        'A',
                        style: TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Utente Admin',
                          style: TextStyle(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Profilo e impostazioni',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AnimatedSlide(
                    duration: AnimationConfig.hoverDuration,
                    curve: Curves.easeOutCubic,
                    offset: hovered ? const Offset(0.08, 0) : Offset.zero,
                    child: Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: hovered ? accent : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
