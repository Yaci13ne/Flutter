import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/profile.dart';
import 'package:twedrli/badge_service.dart';
import 'package:twedrli/fabtab.dart';
import 'package:twedrli/main.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SETUP PROFILE SCREEN
// ════════════════════════════════════════════════════════════════════════════════
class SetupProfileScreen extends StatefulWidget {
  final String fullName;
  const SetupProfileScreen({super.key, required this.fullName});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
Uint8List? _profileImage;
  int _bioLength = 0;
  bool _isSaving = false;
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
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 400,
      maxHeight: 400,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes(); // ← read as bytes
      setState(() => _profileImage = bytes);
    }
  }

  Future<String?> _encodeImage(Uint8List bytes) async {
    try {
      final b64 = base64Encode(bytes);
      return 'data:image/jpeg;base64,$b64';
    } catch (e) {
      debugPrint('Profile image encode error: $e');
      return null;
    }
  }

  /// Save profile image (and any other profile fields) to the users table
  Future<void> _saveProfileToApi(String imgUrl) async {
    final userId = loggedInUserIdNotifier.value;
    if (userId == null) return;
    try {
      final res = await http
          .put(
            Uri.parse('https://twedrliapi.linguaflo.me/users/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'img_url': imgUrl}),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('Profile img saved: ${res.statusCode}');
    } catch (e) {
      debugPrint('Could not save profile image: $e');
    }
  }

  Future<void> _completeProfile() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a username.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Encode and upload profile image if selected
      if (_profileImage != null) {
        final imgUrl = await _encodeImage(
          _profileImage!,
        ); // pass bytes directly
        if (imgUrl != null) {
          await _saveProfileToApi(imgUrl);
        }
      }
    } finally {
      setState(() => _isSaving = false);
    }

    // Update local notifiers
    displayNameNotifier.value = widget.fullName;
    usernameNotifier.value = '@$username';
    if (_profileImage != null) {
      profileImageNotifier.value = _profileImage;
    }

    // Load badges then award b3 (Trusted User) and b4 (Early Bird)
    final userId = loggedInUserIdNotifier.value;
    if (userId != null) {
      await BadgeService.loadBadges(userId);
      if (_profileImage != null)
        await BadgeService.awardBadge(3); // Trusted User
      if (userId <= 100) await BadgeService.awardBadge(4); // Early Bird
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FabTabs()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg.png', fit: BoxFit.cover),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── App bar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
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
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                image: _profileImage != null
                                ? DecorationImage(
                                    image: MemoryImage(
                                      _profileImage!,
                                    ), // ← MemoryImage instead of FileImage
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
                        Positioned(
                          bottom: 4,
                          right: -2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: kBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
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

                // ── Form ──────────────────────────────────────────────
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.alternate_email_rounded,
                                color: kGrey,
                                size: 20,
                              ),
                              hintText: 'e.g. futurist_alex',
                              hintStyle: const TextStyle(
                                color: kGrey,
                                fontSize: 14,
                              ),
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
                          ),
                        ),

                        const SizedBox(height: 32),

                        _isSaving
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : PrimaryButton(
                                label: 'Complete Profile  ›',
                                onTap: _completeProfile,
                              ),

                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'By finishing, you agree to our Terms of Service',
                            style: TextStyle(color: kGrey, fontSize: 12),
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
