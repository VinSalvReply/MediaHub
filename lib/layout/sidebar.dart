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
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const _ProfilePopupRoute(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF4F46E5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
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
                        'Admin user',
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
                  duration: const Duration(milliseconds: 220),
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
    );
  }
}

class _ProfilePopupRoute extends StatelessWidget {
  const _ProfilePopupRoute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withValues(alpha: 0.46)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Material(
                color: Colors.transparent,
                child: _ProfilePopupCard(
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePopupCard extends StatefulWidget {
  final VoidCallback onClose;

  const _ProfilePopupCard({required this.onClose});

  @override
  State<_ProfilePopupCard> createState() => _ProfilePopupCardState();
}

class _ProfilePopupCardState extends State<_ProfilePopupCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.92,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.08,
          end: 0.98,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.98,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
    ]).animate(controller);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF4F46E5);

    return ScaleTransition(
      scale: scaleAnim,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 36,
              offset: Offset(0, 18),
              color: Color(0x1A000000),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 22, 18, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Hero(
                      tag: 'sidebar-profile-avatar',
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: const Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin user',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Profilo workspace e preferenze operative',
                          style: TextStyle(
                            color: Color(0xFFF5F3FF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7EAF0)),
                    ),
                    child: const Column(
                      children: [
                        _ProfileMetaRow(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Ruolo',
                          value: 'Amministratore',
                        ),
                        SizedBox(height: 12),
                        _ProfileMetaRow(
                          icon: Icons.alternate_email_rounded,
                          label: 'Email',
                          value: 'admin@mediahub.local',
                        ),
                        SizedBox(height: 12),
                        _ProfileMetaRow(
                          icon: Icons.hub_rounded,
                          label: 'Workspace',
                          value: 'Live Reply demo',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Azioni rapide',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _ProfileActionChip(
                          icon: Icons.settings_outlined,
                          label: 'Impostazioni',
                          color: accent,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _ProfileActionChip(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifiche',
                          color: Color(0xFF14B8A6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: accent,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Accedi rapidamente a impostazioni personali, notifiche e contesto del workspace.',
                            style: TextStyle(
                              color: Color(0xFF312E81),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ProfileActionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
