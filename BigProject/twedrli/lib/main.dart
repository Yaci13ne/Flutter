import 'package:flutter/material.dart';
import 'package:twedrli/Pages/Login.dart';
import 'package:twedrli/Pages/SignUp.dart';
import 'package:twedrli/Pages/home.dart';
import 'package:twedrli/fabtab.dart';
import 'package:twedrli/map.dart';
import 'package:twedrli/splash.dart';
import 'package:twedrli/theme/theme_modifier.dart';

// ── Constants ─────────────────────────────────────────────────────────────────
const Color kBlue = Color(0xFF1E9BF0);
const Color kBlueDark = Color(0xFF1578C2);
const Color kBlueBg = Color(0xFFE8F4FD);
const Color kGrey = Color(0xFF8A9BB0);
const Color kInputBg = Color(0xFFF5F8FB);
const Color kBorder = Color(0xFFDDE4ED);

void main() {
  runApp(const TwedrliApp());
}

class TwedrliApp extends StatelessWidget {
  const TwedrliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Twedrli',
          debugShowCheckedModeBanner: false,

          // ─── Light Theme ────────────────────────────────────────────
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF29B6F6),
              brightness: Brightness.light,
            ),
            fontFamily: 'SF Pro Display',
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF4F6F8),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E1E1E),
            ),
          ),

          // ─── Dark Theme ─────────────────────────────────────────────
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF29B6F6),
              brightness: Brightness.dark,
            ),
            fontFamily: 'SF Pro Display',
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
          ),

          themeMode: themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
            '/home': (_) => const FabTabs(),
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ════════════════════════════════════════════════════════════════════════════════

// ─── Logo ─────────────────────────────────────────────────────────────────────
class TwedrliLogo extends StatelessWidget {
  final double size;
  final bool showName;
  const TwedrliLogo({super.key, this.size = 64, this.showName = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Image.asset(
              'assets/logo.png',
              width: size * 4,
              height: size * 4,
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (showName) const SizedBox(height: 8),
      ],
    );
  }
}

class TwedrliLogoColored extends StatelessWidget {
  final double size;
  const TwedrliLogoColored({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size * 1.5,
      height: size * 1.5,
      fit: BoxFit.contain,
    );
  }
}

// ─── Input Field (with password toggle) ──────────────────────────────────────
class TwedrliInput extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const TwedrliInput({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<TwedrliInput> createState() => _TwedrliInputState();
}

class _TwedrliInputState extends State<TwedrliInput> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _hidden,
        keyboardType: widget.keyboardType,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1A2B3C)),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: kGrey, fontSize: 15),
          prefixIcon: Icon(widget.icon, color: kGrey, size: 20),
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    _hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: kGrey,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _hidden = !_hidden),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const PrimaryButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E9BF0), Color(0xFF1578C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E9BF0).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─── Google Button ────────────────────────────────────────────────────────────
class GoogleButton extends StatelessWidget {
  final String label;
  const GoogleButton({super.key, this.label = 'Sign in with Google'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/google.png', width: 22, height: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Or Divider ───────────────────────────────────────────────────────────────
class OrDivider extends StatelessWidget {
  final String text;
  const OrDivider({super.key, this.text = 'Or sign in with'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: kBorder, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: const TextStyle(color: kGrey, fontSize: 13)),
        ),
        const Expanded(child: Divider(color: kBorder, thickness: 1)),
      ],
    );
  }
}
