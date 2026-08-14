import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/utils/preserved_tween_animation_builder.dart';

/// Responsive shortcuts for the most common dashboard actions.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_QuickAction> actions = <_QuickAction>[
      _QuickAction(
        'Crea utente',
        'Aggiungi un operatore o un editor',
        Icons.person_add_alt_1_rounded,
        Color(0xFF4F46E5),
      ),
      _QuickAction(
        'Crea evento',
        'Pianifica una nuova diretta o campagna',
        Icons.event_available_rounded,
        Color(0xFF14B8A6),
      ),
      _QuickAction(
        'Aggiungi contenuto',
        'Collega media o post a un evento',
        Icons.upload_rounded,
        Color(0xFFEC4899),
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = width >= 1000
            ? 3
            : width >= 700
            ? 2
            : 1;
        final double aspectRatio = width >= 1000
            ? 3.2
            : width >= 700
            ? 2.5
            : width >= 420
            ? 2.15
            : 1.65;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (BuildContext context, int index) =>
              _QuickActionCard(action: actions[index]),
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final _QuickAction action = widget.action;
    final bool compact = MediaQuery.sizeOf(context).width < 430;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: RepaintBoundary(
        child: PreservedTweenAnimationBuilder(
          begin: 0,
          end: _isHovered ? 1 : 0,
          duration: AnimationConfig.hoverDuration,
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double progress, Widget? child) {
            return Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DashboardColors.subtleSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DashboardColors.border),
                  ),
                  child: child,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: action.color.withValues(alpha: 0.08 * progress),
                        border: Border.all(
                          color: action.color.withValues(
                            alpha: 0.24 * progress,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: _ActionContent(action: action, compact: compact),
        ),
      ),
    );
  }
}

class _ActionContent extends StatelessWidget {
  final _QuickAction action;
  final bool compact;

  const _ActionContent({required this.action, required this.compact});

  @override
  Widget build(BuildContext context) {
    final Widget icon = Container(
      width: compact ? 40 : 44,
      height: compact ? 40 : 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        color: action.color.withValues(alpha: 0.14),
      ),
      child: Icon(action.icon, color: action.color, size: compact ? 20 : null),
    );
    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          action.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          action.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );

    return compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  icon,
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              text,
            ],
          )
        : Row(
            children: <Widget>[
              icon,
              const SizedBox(width: 14),
              Expanded(child: text),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey,
              ),
            ],
          );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _QuickAction(this.title, this.subtitle, this.icon, this.color);
}
