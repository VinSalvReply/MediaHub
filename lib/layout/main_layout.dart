import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:go_router/go_router.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/layout/sidebar/nav_entries.dart';
import 'package:mediahub/layout/sidebar/sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isMobile =
            constraints.maxWidth < ResponsiveBreakpoints.mobile;

        return Scaffold(
          body: Row(
            children: <Widget>[
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

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        color: surfaceColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: navEntries
              .map(
                (NavEntry entry) => ListTile(
                  leading: Icon(entry.icon),
                  title: Text(entry.label),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(entry.route);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
