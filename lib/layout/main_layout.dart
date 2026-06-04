import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediahub/layout/sidebar.dart';
import 'package:mediahub/routes/app_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  static const _mobileBreakpoint = 768.0;

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.dashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_rounded),
              title: const Text('Users'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.users);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_rounded),
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.events);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _mobileBreakpoint;

        return Scaffold(
          body: Row(
            children: [
              if (!isMobile) const Sidebar(),
              Expanded(child: child),
            ],
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  onPressed: () => _showMobileMenu(context),
                  child: const Icon(Icons.menu),
                )
              : null,
        );
      },
    );
  }
}
