import 'package:flutter/material.dart';
import 'package:mediahub/routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MediaHub',
      routerConfig: router,
    );
  }
}
