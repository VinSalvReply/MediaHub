import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/features/users/models/user.dart';

/// Visual content shared by the desktop user card.
class UserCardContent extends StatelessWidget {
  final User user;
  final Color color;

  const UserCardContent({super.key, required this.user, required this.color});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = user.isActive ? successColor : dangerColor;
    final String initials = _initialsFor(user);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final _UserCardDimensions dimensions = _UserCardDimensions.fromWidth(
          constraints.maxWidth,
        );

        return Column(
          children: <Widget>[
            // The header remains separate from the profile content so the
            // avatar can overlap it without affecting the grid dimensions.
            _CardHeader(color: color, height: dimensions.headerHeight),
            Transform.translate(
              offset: Offset(0, -dimensions.headerOverlap),
              child: Column(
                children: <Widget>[
                  _Avatar(
                    initials: initials,
                    isActive: user.isActive,
                    color: color,
                    statusColor: statusColor,
                    size: dimensions.avatarSize,
                    radius: dimensions.avatarRadius,
                    fontSize: dimensions.avatarFontSize,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${user.name} ${user.lastName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: dimensions.nameFontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _RoleBadge(
                    role: user.role,
                    color: color,
                    fontSize: dimensions.roleFontSize,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: dimensions.horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _InfoRow(
                          icon: Icons.email_rounded,
                          text: user.email,
                          compact: dimensions.isCompact,
                        ),
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          text:
                              'Creato il ${formatDate(user.createdAt, format: "dd-MM-yyyy")}',
                          compact: dimensions.isCompact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _initialsFor(User user) {
    final String firstInitial = user.name.trim().isNotEmpty
        ? user.name.trim()[0]
        : '';
    final String lastInitial = user.lastName.trim().isNotEmpty
        ? user.lastName.trim()[0]
        : '';
    final String initials = '$firstInitial$lastInitial'.toUpperCase();

    return initials.isEmpty ? '?' : initials;
  }
}

/// Responsive measurements used by the card content.
class _UserCardDimensions {
  static const double _compactBreakpoint = 340;

  final bool isCompact;
  final double headerHeight;
  final double avatarRadius;
  final double avatarSize;
  final double avatarFontSize;
  final double nameFontSize;
  final double roleFontSize;
  final double horizontalPadding;
  final double headerOverlap;

  const _UserCardDimensions._({
    required this.isCompact,
    required this.headerHeight,
    required this.avatarRadius,
    required this.avatarSize,
    required this.avatarFontSize,
    required this.nameFontSize,
    required this.roleFontSize,
    required this.horizontalPadding,
    required this.headerOverlap,
  });

  /// Keeps the card proportions stable when the grid column becomes narrow.
  factory _UserCardDimensions.fromWidth(double width) {
    final bool compact = width < _compactBreakpoint;
    return _UserCardDimensions._(
      isCompact: compact,
      headerHeight: compact ? 95 : 110,
      avatarRadius: compact ? 38 : 43,
      avatarSize: compact ? 96 : 106,
      avatarFontSize: compact ? 24 : 28,
      nameFontSize: compact ? 16 : 18,
      roleFontSize: compact ? 11 : 12,
      horizontalPadding: compact ? 20 : 28,
      headerOverlap: compact ? 48 : 55,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final Color color;
  final double height;

  const _CardHeader({required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final bool isActive;
  final Color color;
  final Color statusColor;
  final double size;
  final double radius;
  final double fontSize;

  const _Avatar({
    required this.initials,
    required this.isActive,
    required this.color,
    required this.statusColor,
    required this.size,
    required this.radius,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        SizedBox(
          width: size,
          height: size,
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: AnimationConfig.statusPulseDuration,
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: isActive ? 10 : 4,
                color: statusColor.withValues(alpha: 0.30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final Color color;
  final double fontSize;

  const _RoleBadge({
    required this.role,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool compact;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: compact ? 13 : 14, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: compact ? 12 : 13, color: greyLight),
          ),
        ),
      ],
    );
  }
}
