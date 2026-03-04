import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twedrli/Pages/profile.dart';
import 'package:twedrli/fabtab.dart';
import 'package:twedrli/main.dart';


// ════════════════════════════════════════════════════════════════════════════════
// SETUP PROFILE SCREEN
// ════════════════════════════════════════════════════════════════════════════════
class SetupProfileScreen extends StatefulWidget {
  final String fullName; // ✅ add this
  const SetupProfileScreen({super.key, required this.fullName});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _profileImage;
  int _bioLength = 0;
  static const int _maxBio = 150;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(() {
      setState(() => _bioLength = _bioController.text.length);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }
void _completeProfile() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a username.')));
      return;
    }
displayNameNotifier.value = widget.fullName; // ✅ add this line

    // ✅ Push data to global notifiers
    usernameNotifier.value = '@$username';
    if (_profileImage != null) {
      profileImageNotifier.value = _profileImage;
    }

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
          // Background — same blue gradient as the rest of the app
          Image.asset('assets/bg.png', fit: BoxFit.cover),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── App bar row ───────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Setup Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      // Invisible spacer to balance the back button
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // ── Hero text ─────────────────────────────────────────
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Almost there',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Personalize your Twedrli identity',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.80),
                    ),
                  ),
                ),

                // ── Avatar picker ──────────────────────────────────────
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Circle avatar
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD0D8E8), Color(0xFFB0BDD4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white70,
                                  size: 36,
                                )
                              : null,
                        ),

                        // Blue "+" badge
                        Positioned(
                          bottom: 4,
                          right: -2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: kBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Form card ─────────────────────────────────────────
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username label
                        const Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Username field
                        Container(
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
                          child: TextField(
                            controller: _usernameController,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.alternate_email_rounded,
                                color: kGrey,
                                size: 20,
                              ),
                              hintText: 'e.g. futurist_alex',
                              hintStyle: const TextStyle(
                                  color: kGrey, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bio label + counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$_bioLength/$_maxBio',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.70),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Bio field
                        Container(
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
                          child: TextField(
                            controller: _bioController,
                            maxLines: 4,
                            maxLength: _maxBio,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Tell the world who you are...',
                              hintStyle: const TextStyle(
                                  color: kGrey, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                              counterText: '', // hide built-in counter
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Complete Profile button
                        PrimaryButton(
                          label: 'Complete Profile  ›',
                          onTap: _completeProfile,
                        ),

                        const SizedBox(height: 16),

                        // Terms of service note
                        const Center(
                          child: Text(
                            'By finishing, you agree to our Terms of Service',
                            style: TextStyle(
                              color: kGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
