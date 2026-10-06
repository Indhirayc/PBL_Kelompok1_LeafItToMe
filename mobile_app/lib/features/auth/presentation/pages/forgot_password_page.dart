import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi pengiriman email untuk tahap UI.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
  }

  void _backToLogin() {
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 42),
              _buildLogo(),
              const SizedBox(height: 22),

              const Text(
                'Lupa kata sandi?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF124B35),
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Masukkan email yang terdaftar. Kami akan '
                  'mengirimkan tautan untuk mengatur ulang kata sandimu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF718478),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 38),

              if (!_emailSent)
                _buildEmailForm()
              else
                _buildSuccessContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        InkWell(
          onTap: _backToLogin,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 6,
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF124B35),
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Lupa Kata Sandi',
          style: TextStyle(
            color: Color(0xFF123F2F),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 82,
      height: 82,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8F6E7),
      ),
      child: Image.asset(
        'assets/images/splash/leafittome_logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.eco_rounded,
            color: Color(0xFF1F7338),
            size: 48,
          );
        },
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            key: const Key('forgotPasswordEmailField'),
            controller: _emailController,
            label: 'Email',
            hintText: 'Masukkan email kamu',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: _validateEmail,
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFF1F7338),
              size: 21,
            ),
          ),
          const SizedBox(height: 26),

          AppButton(
            key: const Key('sendResetLinkButton'),
            text: 'Kirim Tautan',
            isLoading: _isLoading,
            onPressed: _sendResetLink,
          ),
          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah ingat kata sandimu? ',
                style: TextStyle(
                  color: Color(0xFF718478),
                  fontSize: 12,
                ),
              ),
              InkWell(
                onTap: _backToLogin,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      color: Color(0xFF1F7338),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6E7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC9E3CD),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: Color(0xFF1F7338),
                size: 48,
              ),
              const SizedBox(height: 14),
              const Text(
                'Tautan berhasil dikirim',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF124B35),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Periksa kotak masuk ${_emailController.text.trim()} '
                'dan ikuti petunjuk untuk mengatur ulang kata sandi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF627A6C),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        AppButton(
          text: 'Kembali ke Login',
          onPressed: _backToLogin,
        ),
        const SizedBox(height: 14),

        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text(
            'Kirim ulang tautan',
            style: TextStyle(
              color: Color(0xFF1F7338),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}