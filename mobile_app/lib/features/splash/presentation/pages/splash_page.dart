import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  Timer? _navigationTimer;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFFBFCF6),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _navigationTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          context.goNamed('login');
        }
      },
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFCF6),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SplashBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _SplashContent(
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight,
                  progressAnimation: _progressController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.maxWidth,
    required this.maxHeight,
    required this.progressAnimation,
  });

  final double maxWidth;
  final double maxHeight;
  final Animation<double> progressAnimation;

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = maxWidth > maxHeight;
    final bool isTablet = maxWidth >= 600;
    final bool isShortScreen = maxHeight < 700;

    final double contentWidth = maxWidth.clamp(
      0.0,
      isTablet ? 520.0 : 430.0,
    );

    final double logoSize = _responsiveValue(
      normal: maxWidth * 0.21,
      minimum: isLandscape ? 58 : 72,
      maximum: isTablet ? 112 : 92,
    );

    final double titleFontSize = _responsiveValue(
      normal: maxWidth * 0.097,
      minimum: isLandscape ? 28 : 32,
      maximum: isTablet ? 46 : 40,
    );

    final double taglineFontSize = _responsiveValue(
      normal: maxWidth * 0.036,
      minimum: 12,
      maximum: isTablet ? 17 : 15,
    );

    final double topSpacing = isLandscape
        ? 16
        : _responsiveValue(
            normal: maxHeight * 0.095,
            minimum: 42,
            maximum: isTablet ? 120 : 90,
          );

    final double progressWidth = _responsiveValue(
      normal: contentWidth * 0.49,
      minimum: 170,
      maximum: isTablet ? 230 : 200,
    );

    final double logoToTitleSpacing =
        isShortScreen || isLandscape ? 10 : 14;

    final double titleToTaglineSpacing =
        isShortScreen || isLandscape ? 8 : 12;

    final double bottomSpacing =
        isShortScreen || isLandscape ? 18 : 30;

    return Center(
      child: SizedBox(
        width: contentWidth,
        height: maxHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 24,
          ),
          child: Column(
            children: [
              SizedBox(height: topSpacing),

              // Logo aplikasi
              Semantics(
                image: true,
                label: 'Logo LeafItToMe',
                child: Image.asset(
                  'assets/images/splash/leafittome_logo.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      width: logoSize,
                      height: logoSize,
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF238341),
                        size: 60,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: logoToTitleSpacing),

              // Nama aplikasi
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'LeafItToMe',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: const Color(0xFF0F402B),
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.8,
                  ),
                ),
              ),

              SizedBox(height: titleToTaglineSpacing),

              // Tagline aplikasi
              Text(
                'Kenali Daunnya, Jaga Tanamannya',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: const Color(0xFF40614D),
                  fontSize: taglineFontSize,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),

              // Mendorong indikator loading ke bagian bawah layar
              const Spacer(),

              // Progress bar
              _SplashProgressBar(
                width: progressWidth,
                height: isTablet ? 7 : 6,
                animation: progressAnimation,
              ),

              const SizedBox(height: 12),

              // Teks loading
              Text(
                'Memuat...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFD0130F),
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: bottomSpacing),
            ],
          ),
        ),
      ),
    );
  }

  double _responsiveValue({
    required double normal,
    required double minimum,
    required double maximum,
  }) {
    return normal.clamp(minimum, maximum).toDouble();
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/splash/splash_background.png',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return const ColoredBox(
            color: Color(0xFFFBFCF6),
          );
        },
      ),
    );
  }
}

class _SplashProgressBar extends StatelessWidget {
  const _SplashProgressBar({
    required this.width,
    required this.height,
    required this.animation,
  });

  final double width;
  final double height;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat aplikasi',
      value: 'Sedang berlangsung',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFD6E3D4),
          borderRadius: BorderRadius.circular(height),
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: animation.value,
                heightFactor: 1,
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF23217),
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}