import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/setup_profile_screen.dart';
import 'package:twedrli/fabtab.dart';
import 'package:twedrli/main.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SIGNUP SCREEN
// ════════════════════════════════════════════════════════════════════════════════
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _selectedDepartment;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Creates a badges row for the newly registered user.
  /// All 29 badges default to false on the server — just send user_id.
  Future<void> _createBadgesRow(int userId) async {
    try {
      final res = await http
          .post(
            Uri.parse('https://twedrliapi.linguaflo.me/badges'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint('POST /badges → ${res.statusCode}: ${res.body}');
    } catch (e) {
      debugPrint('Could not create badges row: $e');
    }
  }

  Future<void> _signUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        _selectedDepartment == null ||
        password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http
          .post(
            Uri.parse('https://twedrliapi.linguaflo.me/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': fullName,
              'email': email,
              'password': password,
              'department': _selectedDepartment,
              'img_url': '',
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userId = data['userId'] as int;

        // Save user info globally
        loggedInUserIdNotifier.value = userId;
        loggedInUserNameNotifier.value = fullName;

        // Create the badges row for this new user (fire and don't await on UI)
        await _createBadgesRow(userId);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SetupProfileScreen(fullName: fullName),
            ),
          );
        }
      } else {
        final msg = data['message'] ?? data['error'] ?? 'Registration failed.';
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
              Expanded(
                flex: 4,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const TwedrliLogo(size: 60),
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create your account',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 9,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                  child: Column(
                    children: [
                      TwedrliInput(
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        controller: _fullNameController,
                      ),
                      const SizedBox(height: 14),
                      TwedrliInput(
                        hint: 'name@university.edu',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _DepartmentDropdown(
                        value: _selectedDepartment,
                        departments: departements,
                        onChanged: (val) =>
                            setState(() => _selectedDepartment = val),
                      ),
                      const SizedBox(height: 14),
                      TwedrliInput(
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 14),
                      TwedrliInput(
                        hint: 'Confirm Password',
                        icon: Icons.lock_reset_outlined,
                        obscure: true,
                        controller: _confirmController,
                      ),
                      const SizedBox(height: 28),

                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : PrimaryButton(
                              label: 'Create Account',
                              onTap: _signUp,
                            ),

                      const SizedBox(height: 28),
                      const OrDivider(text: 'Or sign in with'),
                      const SizedBox(height: 24),
                      const GoogleButton(label: 'Sign up with Google'),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: kGrey, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: kBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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

// ════════════════════════════════════════════════════════════════════════════════
// DEPARTMENT DROPDOWN
// ════════════════════════════════════════════════════════════════════════════════
class _DepartmentDropdown extends StatelessWidget {
  const _DepartmentDropdown({
    required this.value,
    required this.departments,
    required this.onChanged,
  });

  final String? value;
  final List<String> departments;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kGrey),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.account_balance_outlined,
            color: kBlue,
            size: 20,
          ),
          hintText: 'Choose your department',
          hintStyle: const TextStyle(color: kGrey, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        items: departments
            .map(
              (dept) => DropdownMenuItem(
                value: dept,
                child: Text(
                  dept,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
