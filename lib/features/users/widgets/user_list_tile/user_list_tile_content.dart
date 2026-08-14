import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/users/models/user.dart';

/// Compact visual representation used by the mobile users list.
class UserListTileContent extends StatelessWidget {
  final User user;
  final Color color;
  final bool isHovered;

  const UserListTileContent({
    super.key,
    required this.user,
    required this.color,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = user.isActive ? successColor : dangerColor;

    return AnimatedContainer(
      duration: AnimationConfig.hoverDuration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: surfaceColor,
        border: Border.all(
          color: isHovered ? color.withValues(alpha: 0.3) : borderColor,
          width: isHovered ? 2 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: isHovered ? 12 : 4,
            offset: Offset(0, isHovered ? 4 : 2),
            color: Colors.black.withValues(alpha: isHovered ? 0.08 : 0.04),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _Avatar(
            initials: _initialsFor(user),
            color: color,
            statusColor: statusColor,
            isActive: user.isActive,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _UserInfo(user: user, color: color),
          ),
          AnimatedRotation(
            turns: isHovered ? 0.1 : 0,
            duration: AnimationConfig.hoverDuration,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: color.withValues(alpha: isHovered ? 1 : 0.5),
            ),
          ),
        ],
      ),
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

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final Color statusColor;
  final bool isActive;

  const _Avatar({
    required this.initials,
    required this.color,
    required this.statusColor,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: <Color>[
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: AnimationConfig.statusPulseDuration,
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: isActive ? 6 : 2,
                color: statusColor.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserInfo extends StatelessWidget {
  final User user;
  final Color color;

  const _UserInfo({required this.user, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${user.name} ${user.lastName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            user.role,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: textMutedColor),
        ),
      ],
    );
  }
}
