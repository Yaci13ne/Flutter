import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:twedrli/Lists/list.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http
          .post(
            Uri.parse('https://twedrliapi.linguaflo.me/auth/signin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final user = data['user'] as Map<String, dynamic>;

  loggedInUserIdNotifier.value = user['id'] as int;
        loggedInUserNameNotifier.value = user['name'] as String? ?? '';
        loggedInDepartmentNotifier.value = user['department'] as String? ?? '';
        loggedInTokenNotifier.value = data['token'] as String? ?? '';
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const FabTabs()),
            (route) => false,
          );
        }
      } else {
        final msg = data['message'] ?? data['error'] ?? 'Login failed.';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not connect: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      TwedrliInput(
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: kBlue, fontSize: 13),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _isSubmitting
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(label: 'Sign In', onTap: _signIn),

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
