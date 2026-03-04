import 'package:flutter/material.dart';
import 'package:twedrli/fabtab.dart';
import 'package:twedrli/main.dart';

// ════════════════════════════════════════════════════════════════════════════════
// LOGIN SCREEN
// ════════════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username and password.'),
        ),
      );
      return;
    }

    // TODO: replace with your actual auth logic
    // On success → go to home and clear the back stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const FabTabs()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg.png', fit: BoxFit.cover),

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

              // ── Form section ──────────────────────────────────────────
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TwedrliInput(
                        hint: 'Username',
                        icon: Icons.person_outline_rounded,
                        controller: _usernameController,
                      ),
                      const SizedBox(height: 14),
                      TwedrliInput(
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 8),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: navigate to forgot password screen
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: kBlue, fontSize: 13),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      PrimaryButton(label: 'Sign In', onTap: _signIn),
                      const SizedBox(height: 28),
                      const OrDivider(text: 'Or sign in with'),
                      const SizedBox(height: 24),
                      const GoogleButton(label: 'Sign in with Google'),
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
