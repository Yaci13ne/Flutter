// ════════════════════════════════════════════════════════════════════════════════
// SIGN UP SCREEN
// ════════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/Login.dart';
import 'package:twedrli/main.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 155, 240),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                
                  ),
                  const SizedBox(height: 24),
                  const TwedrliLogoColored(size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2B3C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create your account',
                    style: TextStyle(fontSize: 14, color: kGrey),
                  ),
                  const SizedBox(height: 28),

                  // Form fields
                  const TwedrliInput(
                    hint: 'Enter your full name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  const TwedrliInput(
                    hint: 'name@university.edu',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // Department dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: kInputBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Row(
                          children: const [
                            Icon(
                              Icons.account_balance_outlined,
                              color: kGrey,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Choose your department',
                              style: TextStyle(color: kGrey, fontSize: 15),
                            ),
                          ],
                        ),
                        items: departements
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF1A2B3C),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const TwedrliInput(
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  const SizedBox(height: 14),
                  const TwedrliInput(
                    hint: '••••••••',
                    icon: Icons.lock_reset_outlined,
                    obscure: true,
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(label: 'Create Account', onTap: () {}),
                  const SizedBox(height: 24),
                  const OrDivider(),
                  const SizedBox(height: 18),
                  const GoogleButton(),
                  const SizedBox(height: 24),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: kGrey, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
