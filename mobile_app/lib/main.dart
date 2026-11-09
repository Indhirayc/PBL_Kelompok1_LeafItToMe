import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/app/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

// Import file konfigurasi router Anda, misalnya:
// import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase yang sudah berhasil
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan MaterialApp.router agar membaca rute login, register, dan home
    return MaterialApp.router(
      title: 'LeafItToMe',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router, // Sesuaikan dengan variabel GoRouter Anda
    );
  }
}
