

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/Login.dart';
import 'package:twedrli/Pages/home.dart';
import 'package:twedrli/badge_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ProfileScreen(),
    );
  }
}

// ─── Shared Profile Image Notifier ───────────────────────────────────────────

final ValueNotifier<Uint8List?> profileImageNotifier =
    ValueNotifier<Uint8List?>(null);

// ─── Shared Username Notifier ─────────────────────────────────────────────────

final ValueNotifier<String> displayNameNotifier = ValueNotifier<String>('');
final ValueNotifier<String> usernameNotifier = ValueNotifier<String>('');

// ─── Data Models ─────────────────────────────────────────────────────────────

class BadgeData {
  final String label;
  final IconData icon;
  final Color color;
  final String description;
  final bool isEarned;

  BadgeData(
    this.label,
    this.icon,
    this.color,
    this.description, {
    this.isEarned = false,
  });
}

class ItemData {
  final String id;
  final String title;
  final String location;
  final String imagePath;
  ItemData(this.id, this.title, this.location, this.imagePath);
}

class NavItem {
  final IconData? icon;
  final IconData? activeIcon;
  final String label;
  NavItem(this.icon, this.activeIcon, this.label);
}

// ─── Global Badge Data ────────────────────────────────────────────────────────

final List<BadgeData> allBadges = [
  BadgeData(
    'Campus Hero',
    Icons.emoji_events_outlined,
    const Color(0xFFF5A623),
    'Helped recover 5+ lost items on campus',
    isEarned: true,
  ),
  BadgeData(
    'Fast Finder',
    Icons.bolt,
    const Color(0xFF5856D6),
    'Found an item within 24 hours of report',
    isEarned: true,
  ),
  BadgeData(
    'Trusted User',
    Icons.verified_user_outlined,
    const Color(0xFF2ECC71),
    'Verified identity & 0 violations',
    isEarned: true,
  ),
  BadgeData(
    'Early Bird',
    Icons.wb_sunny_outlined,
    const Color(0xFFFF6B6B),
    'First 100 users on the platform',
    isEarned: true,
  ),
  BadgeData(
    'Team Player',
    Icons.group_outlined,
    const Color(0xFF00BCD4),
    'Collaborated with 3+ students on recoveries',
    isEarned: true,
  ),
  BadgeData(
    'Sharp Eye',
    Icons.remove_red_eye_outlined,
    const Color(0xFF9C27B0),
    'Submitted 10+ accurate item descriptions',
    isEarned: true,
  ),
  BadgeData(
    'Master Finder',
    Icons.explore_outlined,
    const Color(0xFFE67E22),
    'Found 50+ lost items',
  ),
  BadgeData(
    'Community Guardian',
    Icons.shield_outlined,
    const Color(0xFF3498DB),
    'Reported 20+ suspicious activities',
  ),
  BadgeData(
    'Weekend Warrior',
    Icons.weekend_outlined,
    const Color(0xFFE74C3C),
    'Active on weekends for 3 months',
  ),
  BadgeData(
    'Night Owl',
    Icons.nights_stay_outlined,
    const Color(0xFF8E44AD),
    'Made 15+ reports after 10 PM',
  ),
  BadgeData(
    'Library Legend',
    Icons.local_library_outlined,
    const Color(0xFF27AE60),
    'Most active in library zone',
  ),
  BadgeData(
    'Gym Hero',
    Icons.fitness_center_outlined,
    const Color(0xFF2980B9),
    'Recovered 10+ items at the gym',
  ),
  BadgeData(
    'Cafeteria King',
    Icons.restaurant_outlined,
    const Color(0xFFF39C12),
    'Found 8+ items in cafeteria',
  ),
  BadgeData(
    'Tech Genius',
    Icons.computer_outlined,
    const Color(0xFF16A085),
    'Helped recover 12+ electronic devices',
  ),
  BadgeData(
    'Key Master',
    Icons.vpn_key_outlined,
    const Color(0xFFD35400),
    'Returned 15+ sets of keys',
  ),
  BadgeData(
    'Wallet Warrior',
    Icons.account_balance_wallet_outlined,
    const Color(0xFF2C3E50),
    'Returned 10+ wallets with all contents',
  ),
  BadgeData(
    'Phone Finder',
    Icons.phone_android_outlined,
    const Color(0xFF7F8C8D),
    'Helped recover 8+ phones',
  ),
  BadgeData(
    'Backpack Buddy',
    Icons.backpack_outlined,
    const Color(0xFFBDC3C7),
    'Found 20+ backpacks',
  ),
  BadgeData(
    'ID Expert',
    Icons.credit_card_outlined,
    const Color(0xFF95A5A6),
    'Returned 25+ student IDs',
  ),
  BadgeData(
    'Water Bottle Collector',
    Icons.local_drink_outlined,
    const Color(0xFF1ABC9C),
    'Found 30+ water bottles',
  ),
  BadgeData(
    'Umbrella Saver',
    Icons.beach_access_outlined,
    const Color(0xFF3498DB),
    'Returned 15+ umbrellas on rainy days',
  ),
  BadgeData(
    'Charger Champion',
    Icons.battery_charging_full_outlined,
    const Color(0xFF9B59B6),
    'Found 10+ phone chargers',
  ),
  BadgeData(
    'Glasses Guardian',
    Icons.remove_red_eye_outlined,
    const Color(0xFF34495E),
    'Returned 8+ pairs of glasses',
  ),
  BadgeData(
    'Notebook Ninja',
    Icons.note_outlined,
    const Color(0xFFE67E22),
    'Found 25+ notebooks with class notes',
  ),
  BadgeData(
    'Calculator Crusader',
    Icons.calculate_outlined,
    const Color(0xFF2ECC71),
    'Returned 12+ scientific calculators',
  ),
  BadgeData(
    'Headphone Hero',
    Icons.headphones_outlined,
    const Color(0xFFE74C3C),
    'Found 20+ pairs of headphones',
  ),
  BadgeData(
    'Flash Drive Finder',
    Icons.save_outlined,
    const Color(0xFF3498DB),
    'Returned 18+ USB drives with data',
  ),
  BadgeData(
    'Watch Wizard',
    Icons.watch_outlined,
    const Color(0xFFF1C40F),
    'Found 7+ watches',
  ),
  BadgeData(
    'Jewelry Journalist',
    Icons.diamond_outlined,
    const Color(0xFFE91E63),
    'Returned 5+ pieces of jewelry',
  ),
];

// ─── Main Profile Screen ──────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedNavIndex = 4;
  bool _savedItemsSelected = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (loggedInUserNameNotifier.value.isNotEmpty) {
      displayNameNotifier.value = loggedInUserNameNotifier.value;
      usernameNotifier.value =
          '@${loggedInUserNameNotifier.value.toLowerCase().replaceAll(' ', '_')}';
    }
  }

  int get earnedBadgesCount => earnedBadgeCount;

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      
      profileImageNotifier.value = bytes;

      final userId = loggedInUserIdNotifier.value;
      if (userId != null) {
        final success = await TwedrliApi.updateProfilePicture(userId, base64Image);
        if (success) {
          loggedInImgUrlNotifier.value = base64Image;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated successfully')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile picture on server')),
            );
          }
        }
      }
    }
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(text: displayNameNotifier.value);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Name',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.black38,
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2979FF),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              counterStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.black38,
                fontSize: 11,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.grey[400] : Colors.black54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  displayNameNotifier.value = newName;
                  loggedInUserNameNotifier.value = newName;

                  // Sync to Database
                  final userId = loggedInUserIdNotifier.value;
                  if (userId != null) {
                    TwedrliApi.updateUserName(userId, newName);
                  }
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  void _toggleSaved(int index) {
    final saved = savedItemsNotifier.value;
    final item = saved[index];
    savedItemsNotifier.value = saved.where((s) => s.id != item.id).toList();
  }

  void _openAllBadges() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllBadgesScreen()),
    );
  }

  // ── Get current user's posts from the global list ─────────────────────────
  List<LostFoundItem> _getMyPosts(List<LostFoundItem> allItems) {
    final myId = loggedInUserIdNotifier.value;
    if (myId == null) return [];
    return allItems.where((item) => item.userId == myId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.black54;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFEEEEEE);

    if (isGuestNotifier.value) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2979FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Color(0xFF2979FF),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Guest Mode',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to your account to view your profile, saved items, and stats.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    isGuestNotifier.value = false;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In Now',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme, isDark),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildAvatar(),
                    const SizedBox(height: 12),
                    _buildUserInfo(theme, isDark),
                    const SizedBox(height: 20),
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildBadges(isDark, textColor, secondaryTextColor),
                    const SizedBox(height: 16),
                    _buildToggleTabs(theme, isDark),
                    const SizedBox(height: 16),
                    _savedItemsSelected
                        ? _buildSavedItems(
                            isDark,
                            cardColor,
                            borderColor,
                            textColor,
                            secondaryTextColor,
                          )
                        : _buildMyReports(
                            isDark,
                            cardColor,
                            borderColor,
                            textColor,
                            secondaryTextColor,
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          GestureDetector(
            onTap: () => _confirmSignOut(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: Color(0xFFE74C3C),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE74C3C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: ValueListenableBuilder<Uint8List?>(
        valueListenable: profileImageNotifier,
        builder: (context, profileImage, _) {
          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFD9FF), width: 3),
                ),
                child: ClipOval(
                  child: profileImage != null
                      ? Image.memory(
                          profileImage,
                          fit: BoxFit.cover,
                        ) // ← use this
                      : ValueListenableBuilder<String>(
                          valueListenable: loggedInImgUrlNotifier,
                          builder: (context, imgUrl, _) {


// REPLACE with this:
                            if (imgUrl.isNotEmpty) {
                              if (imgUrl.startsWith('data:image')) {
                                try {
                                  final bytes = base64Decode(
                                    imgUrl.split(',').last,
                                  );
                                  return Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFFE8F0FE),
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  );
                                } catch (_) {}
                              }
                              return Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFE8F0FE),
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.blue,
                                  ),
                                ),
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                              );
                            }

                            return Image.asset(
                              'assets/profile_placeholder.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFE8F0FE),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2979FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme, bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: _editDisplayName,
          child: ValueListenableBuilder<String>(
            valueListenable: displayNameNotifier,
            builder: (context, displayName, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2979FF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Color(0xFF2979FF),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        ValueListenableBuilder<String>(
          valueListenable: usernameNotifier,
          builder: (context, username, _) {
            return Text(
              username,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        ValueListenableBuilder<String>(
          valueListenable: loggedInDepartmentNotifier,
          builder: (context, dept, _) {
            return Text(
              dept.isNotEmpty ? dept : '',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.black54,
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Stats now use real data from allItemsNotifier ─────────────────────────
  Widget _buildStats() {
    return ValueListenableBuilder<List<LostFoundItem>>(
      valueListenable: allItemsNotifier,
      builder: (context, allItems, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final myPosts = _getMyPosts(allItems);
        final postCount = myPosts.length;
        final recoveryCount = myPosts
            .where((i) => i.status == ItemStatus.claimed)
            .length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$postCount',
                  'POSTS',
                  isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F4FF),
                  const Color(0xFF2979FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '$recoveryCount',
                  'RECOVERIES',
                  isDark ? const Color(0xFF1E3A2E) : const Color(0xFFEAF9F0),
                  const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color bgColor,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges(bool isDark, Color textColor, Color? secondaryTextColor) {
    return ValueListenableBuilder<List<bool>>(
      valueListenable: userBadgesNotifier,
      builder: (context, earnedFlags, _) {
        final earned = earnedFlags.where((b) => b).length;
        final allVerified = earnedFlags.every((b) => b);
        final preview = allBadges.take(3).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Badges',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$earned/${allBadges.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2979FF),
                          ),
                        ),
                      ),
                      if (allVerified) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 12,
                                color: Color(0xFF2ECC71),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'VERIFIED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2ECC71),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  GestureDetector(
                    onTap: _openAllBadges,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2979FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'VIEW ALL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(
                  preview.length,
                  (i) => Expanded(
                    child: _buildBadgeItem(preview[i], earnedFlags[i], isDark),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeItem(BadgeData badge, bool isEarned, bool isDark) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isEarned ? badge.color : badge.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(badge.icon, color: Colors.white, size: 28),
            ),
            if (isEarned)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          badge.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildToggleTabs(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildTab('Saved Items', true, theme, isDark)),
          Expanded(child: _buildTab('My Reports', false, theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSaved, ThemeData theme, bool isDark) {
    final isSelected = _savedItemsSelected == isSaved;
    return GestureDetector(
      onTap: () => setState(() => _savedItemsSelected = isSaved),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDark ? Colors.grey[500] : Colors.black45),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedItems(
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color? secondaryTextColor,
  ) {
    return ValueListenableBuilder<List<LostFoundItem>>(
      valueListenable: savedItemsNotifier,
      builder: (context, saved, _) {
        if (saved.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No saved items yet.\nTap the bookmark on any item to save it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.black45,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            itemCount: saved.length,
            itemBuilder: (context, index) {
              final item = saved[index];
              return _buildItemCard(
                ItemData(
                  item.id,
                  item.title,
                  item.locationDisplay,
                  item.imagePath,
                ),
                index,
                isDark,
                cardColor,
                borderColor,
                textColor,
                secondaryTextColor!,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItemCard(
    ItemData item,
    int index,
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    Widget buildImage() {
      bool isBase64(String s) {
        if (s.length % 4 != 0) return false;
        return RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(s);
      }

      Widget placeholder() => Container(
        color: isDark ? Colors.grey[800] : const Color(0xFFF0F0F0),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: isDark ? Colors.grey[600] : Colors.grey,
          size: 30,
        ),
      );

      if (item.imagePath.isEmpty) return placeholder();

      if (item.imagePath.startsWith('http://') ||
          item.imagePath.startsWith('https://')) {
        return Image.network(
          item.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder(),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : placeholder(),
        );
      }

      if (item.imagePath.startsWith('data:image') || isBase64(item.imagePath)) {
        try {
          final bytes = base64Decode(
            item.imagePath.contains(',')
                ? item.imagePath.split(',').last
                : item.imagePath,
          );
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder(),
          );
        } catch (_) {
          return placeholder();
        }
      }

      if (item.imagePath.startsWith('assets/')) {
        return Image.asset(
          item.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder(),
        );
      }

      return Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: buildImage(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleSaved(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      size: 18,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 12,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                item.location,
                style: TextStyle(fontSize: 11, color: secondaryTextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── My Reports: show real posts by this user, no hardcoded defaults ────────
  Widget _buildMyReports(
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color? secondaryTextColor,
  ) {
    return ValueListenableBuilder<List<LostFoundItem>>(
      valueListenable: allItemsNotifier,
      builder: (context, allItems, _) {
        final myPosts = _getMyPosts(allItems);

        if (myPosts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No reports yet.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[500] : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'When you post a lost or found item,\nit will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.black38,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: myPosts
                .map(
                  (item) => _buildRealReportCard(
                    item,
                    isDark,
                    cardColor,
                    borderColor,
                    textColor,
                    secondaryTextColor!,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  // ── Card for a real LostFoundItem ─────────────────────────────────────────
  Widget _buildRealReportCard(
    LostFoundItem report,
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    // Map status to color and icon
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (report.status) {
      case ItemStatus.lost:
        statusColor = const Color(0xFFE53935);
        statusIcon = Icons.error_outline;
        statusLabel = 'Lost';
        break;
      case ItemStatus.found:
        statusColor = const Color(0xFF1E88E5);
        statusIcon = Icons.search_outlined;
        statusLabel = 'Found';
        break;
      case ItemStatus.claimed:
        statusColor = const Color(0xFF43A047);
        statusIcon = Icons.check_circle_outline;
        statusLabel = 'Claimed';
        break;
    }

    // Icon based on category
    IconData categoryIcon = _iconForReport(report.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Thumbnail or icon ──
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: report.imagePath.isNotEmpty
                  ? _buildReportThumbnail(
                      report.imagePath,
                      isDark,
                      categoryIcon,
                      statusColor,
                    )
                  : Container(
                      color: statusColor.withOpacity(isDark ? 0.2 : 0.12),
                      child: Icon(categoryIcon, color: statusColor, size: 24),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        report.locationDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  report.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[600] : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          // ── Status chip ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportThumbnail(
    String imagePath,
    bool isDark,
    IconData fallbackIcon,
    Color iconColor,
  ) {
    Widget placeholder() => Container(
      color: iconColor.withOpacity(isDark ? 0.2 : 0.12),
      child: Icon(fallbackIcon, color: iconColor, size: 24),
    );

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : placeholder(),
      );
    }

    if (imagePath.startsWith('data:image')) {
      try {
        final bytes = base64Decode(imagePath.split(',').last);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder(),
        );
      } catch (_) {
        return placeholder();
      }
    }

    return placeholder();
  }

  IconData _iconForReport(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'fashion':
        return Icons.checkroom;
      case 'home & living':
        return Icons.chair;
      case 'beauty':
        return Icons.face;
      case 'sport':
        return Icons.sports_soccer;
      case 'books':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      profileImageNotifier.value = null;
      displayNameNotifier.value = '';
      usernameNotifier.value = '';

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

// ─── All Badges Screen ────────────────────────────────────────────────────────

class AllBadgesScreen extends StatelessWidget {
  const AllBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<List<bool>>(
      valueListenable: userBadgesNotifier,
      builder: (context, earnedFlags, _) {
        final earnedCount = earnedFlags.where((b) => b).length;
        final allVerified = earnedFlags.every((b) => b);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'All Badges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (allVerified) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified,
                    size: 20,
                    color: Color(0xFF2ECC71),
                  ),
                ],
              ],
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Earned: $earnedCount/${allBadges.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2979FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (allVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2ECC71,
                          ).withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: Color(0xFF2ECC71),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'VERIFIED',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2ECC71),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.green.withOpacity(0.2)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2ECC71),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Earned',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2ECC71),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.9,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, index) =>
                  _buildBadgeCard(allBadges[index], earnedFlags[index], isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeCard(BadgeData badge, bool isEarned, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badge.color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEarned
              ? const Color(0xFF2ECC71)
              : badge.color.withOpacity(0.25),
          width: isEarned ? 2 : 1.5,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isEarned
                            ? badge.color
                            : badge.color.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(badge.icon, color: Colors.white, size: 26),
                    ),
                    if (isEarned)
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Color(0xFF2ECC71),
                          child: Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  badge.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badge.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[400] : Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isEarned)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'LOCKED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
