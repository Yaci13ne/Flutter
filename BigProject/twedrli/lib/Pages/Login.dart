// ════════════════════════════════════════════════════════════════════════════════
// LOGIN SCREEN
// ════════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:twedrli/main.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/bg.png', fit: BoxFit.cover),
          // Content
          Column(
            children: [
              // ── Blue top section ──────────────────────────────────────
              Expanded(
                flex: 5,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const TwedrliLogo(size: 70),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Login to your account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Form section (no white card, transparent) ─────────────
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TwedrliInput(
                        hint: 'Username',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      const TwedrliInput(
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(label: 'Sign In', onTap: () {}),
                      const SizedBox(height: 28),
                      const OrDivider(),
                      const SizedBox(height: 24),
                      const GoogleButton(),
                      const SizedBox(height: 40),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: kGrey, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: kBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(color: kGrey, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Terms of Service',
                              style: TextStyle(color: kGrey, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Help Center',
                              style: TextStyle(color: kGrey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Center(
                        child: Text(
                          '© 2026 TWEDRLI CAMPUS INC.',
                          style: TextStyle(
                            color: kGrey,
                            fontSize: 10,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

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
          const Text(
            'Sign up with Google',
            style: TextStyle(
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

// ─── Divider with text ────────────────────────────────────────────────────────
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: kBorder, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or sign in with',
            style: TextStyle(color: kGrey, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: kBorder, thickness: 1)),
      ],
    );
  }
}

// ─── Twedrli Logo ─────────────────────────────────────────────────────────────
class TwedrliLogo extends StatelessWidget {
  final double size;
  final bool showName;
  const TwedrliLogo({super.key, this.size = 64, this.showName = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
        if (showName) ...[const SizedBox(height: 8)],
      ],
    );
  }
}

class TwedrliLogoColored extends StatelessWidget {
  final double size;
  const TwedrliLogoColored({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Center(
            child: Image.asset(
              'assets/logo.png',
              width: size * 1.5,
              height: size * 1.5,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 6),
      
      ],
    );
  }
}

// ─── Shared Input Field ───────────────────────────────────────────────────────
class TwedrliInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1A2B3C)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kGrey, fontSize: 15),
          prefixIcon: Icon(icon, color: kGrey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// ─── Shared Primary Button ────────────────────────────────────────────────────
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
              color: const Color.fromRGBO(30, 155, 240, 1).withOpacity(0.35),
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
