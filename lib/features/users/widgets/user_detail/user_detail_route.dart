import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/user_detail/user_detail.dart';

/// Displays user details in a transparent modal route shared by user views.
class UserDetailRoute extends StatelessWidget {
  final User user;
  final Color color;
  final bool isMobile;
  final bool enableHero;

  const UserDetailRoute({
    super.key,
    required this.user,
    required this.color,
    required this.isMobile,
    this.enableHero = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          ModalBarrier(
            dismissible: true,
            color: Colors.black.withValues(alpha: 0.5),
          ),
          Center(
            child: UserDetail(
              user: user,
              color: color,
              enableHero: enableHero,
              startPulseImmediately: isMobile,
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens [UserDetailRoute] using the same animation timings on all user views.
Future<void> openUserDetail({
  required BuildContext context,
  required User user,
  required Color color,
  bool isMobile = false,
  bool enableHero = false,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: isMobile
          ? Duration.zero
          : AnimationConfig.heroForwardDuration,
      reverseTransitionDuration: isMobile
          ? Duration.zero
          : AnimationConfig.heroReverseDuration,
      opaque: false,
      pageBuilder: (_, _, _) => UserDetailRoute(
        user: user,
        color: color,
        isMobile: isMobile,
        enableHero: enableHero,
      ),
      transitionsBuilder: (_, _, _, Widget child) => child,
    ),
  );
}
