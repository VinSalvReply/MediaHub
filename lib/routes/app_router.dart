import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mediahub/layout/main_layout.dart';
import 'package:mediahub/features/dashboard/dashboard_page.dart';
import 'package:mediahub/features/events/events_page.dart';
import 'package:mediahub/features/users/users_page.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String users = '/users';
  static const String events = '/events';
}

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          MainLayout(child: child),
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (BuildContext context, GoRouterState state) =>
              const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.users,
          builder: (BuildContext context, GoRouterState state) =>
              const UsersPage(),
        ),
        GoRoute(
          path: AppRoutes.events,
          builder: (BuildContext context, GoRouterState state) =>
              const EventsPage(),
        ),
      ],
    ),
  ],
);
