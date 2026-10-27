import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Nama lengkap wajib diisi';
    }

    if (name.length < 3) {
      return 'Nama minimal 3 karakter';
    }

    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }

    if (value != _passwordController.text) {
      return 'Konfirmasi kata sandi tidak sama';
    }

    return null;
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setujui Syarat & Ketentuan dan Kebijakan Privasi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Hubungkan ke Firebase Auth untuk verifikasi email & password
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Simpan nama lengkap langsung dari field nama register ke profil Firebase Auth
      await credential.user?.updateDisplayName(_nameController.text.trim());
      await credential.user?.reload();

      // Simpan dokumen profil awal ke Cloud Firestore
      if (credential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'displayName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;

      // 3. Hanya pindah ke halaman home jika user terautentikasi
      if (credential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.goNamed('home');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // 4. Tangani pesan error spesifik dari Firebase
      String errorMessage = 'Gagal mendaftar. Silakan coba lagi.';

      switch (e.code) {
        case 'weak-password':
          errorMessage =
              'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email sudah terdaftar. Gunakan email lain.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'network-request-failed':
          errorMessage = 'Tidak ada koneksi internet.';
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.goNamed('login');
      }
    }
  }

  void _openLoginPage() {
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCF9),
      body: SafeArea(
        child: AppContentLayout(
          maxWidth: 480,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 12),

                  _buildLogo(),
                  const SizedBox(height: 14),

                  const Text(
                    'Buat akun baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF124B35),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),

                  const Text(
                    'Simpan riwayat dan pantau tanamanmu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF718478),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 27),

                  AppTextField(
                    key: const Key('nameField'),
                    controller: _nameController,
                    label: 'Nama lengkap',
                    hintText: 'Masukkan nama lengkap',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: _validateName,
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF1F7338),
                      size: 21,
                    ),
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    key: const Key('registerEmailField'),
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'nama@email.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      color: Color(0xFF1F7338),
                      size: 21,
                    ),
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    key: const Key('registerPasswordField'),
                    controller: _passwordController,
                    label: 'Kata sandi',
                    hintText: 'Masukkan kata sandi',
                    textInputAction: TextInputAction.next,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF1F7338),
                      size: 21,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Tampilkan kata sandi'
                          : 'Sembunyikan kata sandi',
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF1F7338),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    key: const Key('confirmPasswordField'),
                    controller: _confirmPasswordController,
                    label: 'Konfirmasi kata sandi',
                    hintText: 'Masukkan kembali kata sandi',
                    textInputAction: TextInputAction.done,
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF1F7338),
                      size: 21,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirmPassword
                          ? 'Tampilkan konfirmasi kata sandi'
                          : 'Sembunyikan konfirmasi kata sandi',
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF1F7338),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildAgreement(),
                  const SizedBox(height: 28),

                  AppButton(
                    key: const Key('registerSubmitButton'),
                    label: 'Daftar',
                    isLoading: _isLoading,
                    onPressed: _register,
                  ),
                  const SizedBox(height: 18),

                  _buildLoginPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        InkWell(
          onTap: _openLoginPage,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1F3826),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Daftar Akun',
          style: TextStyle(
            color: Color(0xFF1F3826),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(9),
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
            size: 34,
          );
        },
      ),
    );
  }

  Widget _buildAgreement() {
    return InkWell(
      onTap: () {
        setState(() {
          _agreeToTerms = !_agreeToTerms;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: _agreeToTerms,
              activeColor: const Color(0xFF1F7338),
              checkColor: Colors.white,
              side: const BorderSide(color: Color(0xFF1F7338), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Saya menyetujui Syarat & Ketentuan serta\n'
              'Kebijakan Privasi.',
              style: TextStyle(
                color: Color(0xFF627A6C),
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Sudah memiliki akun? ',
          style: TextStyle(color: Color(0xFF718478), fontSize: 13),
        ),
        InkWell(
          key: const Key('loginButton'),
          onTap: _openLoginPage,
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              'Masuk',
              style: TextStyle(
                color: Color(0xFF2F7D4A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
