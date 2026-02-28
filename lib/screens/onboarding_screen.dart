import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iqacs/providers/page_provider.dart';
import 'package:iqacs/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLime = Color(0xFFBFFA01);
const _kLimeDark = Color(0xFF8CB800);
const _kBgTop = Color(0xFF0B1C0B);
const _kBgBottom = Color(0xFF0E2A1A);

class OnboardingModel {
  final String image;
  final String tag;
  final String heading;
  final String description;
  final String body;
  final String textButton;

  const OnboardingModel({
    required this.image,
    required this.tag,
    required this.heading,
    required this.description,
    required this.body,
    required this.textButton,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      image: "assets/images/onboarding/onboarding1.png",
      tag: "Selamat Datang",
      heading: "IQACS\nNursery Coffee.",
      description: "Platform pintar untuk mengelola\nnursery kopi Anda.",
      body: "Kelola, pantau, dan optimalkan\npertumbuhan bibit kopi Anda.",
      textButton: "Get Started",
    ),
    OnboardingModel(
      image: "assets/images/onboarding/onboarding2.png",
      tag: "Monitoring Real-time",
      heading: "Temperature\n& Humidity.",
      description: "Monitoring & Controlling.",
      body:
          "Pantau suhu dan kelembapan greenhouse\nsecara real-time dari mana saja.",
      textButton: "Next",
    ),
    OnboardingModel(
      image: "assets/images/onboarding/onboarding3.png",
      tag: "Deteksi Cerdas",
      heading: "Greenhouse\nCoffee.",
      description: "Deteksi Penyakit Dini Bibit Kopi.",
      body:
          "Deteksi penyakit dini pada bibit kopi\ndengan teknologi AI terkini.",
      textButton: "Mulai Sekarang",
    ),
  ];

  late final PageController _pageCtrl;
  bool _pressed = false;

  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  Future<void> _goToLogin(BuildContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (ctx.mounted) {
      Navigator.pushReplacement(
        ctx,
        PageRouteBuilder(
          pageBuilder: (_, a1, a2) =>
              const LoginScreen(title: "Login | IQACS"),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, a1, __, child) =>
              FadeTransition(opacity: a1, child: child),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _pageCtrl = ref.read(pageControllerOnboardingProvider);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(selectedIndexOnboardingProvider);
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 680;

    return FutureBuilder<bool>(
      future: _hasSeenOnboarding(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return const LoginScreen(title: "Login | IQACS");
        }

        return Scaffold(
          backgroundColor: _kBgTop,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── Dark gradient bg ─────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kBgTop, Color(0xFF102010), _kBgBottom],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // ── Grid overlay ──────────────────────────────────────────────
              CustomPaint(painter: _GridPainter()),

              // ── Pages ─────────────────────────────────────────────────────
              Column(
                children: [
                  // Image area (top 52 % of screen)
                  SizedBox(
                    height: size.height * (isSmall ? 0.46 : 0.52),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: _pageCtrl,
                          itemCount: _pages.length,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (i) {
                            ref
                                .read(selectedIndexOnboardingProvider.notifier)
                                .state = i;
                          },
                          itemBuilder: (ctx, i) {
                            return Image.asset(
                              _pages[i].image,
                              fit: BoxFit.cover,
                            ).animate(key: ValueKey(i)).fadeIn(
                                duration: 500.ms, curve: Curves.easeIn);
                          },
                        ),
                        // Gradient fade to bg at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: size.height * 0.18,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xDD0B1C0B),
                                  _kBgBottom,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Skip button top-right
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          right: 20,
                          child: currentIndex < _pages.length - 1
                              ? GestureDetector(
                                  onTap: () => _goToLogin(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black.withOpacity(0.35),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Lewati',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // Page number chip top-left
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _kLime.withOpacity(0.15),
                              border: Border.all(
                                color: _kLime.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '0${currentIndex + 1} / 0${_pages.length}',
                              style: GoogleFonts.poppins(
                                color: _kLime,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content card (bottom 48 %)
                  Expanded(
                    child: _ContentCard(
                      page: _pages[currentIndex],
                      currentIndex: currentIndex,
                      total: _pages.length,
                      isSmall: isSmall,
                      pressed: _pressed,
                      onNext: () async {
                        if (currentIndex < _pages.length - 1) {
                          _pageCtrl.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          await _goToLogin(context);
                        }
                      },
                      onPressedChanged: (v) =>
                          setState(() => _pressed = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Content card ─────────────────────────────────────────────────────────────
class _ContentCard extends StatelessWidget {
  final OnboardingModel page;
  final int currentIndex;
  final int total;
  final bool isSmall;
  final bool pressed;
  final VoidCallback onNext;
  final ValueChanged<bool> onPressedChanged;

  const _ContentCard({
    required this.page,
    required this.currentIndex,
    required this.total,
    required this.isSmall,
    required this.pressed,
    required this.onNext,
    required this.onPressedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.fromLTRB(
        w * 0.07,
        isSmall ? 18 : 24,
        w * 0.07,
        isSmall ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _kLime.withOpacity(0.12),
              border:
                  Border.all(color: _kLime.withOpacity(0.4), width: 1),
            ),
            child: Text(
              page.tag,
              style: GoogleFonts.poppins(
                color: _kLime,
                fontSize: math.min(w * 0.028, 11.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ).animate(key: ValueKey('tag_$currentIndex')).fadeIn(
              duration: 400.ms, curve: Curves.easeOut),

          SizedBox(height: isSmall ? 10 : 14),

          // Heading
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Colors.white, Color(0xFFDDFFA0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(b),
            child: Text(
              page.heading,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: math.min(w * 0.085, 36.0),
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ).animate(key: ValueKey('head_$currentIndex')).slideY(
              begin: 0.3,
              end: 0,
              duration: 450.ms,
              curve: Curves.easeOutCubic).fadeIn(duration: 400.ms),

          SizedBox(height: isSmall ? 6 : 10),

          // Body
          Text(
            page.body,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.48),
              fontSize: math.min(w * 0.032, 13.5),
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ).animate(key: ValueKey('body_$currentIndex')).fadeIn(
              delay: 100.ms, duration: 400.ms),

          const Spacer(),

          // Dot indicators
          Row(
            children: List.generate(total, (i) {
              final active = i == currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 7),
                width: active ? 26.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: active
                      ? const LinearGradient(
                          colors: [_kLime, _kLimeDark],
                        )
                      : null,
                  color: active ? null : Colors.white.withOpacity(0.2),
                ),
              );
            }),
          ),

          SizedBox(height: isSmall ? 14 : 20),

          // CTA button
          _GradientButton(
            label: page.textButton,
            isLast: currentIndex == total - 1,
            pressed: pressed,
            onTap: onNext,
            onPressedChanged: onPressedChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Gradient button ──────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLast;
  final bool pressed;
  final VoidCallback onTap;
  final ValueChanged<bool> onPressedChanged;

  const _GradientButton({
    required this.label,
    required this.isLast,
    required this.pressed,
    required this.onTap,
    required this.onPressedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTapDown: (_) => onPressedChanged(true),
      onTapUp: (_) {
        onPressedChanged(false);
        onTap();
      },
      onTapCancel: () => onPressedChanged(false),
      child: AnimatedScale(
        scale: pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: math.min(w * 0.14, 58.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [_kLime, Color(0xFF9DD600), _kLimeDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _kLime.withOpacity(pressed ? 0.2 : 0.38),
                blurRadius: pressed ? 12 : 24,
                spreadRadius: pressed ? 0 : 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0B1C0B),
                  fontSize: math.min(w * 0.038, 15.5),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLast
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                color: const Color(0xFF0B1C0B),
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Grid overlay painter ─────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x07BFFA01)
      ..strokeWidth = 0.6;
    const step = 42.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
