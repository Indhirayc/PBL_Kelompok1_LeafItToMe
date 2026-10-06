import 'package:flutter/material.dart';

import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  runApp(const LeafItToMeApp());
}

class LeafItToMeApp extends StatelessWidget {
  const LeafItToMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'LeafItToMe',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}