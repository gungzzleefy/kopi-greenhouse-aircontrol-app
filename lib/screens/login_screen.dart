import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iqacs/providers/input_provider.dart';
import 'package:iqacs/providers/login_provider.dart';
import 'package:iqacs/screens/forgot_password_screen.dart';
import 'package:iqacs/screens/page_screen.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Brand tokens (light theme) ─────────────────────────────────────────────
const _kGreen = Color(0xFF1B6B3A);
const _kGreenMid = Color(0xFF2D9B4E);
const _kGreenLight = Color(0xFF42A510);
const _kBgTop = Color(0xFFF4F9F5);
const _kBgBottom = Color(0xFFE8F5EC);
const _kSurface = Colors.white;
const _kText = Color(0xFF1A2E1A);
const _kTextSub = Color(0xFF4A6B52);
const _kBorder = Color(0xFFBDD9C5);

class LoginScreen extends ConsumerStatefulWidget {
  final String title;

  const LoginScreen({super.key, required this.title});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  bool _loginPressed = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeIn)));
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.25), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)));

    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeIn)));
    _cardSlide = Tween<Offset>(
            begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic)));

    _entryCtrl.forward();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      await ref.read(loginProvider.notifier).loginWithStoredToken(token);
      if (mounted && ref.read(loginProvider) is AsyncData) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PageScreen()),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    final phone = ref.read(phoneControllerProvider).text;
    final password = ref.read(passwordControllerProvider).text;

    if (phone.isEmpty || password.isEmpty) {
      _showSnack('Identifier dan password tidak boleh kosong!');
      return;
    }

    await ref.read(loginProvider.notifier).login(phone, password);
    final resp = ref.read(loginProvider);

    if (resp.hasValue) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PageScreen()),
        );
      }
    } else if (resp.hasError) {
      String msg = resp.error.toString();
      if (msg.contains('Username pengguna tidak ditemukan')) {
        msg = 'Pengguna tidak ditemukan!';
      } else if (msg.contains('Password anda salah')) {
        msg = 'Password salah!';
      }
      if (mounted) _showSnack(msg);
    }
  }

  void _showSnack(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Kesalahan',
        message: message,
        contentType: ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 680;
    final phoneController = ref.watch(phoneControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final loginResponse = ref.watch(loginProvider);
    final obscure = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      backgroundColor: _kBgTop,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ───────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kBgTop, Color(0xFFF0F7F2), _kBgBottom],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Grid overlay ─────────────────────────────────────────────────
          CustomPaint(painter: _GridPainter()),

          // ── Decorative orbs ──────────────────────────────────────────────
          Positioned(
            top: -size.height * 0.06,
            right: -size.width * 0.15,
            child: _Orb(
              radius: size.width * 0.55,
              color: _kGreen.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: size.height * 0.05,
            left: -size.width * 0.2,
            child: _Orb(
              radius: size.width * 0.4,
              color: _kGreenMid.withOpacity(0.07),
            ),
          ),

          // ── Scrollable body ───────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.07,
                vertical: isSmall ? 16 : 28,
              ),
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  SlideTransition(
                    position: _headerSlide,
                    child: FadeTransition(
                      opacity: _headerFade,
                      child: _Header(size: size, isSmall: isSmall),
                    ),
                  ),

                  SizedBox(height: isSmall ? 24 : 36),

                  // ── Form card ────────────────────────────────────────────
                  SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: _FormCard(
                        size: size,
                        isSmall: isSmall,
                        phoneController: phoneController,
                        passwordController: passwordController,
                        obscure: obscure,
                        isLoading: loginResponse.isLoading,
                        loginPressed: _loginPressed,
                        onToggleObscure: () {
                          ref
                              .read(passwordVisibilityProvider.notifier)
                              .state = !obscure;
                        },
                        onForgotPassword: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()),
                        ),
                        onLogin: () async {
                          setState(() => _loginPressed = true);
                          await _handleLogin();
                          if (mounted) {
                            setState(() => _loginPressed = false);
                          }
                        },
                        onLoginPressedChanged: (v) =>
                            setState(() => _loginPressed = v),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmall ? 16 : 28),

                  // ── Footer ───────────────────────────────────────────────
                  FadeTransition(
                    opacity: _cardFade,
                    child: const _Footer(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final Size size;
  final bool isSmall;
  const _Header({required this.size, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final logoSize = math.min(size.width * 0.22, 90.0);

    return Column(
      children: [
        // Logo ring
        Container(
          width: logoSize + 24,
          height: logoSize + 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [_kGreen.withOpacity(0.12), Colors.transparent],
            ),
            boxShadow: [
              BoxShadow(
                color: _kGreen.withOpacity(0.14),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: logoSize,
              height: logoSize,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: _kGreen.withOpacity(0.4),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/coffee-black.png',
                fit: BoxFit.contain,
                color: _kGreen,
              ),
            ),
          ),
        ),

        SizedBox(height: isSmall ? 16 : 22),

        // Tag chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _kGreen.withOpacity(0.08),
            border: Border.all(color: _kGreen.withOpacity(0.3), width: 1),
          ),
          child: Text(
            'Smart Agriculture System',
            style: GoogleFonts.poppins(
              color: _kGreen,
              fontSize: math.min(size.width * 0.027, 11.0),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
            ),
          ),
        ),

        SizedBox(height: isSmall ? 10 : 14),

        // Title
        Text(
          'Masuk Akun',
          style: GoogleFonts.poppins(
            color: _kText,
            fontSize: math.min(size.width * 0.088, 38.0),
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'IQACS Kopi Nursery',
          style: GoogleFonts.poppins(
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [_kGreen, _kGreenLight],
              ).createShader(const Rect.fromLTWH(0, 0, 220, 30)),
            fontSize: math.min(size.width * 0.048, 20.0),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Form card ────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final Size size;
  final bool isSmall;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscure;
  final bool isLoading;
  final bool loginPressed;
  final VoidCallback onToggleObscure;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final ValueChanged<bool> onLoginPressedChanged;

  const _FormCard({
    required this.size,
    required this.isSmall,
    required this.phoneController,
    required this.passwordController,
    required this.obscure,
    required this.isLoading,
    required this.loginPressed,
    required this.onToggleObscure,
    required this.onForgotPassword,
    required this.onLogin,
    required this.onLoginPressedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 20 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _kSurface,
        border: Border.all(
          color: _kBorder.withOpacity(0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withOpacity(0.07),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identifier field
          _FieldLabel(label: 'Nomor / Username'),
          const SizedBox(height: 8),
          _ModernTextField(
            controller: phoneController,
            hintText: 'contoh: 08xxxxxxxxxx',
            keyboardType: TextInputType.text,
            prefixIcon: Icons.person_outline_rounded,
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.08, end: 0),

          SizedBox(height: isSmall ? 14 : 18),

          // Password field
          _FieldLabel(label: 'Password'),
          const SizedBox(height: 8),
          _ModernTextField(
            controller: passwordController,
            hintText: 'Masukkan password Anda',
            keyboardType: TextInputType.visiblePassword,
            obscureText: obscure,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            onSuffixTap: onToggleObscure,
          ).animate().fadeIn(duration: 500.ms, delay: 80.ms).slideX(begin: -0.08, end: 0),

          const SizedBox(height: 10),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onForgotPassword,
              child: Text(
                'Lupa Password?',
                style: GoogleFonts.poppins(
                  color: _kGreen,
                  fontSize: math.min(size.width * 0.032, 13.0),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: _kGreen,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 140.ms),

          SizedBox(height: isSmall ? 20 : 26),

          // Login button
          _LoginButton(
            isLoading: isLoading,
            pressed: loginPressed,
            size: size,
            onTap: onLogin,
            onPressedChanged: onLoginPressedChanged,
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.12, end: 0),
        ],
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: _kTextSub,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ─── Modern text field ────────────────────────────────────────────────────────
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  const _ModernTextField({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      cursorColor: _kGreen,
      style: GoogleFonts.poppins(
        color: _kText,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: _kTextSub.withOpacity(0.45),
          fontSize: 13,
        ),
        filled: true,
        fillColor: const Color(0xFFF6FBF7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: Icon(prefixIcon, color: _kGreen.withOpacity(0.5), size: 20),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon,
                    color: _kGreen.withOpacity(0.5), size: 20),
                onPressed: onSuffixTap,
                splashRadius: 20,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _kBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _kBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kGreen, width: 1.6),
        ),
      ),
    );
  }
}

// ─── Login button ─────────────────────────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final bool pressed;
  final Size size;
  final VoidCallback onTap;
  final ValueChanged<bool> onPressedChanged;

  const _LoginButton({
    required this.isLoading,
    required this.pressed,
    required this.size,
    required this.onTap,
    required this.onPressedChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          height: math.min(size.width * 0.135, 56.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [_kGreen, _kGreenMid, _kGreenLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _kGreen.withOpacity(pressed ? 0.18 : 0.32),
                blurRadius: pressed ? 10 : 20,
                spreadRadius: pressed ? 0 : 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Masuk Akun',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: math.min(size.width * 0.038, 15.5),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.login_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _kGreen,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Powered by IQACS Technology',
          style: GoogleFonts.poppins(
            color: _kTextSub.withOpacity(0.45),
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _kGreen,
          ),
        ),
      ],
    );
  }
}

// ─── Decorative orb ───────────────────────────────────────────────────────────
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
      ..color = const Color(0x221B6B3A)
      ..strokeWidth = 1.0;
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
