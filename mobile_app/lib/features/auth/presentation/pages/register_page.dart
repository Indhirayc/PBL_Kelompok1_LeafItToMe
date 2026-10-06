import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goNamed('login'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Daftar'),
      ),
      body: const Center(
        child: Text('Halaman daftar akan dibuat selanjutnya'),
      ),
    );
  }
}