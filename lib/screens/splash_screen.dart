import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iqacs/screens/onboarding_screen.dart';

// ─── Brand colours ───────────────────────────────────────────────────────────
const _kLime = Color(0xFFBFFA01);
const _kLimeDark = Color(0xFF8CB800);
const _kBgTop = Color(0xFF0B1C0B);
const _kBgBottom = Color(0xFF0E2A1A);
const _kGlowColor = Color(0x33BFFA01);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _btnCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _shimmerCtrl;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _btnFade;
  late final Animation<double> _btnSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    // ── System UI ──────────────────────────────────────────────────────────
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    // ── Logo: scale + fade ────────────────────────────────────────────────
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    // ── Text: slide-up + fade ─────────────────────────────────────────────
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));

    // ── Button: fade-in + rise ────────────────────────────────────────────
    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _btnFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _btnCtrl, curve: Curves.easeIn));
    _btnSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOutCubic));

    // ── Glow pulse ────────────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.82, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // ── Shimmer on button ─────────────────────────────────────────────────
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    // ── Sequence ──────────────────────────────────────────────────────────
    _logoCtrl.forward().then((_) {
      _textCtrl.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _btnCtrl.forward();
        });
      });
    });

    // ── Auto-navigate ──────────────────────────────────────────────────────
    Timer(const Duration(milliseconds: 3200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, a1, a2, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: a1, curve: Curves.easeIn),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _btnCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
    ));
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 680;

    return Scaffold(
      backgroundColor: _kBgTop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient ──────────────────────────────────────────
          const _GradientBackground(),

          // ── Decorative orbs ─────────────────────────────────────────────
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => _DecorativeOrbs(pulseValue: _pulse.value),
          ),

          // ── Grid lines overlay ───────────────────────────────────────────
          const _GridOverlay(),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.07,
                vertical: isSmall ? 16 : 24,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Logo ──────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, child) => Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(opacity: _logoFade.value, child: child),
                    ),
                    child: _LogoWidget(size: size),
                  ),

                  SizedBox(height: isSmall ? 24 : 36),

                  // ── Text block ────────────────────────────────────────
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: _TextBlock(isSmall: isSmall),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── CTA Button ────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _btnCtrl,
                    builder: (_, child) => Opacity(
                      opacity: _btnFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _btnSlide.value),
                        child: child,
                      ),
                    ),
                    child: _GradientButton(
                      shimmer: _shimmer,
                      onTap: _navigate,
                    ),
                  ),

                  SizedBox(height: isSmall ? 20 : 36),

                  // ── Bottom badge ──────────────────────────────────────
                  FadeTransition(
                    opacity: _btnFade,
                    child: const _BottomBadge(),
                  ),

                  SizedBox(height: isSmall ? 8 : 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background gradient ──────────────────────────────────────────────────────
class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kBgTop, Color(0xFF102010), _kBgBottom],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ─── Decorative glowing orbs ──────────────────────────────────────────────────
class _DecorativeOrbs extends StatelessWidget {
  final double pulseValue;
  const _DecorativeOrbs({required this.pulseValue});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Top-right large orb
        Positioned(
          top: -size.height * 0.08,
          right: -size.width * 0.18,
          child: _Orb(
            radius: size.width * 0.52 * pulseValue,
            color: _kGlowColor.withOpacity(0.18 * pulseValue),
          ),
        ),
        // Bottom-left small orb
        Positioned(
          bottom: size.height * 0.1,
          left: -size.width * 0.22,
          child: _Orb(
            radius: size.width * 0.38 * pulseValue,
            color: _kGlowColor.withOpacity(0.12 * pulseValue),
          ),
        ),
        // Centre micro-orb
        Positioned(
          top: size.height * 0.38,
          left: size.width * 0.62,
          child: _Orb(
            radius: size.width * 0.12,
            color: const Color(0x1ABFFA01),
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double radius;
  final Color color;
  const _Orb({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// ─── Subtle grid overlay ──────────────────────────────────────────────────────
class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08BFFA01)
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

// ─── Logo widget ──────────────────────────────────────────────────────────────
class _LogoWidget extends StatelessWidget {
  final Size size;
  const _LogoWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    final logoSize = math.min(size.width * 0.28, 120.0);
    return Column(
      children: [
        // Glow ring + icon
        Container(
          width: logoSize + 28,
          height: logoSize + 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0x40BFFA01), Colors.transparent],
            ),
            boxShadow: [
              BoxShadow(
                color: _kLime.withOpacity(0.22),
                blurRadius: 40,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: logoSize,
              height: logoSize,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF162416),
                border: Border.all(
                  color: _kLime.withOpacity(0.55),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kLime.withOpacity(0.3),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/coffee-black.png',
                fit: BoxFit.contain,
                color: _kLime,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Text block ───────────────────────────────────────────────────────────────
class _TextBlock extends StatelessWidget {
  final bool isSmall;
  const _TextBlock({required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Chip tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _kLime.withOpacity(0.12),
            border: Border.all(color: _kLime.withOpacity(0.4), width: 1),
          ),
          child: Text(
            'Smart Agriculture System',
            style: GoogleFonts.poppins(
              color: _kLime,
              fontSize: math.min(w * 0.028, 11.5),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
        ),

        SizedBox(height: isSmall ? 12 : 18),

        // Main headline
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFDDFFA0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'IQACS Kopi',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: math.min(w * 0.1, 42.0),
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
        ),

        // Sub-headline with accent colour
        Text(
          'Nursery.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [_kLime, _kLimeDark],
              ).createShader(const Rect.fromLTWH(0, 0, 280, 60)),
            fontSize: math.min(w * 0.145, 62.0),
            fontWeight: FontWeight.w800,
            height: 0.95,
            letterSpacing: -1.0,
          ),
        ),

        SizedBox(height: isSmall ? 10 : 14),

        // Description
        Text(
          'Monitoring & Kontrol Greenhouse\nKopi Secara Cerdas',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.45),
            fontSize: math.min(w * 0.032, 13.5),
            fontWeight: FontWeight.w400,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

// ─── Gradient CTA button ──────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  final Animation<double> shimmer;
  final VoidCallback onTap;
  const _GradientButton({required this.shimmer, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final btnW = math.min(w * 0.72, 320.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: btnW,
          height: 56,
          child: Stack(
            children: [
              // Button body
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [_kLime, Color(0xFF9DD600), _kLimeDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kLime.withOpacity(_pressed ? 0.22 : 0.42),
                      blurRadius: _pressed ? 14 : 28,
                      spreadRadius: _pressed ? 0 : 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              // Shimmer sweep
              AnimatedBuilder(
                animation: widget.shimmer,
                builder: (_, __) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        begin: Alignment(widget.shimmer.value - 0.6, 0),
                        end: Alignment(widget.shimmer.value + 0.6, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.28),
                          Colors.transparent,
                        ],
                      ).createShader(rect),
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Label
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mulai Sekarang',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0B1C0B),
                        fontSize: math.min(w * 0.038, 15.5),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF0B1C0B),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom badge ─────────────────────────────────────────────────────────────
class _BottomBadge extends StatelessWidget {
  const _BottomBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _kLime,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Powered by IQACS Technology',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.28),
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _kLime,
          ),
        ),
      ],
    );
  }
}
