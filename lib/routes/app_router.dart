import 'package:go_router/go_router.dart';
import 'package:mediahub/layout/main_layout.dart';
import 'package:mediahub/features/dashboard/pages/dashboard_page.dart';
import 'package:mediahub/features/users/pages/users_page.dart';

class AppRoutes {
  static const dashboard = '/';
  static const users = '/users';
}

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.users,
          builder: (context, state) => const UsersPage(),
        ),
      ],
    ),
  ],
);
