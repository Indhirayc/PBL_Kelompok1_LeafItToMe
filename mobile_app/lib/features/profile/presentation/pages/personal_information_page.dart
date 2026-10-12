import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';

import 'package:go_router/go_router.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: 'Indhira Yuantika Christy');

    _emailController = TextEditingController(text: 'indhira@example.com');

    _phoneController = TextEditingController(text: '081234567890');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Perubahan profil berhasil disimpan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _editProfilePhoto() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _ProfileColors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    color: _ProfileColors.darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _PhotoOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Ambil dari kamera',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _PhotoOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Pilih dari galeri',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileColors.background,

      // Header dibuat sama seperti halaman Daftar Akun.
      appBar: AppBar(
        backgroundColor: _ProfileColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: const SizedBox(
                    width: 32,
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _ProfileColors.darkGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              const Text(
                'Edit Profil',
                style: TextStyle(
                  color: _ProfileColors.darkGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(27, 10, 27, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfilePhoto(),
                const SizedBox(height: 40),
                const Text(
                  'Informasi Pribadi',
                  style: TextStyle(
                    color: _ProfileColors.darkGreen,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Pastikan informasi yang kamu masukkan sudah benar.',
                  style: TextStyle(
                    color: _ProfileColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                _ProfileTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap',
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi.';
                    }

                    if (value.trim().length < 3) {
                      return 'Nama lengkap minimal 3 karakter.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _ProfileTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'nama@email.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Email wajib diisi.';
                    }

                    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                    if (!emailPattern.hasMatch(email)) {
                      return 'Format email belum benar.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _ProfileTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  hintText: 'Masukkan nomor telepon',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveProfile(),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'Nomor telepon wajib diisi.';
                    }

                    if (phone.length < 10 || phone.length > 15) {
                      return 'Nomor telepon harus terdiri dari 10–15 digit.';
                    }

                    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                      return 'Nomor telepon hanya boleh berisi angka.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 29),
                AppButton(
                  label: 'Simpan Perubahan',
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAF3),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD5E9D7), width: 1.2),
              ),
              child: Image.asset(
                'assets/images/splash/leafittome_logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_rounded,
                    color: _ProfileColors.primaryGreen,
                    size: 56,
                  );
                },
              ),
            ),
            Positioned(
              right: -2,
              bottom: 3,
              child: Material(
                color: _ProfileColors.primaryGreen,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _editProfilePhoto,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: _ProfileColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 17),
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: _editProfilePhoto,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Ubah Foto Profil',
                style: TextStyle(
                  color: _ProfileColors.primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?) validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _ProfileColors.darkGreen,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          cursorColor: _ProfileColors.primaryGreen,
          style: const TextStyle(
            color: _ProfileColors.darkGreen,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF9AA9A0),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: _ProfileColors.primaryGreen,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            filled: true,
            fillColor: _ProfileColors.white,
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(
              color: _ProfileColors.primaryGreen,
              width: 1.4,
            ),
            errorBorder: _inputBorder(color: _ProfileColors.error),
            focusedErrorBorder: _inputBorder(
              color: _ProfileColors.error,
              width: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder({
    Color color = _ProfileColors.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  const _PhotoOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F9F4),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(icon, color: _ProfileColors.primaryGreen, size: 22),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  color: _ProfileColors.darkGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class _ProfileColors {
  static const Color background = Color(0xFFFBFCF7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryGreen = Color(0xFF2D8952);
  static const Color darkGreen = Color(0xFF123F2E);
  static const Color secondaryText = Color(0xFF74867C);
  static const Color border = Color(0xFFD7E1D9);
  static const Color error = Color(0xFFD32F2F);
}
