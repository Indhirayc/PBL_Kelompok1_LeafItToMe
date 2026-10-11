import 'package:flutter/material.dart';

import 'router/app_router.dart';

class LeafItToMeApp extends StatelessWidget {
  const LeafItToMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LeafItToMe',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
