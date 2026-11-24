import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../data/onboarding_slide.dart';
import '../../data/onboarding_storage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.storage, this.replay = false});

  /// Bisa diganti saat pengujian agar tidak menyentuh penyimpanan asli.
  final OnboardingStorage? storage;

  /// Saat `true`, onboarding dipaksa tampil ulang dari halaman lain.
  final bool replay;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const Color _background = Color(0xFFFBFCF6);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _secondaryText = Color(0xFF75857B);
  static const Color _primaryGreen = Color(0xFF2F7D4A);
  static const Color _accentGreen = Color(0xFFE8F5E9);
  static const Color _border = Color(0xFFE3EAE4);

  late final OnboardingStorage _storage;
  late final PageController _pageController;

  bool _ready = false;
  bool _finished = false;
  int _currentPage = 0;

  bool get _isLastPage => _currentPage >= kOnboardingSlides.length - 1;

  @override
  void initState() {
    super.initState();
    _storage = widget.storage ?? const OnboardingStorage();
    _pageController = PageController();

    if (widget.replay) {
      _ready = true;
    } else {
      unawaited(_bootstrap());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // Tunggu frame pertama supaya Navigator dari GoRouter sudah siap.
    await WidgetsBinding.instance.endOfFrame;

    final bool harusDilewati =
        _sudahLogin() || await _storage.hasSeenOnboarding();

    if (!mounted) return;

    if (harusDilewati) {
      _goToSplash();
      return;
    }

    setState(() => _ready = true);
  }

  bool _sudahLogin() {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  void _goToSplash() {
    context.goNamed('splash');
  }

  Future<void> _finish() async {
    if (_finished) return;
    setState(() => _finished = true);

    await _storage.markOnboardingSeen();
    if (!mounted) return;

    if (widget.replay) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed('home');
      }
      return;
    }

    _goToSplash();
  }

  void _next() {
    if (_isLastPage) {
      unawaited(_finish());
      return;
    }

    unawaited(
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _OnboardingBackdrop(),
          AppContentLayout(
            maxWidth: 560,
            child: SafeArea(
              child: _ready ? _buildContent() : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: kOnboardingSlides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _buildSlide(index),
          ),
        ),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _accentGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 18,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              'LeafItToMe',
              style: TextStyle(
                color: _darkGreen,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _isLastPage ? 0 : 1,
              child: IgnorePointer(
                ignoring: _isLastPage,
                child: TextButton(
                  key: const Key('onboardingSkipButton'),
                  onPressed: () => unawaited(_finish()),
                  style: TextButton.styleFrom(
                    foregroundColor: _secondaryText,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    widget.replay ? 'Tutup' : 'Lewati',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(int index) {
    final OnboardingSlide slide = kOnboardingSlides[index];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= kTabletBreakpoint;
        final double heroSize = isTablet
            ? 210
            : (constraints.maxWidth * 0.46).clamp(150.0, 200.0).toDouble();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHero(slide, heroSize),
                const SizedBox(height: 30),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: isTablet ? 28 : 25,
                    fontWeight: FontWeight.w700,
                    height: 1.22,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: Text(
                    slide.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(OnboardingSlide slide, double size) {
    final double ring = size * 1.16;

    return SizedBox(
      width: ring + 24,
      height: ring + 24,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: ring,
            height: ring,
            decoration: BoxDecoration(
              color: _accentGreen.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[_primaryGreen, _darkGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _primaryGreen.withValues(alpha: 0.24),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              size: size * 0.42,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 2,
            right: 4,
            child: _buildHeroChip(
              const Icon(Icons.eco_rounded, size: 20, color: _primaryGreen),
            ),
          ),
          Positioned(
            bottom: 6,
            left: 2,
            child: _buildHeroChip(
              size: 34,
              const Icon(Icons.spa_rounded, size: 16, color: _primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(Widget child, {double size = 44}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          _buildDots(),
          const SizedBox(height: 18),
          AppButton(
            key: const Key('onboardingPrimaryButton'),
            label: _isLastPage
                ? (widget.replay ? 'Selesai' : 'Mulai')
                : 'Lanjut',
            height: 52,
            onPressed: _next,
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < kOnboardingSlides.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _currentPage ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _currentPage ? _primaryGreen : _border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFFFBFCF6), Color(0xFFF4F8F1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -70,
            child: _circle(200, const Color(0xFFE8F5E9), 0.85),
          ),
          Positioned(
            top: 140,
            right: -50,
            child: _circle(130, const Color(0xFFDCEDDD), 0.6),
          ),
          Positioned(
            bottom: 90,
            left: -50,
            child: _circle(150, const Color(0xFFE9F4EC), 0.8),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: _circle(180, const Color(0xFFE3F1E6), 0.7),
          ),
          Positioned(
            top: 96,
            right: 26,
            child: _leaf(Icons.eco_rounded, 30, 0.16, -0.5),
          ),
          Positioned(
            bottom: 190,
            left: 22,
            child: _leaf(Icons.spa_rounded, 24, 0.14, 0.5),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _leaf(IconData icon, double size, double opacity, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        icon,
        size: size,
        color: const Color(0xFF2F7D4A).withValues(alpha: opacity),
      ),
    );
  }
}