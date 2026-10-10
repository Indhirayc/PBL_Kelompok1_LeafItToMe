import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/main_bottom_navigation.dart';
import 'data_inspection_page.dart';
import 'photo_preview_page.dart';

class PhotoSourcePage extends StatefulWidget {
  const PhotoSourcePage({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<PhotoSourcePage> createState() => _PhotoSourcePageState();
}

class _PhotoSourcePageState extends State<PhotoSourcePage> {
  static const Color _background = Color(0xFFFBFCF9);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF718478);
  static const Color _lightGreen = Color(0xFFE8F6E7);

  String? _selectedSource;

  void _selectSource(String source) {
    setState(() {
      _selectedSource = source;
    });
    context.pushNamed(
      'photo-preview',
      extra: InspectionPhotoSelection(draft: widget.draft, source: source),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih sumber gambar daun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _darkGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Ambil foto langsung atau pilih dari galeri\n'
                      'untuk mulai mendeteksi penyakit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildCameraIllustration(),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _SourceOptionCard(
                            key: const Key('cameraSourceButton'),
                            title: 'Buka Kamera',
                            subtitle: 'Ambil foto daun\ntomat sekarang',
                            icon: Icons.photo_camera_outlined,
                            isSelected: _selectedSource == 'Kamera',
                            onTap: () => _selectSource('Kamera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SourceOptionCard(
                            key: const Key('gallerySourceButton'),
                            title: 'Pilih dari Galeri',
                            subtitle: 'Gunakan foto yang\nsudah ada',
                            icon: Icons.photo_library_outlined,
                            isSelected: _selectedSource == 'Galeri',
                            onTap: () => _selectSource('Galeri'),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedSource != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Sumber dipilih: $_selectedSource',
                        key: const Key('selectedPhotoSourceLabel'),
                        style: const TextStyle(
                          color: _darkGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _buildPhotoTips(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: SizedBox(
        height: 48,
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
                      color: _darkGreen,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Text(
                'Deteksi Daun Tomat',
                style: TextStyle(
                  color: _darkGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraIllustration() {
    return SizedBox(
      height: 150,
      child: Image.asset(
        'assets/images/inspection/camera_leaf_illustration.png',
        width: 220,
        fit: BoxFit.contain,
        semanticLabel: 'Ilustrasi kamera untuk foto daun',
      ),
    );
  }

  Widget _buildPhotoTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_objects_outlined, color: _darkGreen, size: 18),
              SizedBox(width: 8),
              Text(
                'Tips foto yang baik',
                style: TextStyle(
                  color: _darkGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _PhotoTip(number: '1', text: 'Gunakan cahaya yang cukup'),
          SizedBox(height: 8),
          _PhotoTip(number: '2', text: 'Ambil satu daun dalam frame'),
          SizedBox(height: 8),
          _PhotoTip(number: '3', text: 'Pastikan gambar terlihat tajam'),
        ],
      ),
    );
  }
}

class _SourceOptionCard extends StatelessWidget {
  const _SourceOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _primaryGreen = Color(0xFF1F7338);
  static const Color _secondaryText = Color(0xFF718478);
  static const Color _border = Color(0xFFDDE5DF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 136,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _primaryGreen : _border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _primaryGreen, size: 27),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF183E2D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 10,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoTip extends StatelessWidget {
  const _PhotoTip({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF477254),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF477254), fontSize: 11),
          ),
        ),
      ],
    );
  }
}
