// pubspec.yaml dependencies needed:
//   image_picker: ^1.0.7
//
// Add to pubspec.yaml under dependencies:
//   image_picker: ^1.0.7
//
// Add to pubspec.yaml under flutter:
//   assets:
//     - assets/
//
// Android: add to AndroidManifest.xml inside <manifest>:
//   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
// iOS: add to Info.plist:
//   NSPhotoLibraryUsageDescription - "Select profile photo"

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/home.dart';

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

/// A global ValueNotifier that holds the currently selected profile image.
/// Both ProfileScreen and AppDrawer observe this to stay in sync.
final ValueNotifier<File?> profileImageNotifier = ValueNotifier<File?>(null);

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
  final String title;
  final String location;
  final String imagePath;
  ItemData(this.title, this.location, this.imagePath);
}

class ReportData {
  final String title;
  final String location;
  final String date;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color iconColor;
  ReportData(
    this.title,
    this.location,
    this.date,
    this.status,
    this.statusColor,
    this.icon,
    this.iconColor,
  );
}

class NavItem {
  final IconData? icon;
  final IconData? activeIcon;
  final String label;
  NavItem(this.icon, this.activeIcon, this.label);
}

// ─── Global Data ─────────────────────────────────────────────────────────────

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
    isEarned: false,
  ),
  BadgeData(
    'Community Guardian',
    Icons.shield_outlined,
    const Color(0xFF3498DB),
    'Reported 20+ suspicious activities',
    isEarned: false,
  ),
  BadgeData(
    'Weekend Warrior',
    Icons.weekend_outlined,
    const Color(0xFFE74C3C),
    'Active on weekends for 3 months',
    isEarned: false,
  ),
  BadgeData(
    'Night Owl',
    Icons.nights_stay_outlined,
    const Color(0xFF8E44AD),
    'Made 15+ reports after 10 PM',
    isEarned: false,
  ),
  BadgeData(
    'Library Legend',
    Icons.local_library_outlined,
    const Color(0xFF27AE60),
    'Most active in library zone',
    isEarned: false,
  ),
  BadgeData(
    'Gym Hero',
    Icons.fitness_center_outlined,
    const Color(0xFF2980B9),
    'Recovered 10+ items at the gym',
    isEarned: false,
  ),
  BadgeData(
    'Cafeteria King',
    Icons.restaurant_outlined,
    const Color(0xFFF39C12),
    'Found 8+ items in cafeteria',
    isEarned: false,
  ),
  BadgeData(
    'Tech Genius',
    Icons.computer_outlined,
    const Color(0xFF16A085),
    'Helped recover 12+ electronic devices',
    isEarned: false,
  ),
  BadgeData(
    'Key Master',
    Icons.vpn_key_outlined,
    const Color(0xFFD35400),
    'Returned 15+ sets of keys',
    isEarned: false,
  ),
  BadgeData(
    'Wallet Warrior',
    Icons.account_balance_wallet_outlined,
    const Color(0xFF2C3E50),
    'Returned 10+ wallets with all contents',
    isEarned: false,
  ),
  BadgeData(
    'Phone Finder',
    Icons.phone_android_outlined,
    const Color(0xFF7F8C8D),
    'Helped recover 8+ phones',
    isEarned: false,
  ),
  BadgeData(
    'Backpack Buddy',
    Icons.backpack_outlined,
    const Color(0xFFBDC3C7),
    'Found 20+ backpacks',
    isEarned: false,
  ),
  BadgeData(
    'ID Expert',
    Icons.credit_card_outlined,
    const Color(0xFF95A5A6),
    'Returned 25+ student IDs',
    isEarned: false,
  ),
  BadgeData(
    'Water Bottle Collector',
    Icons.local_drink_outlined,
    const Color(0xFF1ABC9C),
    'Found 30+ water bottles',
    isEarned: false,
  ),
  BadgeData(
    'Umbrella Saver',
    Icons.beach_access_outlined,
    const Color(0xFF3498DB),
    'Returned 15+ umbrellas on rainy days',
    isEarned: false,
  ),
  BadgeData(
    'Charger Champion',
    Icons.battery_charging_full_outlined,
    const Color(0xFF9B59B6),
    'Found 10+ phone chargers',
    isEarned: false,
  ),
  BadgeData(
    'Glasses Guardian',
    Icons.remove_red_eye_outlined,
    const Color(0xFF34495E),
    'Returned 8+ pairs of glasses',
    isEarned: false,
  ),
  BadgeData(
    'Notebook Ninja',
    Icons.note_outlined,
    const Color(0xFFE67E22),
    'Found 25+ notebooks with class notes',
    isEarned: false,
  ),
  BadgeData(
    'Calculator Crusader',
    Icons.calculate_outlined,
    const Color(0xFF2ECC71),
    'Returned 12+ scientific calculators',
    isEarned: false,
  ),
  BadgeData(
    'Headphone Hero',
    Icons.headphones_outlined,
    const Color(0xFFE74C3C),
    'Found 20+ pairs of headphones',
    isEarned: false,
  ),
  BadgeData(
    'Flash Drive Finder',
    Icons.save_outlined,
    const Color(0xFF3498DB),
    'Returned 18+ USB drives with data',
    isEarned: false,
  ),
  BadgeData(
    'Watch Wizard',
    Icons.watch_outlined,
    const Color(0xFFF1C40F),
    'Found 7+ watches',
    isEarned: false,
  ),
  BadgeData(
    'Jewelry Journalist',
    Icons.diamond_outlined,
    const Color(0xFFE91E63),
    'Returned 5+ pieces of jewelry',
    isEarned: false,
  ),
];

final List<ItemData> savedItems = [
  ItemData('Car Keys (Toyota)', 'Student Union', 'assets/keys.png'),
  ItemData('HydroFlask Blue', 'Gym Locker', 'assets/Bottle.png'),
  ItemData('Black Umbrella', 'Science Hall', 'assets/umbrella.png'),
];

final List<ReportData> myReports = [
  ReportData(
    'Lost AirPods Pro',
    'Engineering Block B',
    'Feb 20, 2025',
    'Searching',
    const Color(0xFFF5A623),
    Icons.headphones,
    const Color(0xFFF5A623),
  ),
  ReportData(
    'Found: Student ID',
    'Cafeteria',
    'Feb 18, 2025',
    'Returned',
    const Color(0xFF2ECC71),
    Icons.badge_outlined,
    const Color(0xFF2ECC71),
  ),
  ReportData(
    'Lost Laptop Bag',
    'Library Room 3',
    'Feb 15, 2025',
    'Recovered',
    const Color(0xFF2979FF),
    Icons.laptop_outlined,
    const Color(0xFF2979FF),
  ),
  ReportData(
    'Found: Water Bottle',
    'Sports Complex',
    'Feb 10, 2025',
    'Returned',
    const Color(0xFF2ECC71),
    Icons.local_drink_outlined,
    const Color(0xFF00BCD4),
  ),
  ReportData(
    'Lost Calculator',
    'Math Dept.',
    'Feb 5, 2025',
    'Closed',
    Colors.black38,
    Icons.calculate_outlined,
    Colors.black38,
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
  final Set<int> _savedIndices = {0, 1, 2, 3};
  final ImagePicker _picker = ImagePicker();

  int get earnedBadgesCount =>
      allBadges.where((badge) => badge.isEarned).length;

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      // Update the global notifier — both ProfileScreen and AppDrawer will reflect the change
      profileImageNotifier.value = File(file.path);
    }
  }

  void _toggleSaved(int index) {
    setState(() {
      if (_savedIndices.contains(index)) {
        _savedIndices.remove(index);
      } else {
        _savedIndices.add(index);
      }
    });
  }

  void _openAllBadges() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllBadgesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildAvatar(),
                    const SizedBox(height: 12),
                    _buildUserInfo(),
                    const SizedBox(height: 20),
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildBadges(),
                    const SizedBox(height: 16),
                    _buildToggleTabs(),
                    const SizedBox(height: 16),
                    _savedItemsSelected
                        ? _buildSavedItems()
                        : _buildMyReports(),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.settings, color: Colors.black87, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: ValueListenableBuilder<File?>(
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
                      ? Image.file(profileImage, fit: BoxFit.cover)
                      : Image.asset(
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

  Widget _buildUserInfo() {
    return Column(
      children: const [
        Text(
          'Alex Rivers',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '@arivers_24',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2979FF),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Computer Science Dept.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '24',
              'POSTS',
              const Color(0xFFE8F4FF),
              const Color(0xFF2979FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '12',
              'RECOVERIES',
              const Color(0xFFEAF9F0),
              const Color(0xFF2ECC71),
            ),
          ),
        ],
      ),
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

  Widget _buildBadges() {
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
                  const Text(
                    'Badges',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$earnedBadgesCount/${allBadges.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2979FF),
                      ),
                    ),
                  ),
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
            children: preview
                .map((b) => Expanded(child: _buildBadgeItem(b)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(BadgeData badge) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: badge.color,
                shape: BoxShape.circle,
              ),
              child: Icon(badge.icon, color: Colors.white, size: 28),
            ),
            if (badge.isEarned)
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildTab('Saved Items', true)),
          Expanded(child: _buildTab('My Reports', false)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSaved) {
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
              color: isSelected ? const Color(0xFF2979FF) : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2979FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedItems() {
    return ValueListenableBuilder<List<LostFoundItem>>(
      valueListenable: savedItemsNotifier,
      builder: (context, saved, _) {
        if (saved.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No saved items yet.\nTap the bookmark on any item to save it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, fontSize: 14),
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
                ItemData(item.title, item.location, item.imagePath),
                index,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItemCard(ItemData item, int index) {
    final isSaved = _savedIndices.contains(index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item.imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF0F0F0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 30,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Image not found',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                      color: const Color(0xFF2196F3),
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 12,
              color: Colors.black45,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                item.location,
                style: const TextStyle(fontSize: 11, color: Colors.black45),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyReports() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: myReports.map((r) => _buildReportCard(r)).toList(),
      ),
    );
  }

  Widget _buildReportCard(ReportData report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: report.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(report.icon, color: report.iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      report.location,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  report.date,
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: report.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              report.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: report.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── All Badges Screen ────────────────────────────────────────────────────────

class AllBadgesScreen extends StatelessWidget {
  const AllBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int earnedCount = allBadges.where((badge) => badge.isEarned).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
        ),
        title: const Text(
          'All Badges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
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
          itemBuilder: (context, index) => _buildBadgeCard(allBadges[index]),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(BadgeData badge) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badge.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badge.isEarned
              ? const Color(0xFF2ECC71)
              : badge.color.withOpacity(0.25),
          width: badge.isEarned ? 2 : 1.5,
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
                        color: badge.color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(badge.icon, color: Colors.white, size: 26),
                    ),
                    if (badge.isEarned)
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
                  style: const TextStyle(fontSize: 9, color: Colors.black45),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!badge.isEarned)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
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
