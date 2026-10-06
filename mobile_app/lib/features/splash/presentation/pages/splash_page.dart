import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          _progressController.reset();
          _progressController.forward();
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
      body: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widthScale = constraints.maxWidth / 390;
            final heightScale = constraints.maxHeight / 844;

            return Stack(
              fit: StackFit.expand,
              children: [
                const _SplashBackground(),

                // Logo LeafItToMe
                Positioned(
                  top: 105 * heightScale,
                  left: 155 * widthScale,
                  child: Image.asset(
                    'assets/images/splash/leafittome_logo.png',
                    width: 80 * widthScale,
                    height: 80 * heightScale,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),

                // Nama aplikasi
                Positioned(
                  top: 196 * heightScale,
                  left: 0,
                  right: 0,
                  child: Text(
                    'LeafItToMe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0F402B),
                      fontSize: 38 * widthScale,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                ),

                // Tagline
                Positioned(
                  top: 248 * heightScale,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Kenali Daunnya, Jaga Tanamannya',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF40614D),
                      fontSize: 14 * widthScale,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ),

                // Progress bar
                Positioned(
                  top: 758 * heightScale,
                  left: 100 * widthScale,
                  child: _SplashProgressBar(
                    width: 190 * widthScale,
                    height: 6 * heightScale,
                    animation: _progressController,
                  ),
                ),

                // Teks loading
                Positioned(
                  top: 776 * heightScale,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Memuat...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFD0130F),
                      fontSize: 12 * widthScale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/splash/splash_background.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(
          color: Color(0xFFFBFCF6),
          child: Center(
            child: Text(
              'Background splash tidak ditemukan',
              style: TextStyle(
                color: Color(0xFFD0130F),
                fontSize: 13,
              ),
            ),
          ),
        );
      },
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
    return Container(
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
            child: Container(
              width: width * animation.value,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFF23217),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          );
        },
      ),
    );
  }
}