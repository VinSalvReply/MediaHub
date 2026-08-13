import 'package:flutter/material.dart';
import 'package:mediahub/routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Hide DEBUG banner
      debugShowCheckedModeBanner: false,
      title: 'MediaHub',
      routerConfig: router,
      builder: (context, child) {
        // Builder's child is nullable per Flutter API contract, though never null in practice
        if (child == null) {
          return const SizedBox.shrink();
        }

        // Override OS-level flags so app animations always run as designed
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations: false,
            accessibleNavigation: false,
          ),
          child: child,
        );
      },
    );
  }
}
