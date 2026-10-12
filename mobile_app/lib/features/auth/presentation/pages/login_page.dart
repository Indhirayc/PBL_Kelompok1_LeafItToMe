import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/auth_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email wajib diisi';
    }

    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }

    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }

    return null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi proses login untuk tahap UI.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form login berhasil divalidasi'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.goNamed('home');
  }

  void _forgotPassword() {
    context.goNamed('forgot-password');
  }

  void _openRegisterPage() {
    context.goNamed('register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AuthHeader(
                  title: 'Selamat datang kembali',
                  subtitle:
                      'Masuk untuk menyimpan dan memantau\n'
                      'riwayat kesehatan tanamanmu.',
                ),
                const SizedBox(height: 45),

                AppTextField(
                  key: const Key('emailField'),
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Masukkan email kamu',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: Color(0xFF1F7338),
                    size: 21,
                  ),
                ),
                const SizedBox(height: 20),

                AppTextField(
                  key: const Key('passwordField'),
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  hintText: 'Masukkan kata sandi',
                  textInputAction: TextInputAction.done,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF1F7338),
                    size: 21,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF718478),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2F7D4A),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.padded,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Lupa kata sandi?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                AppButton(
                  key: const Key('loginButton'),
                  label: 'Masuk',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: Color(0xFF597361), fontSize: 13),
                    ),
                    TextButton(
                      key: const Key('registerButton'),
                      onPressed: _openRegisterPage,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2F7D4A),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.padded,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Daftar sekarang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFDDE5DF))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'LeafItToMe',
                        style: TextStyle(
                          color: Color(0xFF8A9B90),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFDDE5DF))),
                  ],
                ),
                const SizedBox(height: 18),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_done_outlined,
                      size: 16,
                      color: Color(0xFF718478),
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Data tersimpan aman di akunmu',
                      style: TextStyle(color: Color(0xFF718478), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
