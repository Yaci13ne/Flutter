import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  final List<TutorialSection> sections = const [
    TutorialSection(
      title: 'How to Report a Lost Item',
      steps: [
        TutorialItemData(
          imagePath: 'assets/ttr/4-home_page.png',
          title: 'Step 1: Open Create Post',
          description:
              'Tap the + button at the bottom center of the home screen to start creating a new post.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 2: Select LOST',
          description:
              'Make sure "LOST" is selected at the top toggle. This tells others you\'re looking for this item.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 3: Add Photos',
          description:
              'Tap the photo upload area to add clear images of your lost item. Good photos help others identify it faster.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 4: Fill Details',
          description:
              'Enter the item title, color, date, and a detailed description with unique marks.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 5: Select Location on Map',
          description:
              'Tap the map pin icon or "Pick on Map" button in the location field. '
              'A full-screen map will open — drag the pin or tap the exact spot where '
              'you lost the item, then confirm your selection. The address fills in automatically.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 6: Submit Post',
          description:
              'Tap "Submit Post" to publish your lost item. You\'ll be notified if someone finds a matching item.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Report a Found Item',
      steps: [
        TutorialItemData(
          imagePath: 'assets/ttr/4-home_page.png',
          title: 'Step 1: Open Create Post',
          description:
              'Tap the + button at the bottom center to create a new post for the item you found.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 2: Select FOUND',
          description:
              'Toggle to "FOUND" at the top. This lets everyone know you have an item that needs its owner.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 3: Add Photos',
          description:
              'Upload clear photos of the found item. Make sure to capture any identifying features.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 4: Add Location',
          description:
              'Enter where you found the item. This helps the owner know where to look or meet.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/7-Create_post_page.png',
          title: 'Step 5: Submit Post',
          description:
              'Submit the found item post. The system will try to match it with lost item reports.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Search for Items',
      steps: [
        TutorialItemData(
          imagePath: 'assets/ttr/4-home_page.png',
          title: 'Step 1: Open Search',
          description:
              'Tap the "Search" tab at the bottom navigation bar to access the advanced search screen.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/5-search_page.png',
          title: 'Step 2: Enter Keywords',
          description:
              'Type keywords like "blue water bottle" or "black keys" to find specific items.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/5-search_page.png',
          title: 'Step 3: Apply Filters',
          description:
              'Use the advanced filters to narrow down by object type, campus zone, date, and color.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/5-search_page.png',
          title: 'Step 4: View Results',
          description:
              'Browse through the matching items. Tap any item to see full details and contact information.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Claim an Item',
      steps: [
        TutorialItemData(
          imagePath: 'assets/ttr/5-search_page.png',
          title: 'Step 1: Find Your Item',
          description:
              'Search for your lost item or browse the found items section until you spot what you\'re looking for.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/6-item_details_page.png',
          title: 'Step 2: Open Item Details',
          description:
              'Tap on the item card to open the detailed view with all information and photos.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/6-item_details_page.png',
          title: 'Step 3: Tap Claim Button',
          description:
              'If the item matches yours, tap the "Claim Item" button at the bottom of the details screen.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/8-chat_page.png',
          title: 'Step 4: Contact Finder',
          description:
              'The app will connect you with the finder via chat. Describe your item to verify ownership.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/8-chat_page.png',
          title: 'Step 5: Arrange Pickup',
          description:
              'Once ownership is verified, arrange a safe meeting spot on campus to collect your item.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Use the Activity Feed',
      steps: [
        TutorialItemData(
          imagePath: 'assets/ttr/4-home_page.png',
          title: 'Step 1: Open Activity',
          description:
              'Tap the "Activity" tab at the bottom navigation bar to see your notifications and updates.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/8-activity_page.png',
          title: 'Step 2: Check Notifications',
          description:
              'View all your activity including post approvals, match alerts, messages, and system updates.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/8-activity_page.png',
          title: 'Step 3: Quick Navigation',
          description:
              'Use the buttons at the top to quickly navigate to Chat, Notifications, Announcements, and Updates.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/8-activity_page.png',
          title: 'Step 4: Mark as Read',
          description:
              'Unread items have a colored indicator. Tap "Mark all read" to clear them or read them individually.',
        ),
      ],
    ),
    TutorialSection(
      title: 'How to Save Items',
      steps: [
        TutorialItemData(
          imagePath: 'assets/ttr/4-home_page.png',
          title: 'Step 1: Find Item to Save',
          description:
              'Browse the home screen or search results to find an item you want to bookmark for later.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/4-home_page.png',
          title: 'Step 2: Tap Bookmark Icon',
          description:
              'On each item card, tap the bookmark icon in the bottom right corner to save it to your collection.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/10-user_profile_page.png',
          title: 'Step 3: View Saved Items',
          description:
              'Go to your Profile and tap the "Saved Items" tab to see all items you\'ve bookmarked.',
        ),
        TutorialItemData(
          imagePath: 'assets/ttr/10-user_profile_page.png',
          title: 'Step 4: Manage Saved Items',
          description:
              'Tap the bookmark icon again to remove items from your saved collection when no longer needed.',
        ),
      ],
    ),
  ];

  // ── Badge data ────────────────────────────────────────────────────────────
  static const List<BadgeTutorialData> _badges = [
    // ── Earned / general ──────────────────────────────────────────────────
    BadgeTutorialData(
      name: 'Campus Hero',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFF5A623),
      how: 'Help recover 5 or more lost items on campus.',
      tip:
          'Respond to found-item posts and assist others in claiming their belongings to earn this badge.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Fast Finder',
      icon: Icons.bolt,
      color: Color(0xFF5856D6),
      how:
          'Find and report a lost item within 24 hours of its original report.',
      tip:
          'Check new lost-item posts frequently so you can act quickly when you spot something nearby.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Trusted User',
      icon: Icons.verified_user_outlined,
      color: Color(0xFF2ECC71),
      how:
          'Verify your identity in Settings and maintain a clean record with zero violations.',
      tip:
          'Keep all interactions respectful and honest — a single violation can prevent this badge.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Early Bird',
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFFF6B6B),
      how: 'Be among the first 100 users to register on the platform.',
      tip:
          'This is a one-time legacy badge — if you already have it, congratulations! It can no longer be earned.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Team Player',
      icon: Icons.group_outlined,
      color: Color(0xFF00BCD4),
      how:
          'Collaborate with 3 or more different students to help recover lost items.',
      tip:
          'Use the in-app chat to coordinate meetups and handoffs with other students.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Sharp Eye',
      icon: Icons.remove_red_eye_outlined,
      color: Color(0xFF9C27B0),
      how:
          'Submit 10 or more accurate item descriptions that lead to successful matches.',
      tip:
          'Include specific details like brand, color, size, and any unique marks when filling out reports.',
      isEarned: true,
    ),
    // ── Location badges ───────────────────────────────────────────────────
    BadgeTutorialData(
      name: 'Library Legend',
      icon: Icons.local_library_outlined,
      color: Color(0xFF27AE60),
      how: 'Become the most active reporter or finder in the library zone.',
      tip:
          'Tag your posts with the Library location to have your activity counted toward this zone.',
      isEarned: true, 
    ),
    BadgeTutorialData(
      name: 'Gym Hero',
      icon: Icons.fitness_center_outlined,
      color: Color(0xFF2980B9),
      how: 'Recover 10 or more items found at the campus gym.',
      tip:
          'Keep an eye out for towels, water bottles, earphones, and ID cards left behind in the gym.',
      isEarned: true,   
    ),
    BadgeTutorialData(
      name: 'Cafeteria King',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFF39C12),
      how: 'Find and report 8 or more items in the cafeteria.',
      tip:
          'Meal times are peak hours for lost items — check tables and seats before leaving.',
        isEarned: true,
  ),
    // ── Item-type badges ──────────────────────────────────────────────────
    BadgeTutorialData(
      name: 'Tech Genius',
      icon: Icons.computer_outlined,
      color: Color(0xFF16A085),
      how:
          'Help recover 12 or more electronic devices such as laptops, tablets, and phones.',
      tip:
          'Electronics are high-priority items. Use the "Electronics" category filter when posting or searching.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Key Master',
      icon: Icons.vpn_key_outlined,
      color: Color(0xFFD35400),
      how: 'Return 15 or more sets of keys to their rightful owners.',
      tip:
          'Keys are one of the most commonly lost items. Always check key-drop spots near campus entrances.',
        isEarned: true,
  ),
    BadgeTutorialData(
      name: 'Wallet Warrior',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF2C3E50),
      how: 'Return 10 or more wallets with all contents intact.',
      tip:
          'When you find a wallet, photograph its contents before handing it over so both parties are protected.',
        isEarned: true,
  ),
    BadgeTutorialData(
      name: 'Phone Finder',
      icon: Icons.phone_android_outlined,
      color: Color.fromARGB(255, 20, 141, 150),
      how: 'Help recover 8 or more phones for their owners.',
      tip:
          'If a phone is locked, try bringing it to campus security so the owner can be contacted.',
          isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Backpack Buddy',
      icon: Icons.backpack_outlined,
      color: Color.fromARGB(255, 116, 38, 109),
      how: 'Find and report 20 or more backpacks.',
      tip:
          'Note any visible keychains, patches, or tags when describing a found backpack — they help a lot.',
          isEarned: true,
    ),
    BadgeTutorialData(
      name: 'ID Expert',
      icon: Icons.credit_card_outlined,
      color: Color.fromARGB(255, 68, 106, 109),
      how: 'Return 25 or more student ID cards.',
      tip:
          'IDs often have a student number visible. Use it to contact the registrar\'s office for faster reunions.',
        isEarned: true,
  ),
    BadgeTutorialData(
      name: 'Water Bottle Collector',
      icon: Icons.local_drink_outlined,
      color: Color(0xFF1ABC9C),
      how: 'Find and report 30 or more water bottles.',
      tip:
          'Many bottles have names or initials written on them — include that in your description.',
        isEarned: true,
  ),
    BadgeTutorialData(
      name: 'Umbrella Saver',
      icon: Icons.beach_access_outlined,
      color: Color(0xFF3498DB),
      how: 'Return 15 or more umbrellas, particularly on rainy days.',
      tip:
          'Umbrellas are often left at building entrances. Check umbrella stands near lecture halls.',
          isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Charger Champion',
      icon: Icons.battery_charging_full_outlined,
      color: Color(0xFF9B59B6),
      how: 'Find and return 10 or more phone or laptop chargers.',
      tip:
          'Chargers are frequently left in power outlets in libraries and study rooms — keep an eye out.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Glasses Guardian',
      icon: Icons.remove_red_eye_outlined,
      color: Color(0xFF34495E),
      how: 'Return 8 or more pairs of glasses or sunglasses.',
      tip:
          'Glasses cases often have optician stickers that can help identify the owner.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Notebook Ninja',
      icon: Icons.note_outlined,
      color: Color(0xFFE67E22),
      how: 'Find and report 25 or more notebooks containing class notes.',
      tip:
          'Check the first page of notebooks — students often write their name and course there.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Calculator Crusader',
      icon: Icons.calculate_outlined,
      color: Color(0xFF2ECC71),
      how: 'Return 12 or more scientific calculators to their owners.',
      tip:
          'Calculators are commonly left in exam halls. Always check the model and any stickers for identification.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Headphone Hero',
      icon: Icons.headphones_outlined,
      color: Color(0xFFE74C3C),
      how: 'Find and return 20 or more pairs of headphones or earbuds.',
      tip:
          'Include the brand and cable color in your post — many headphones look similar.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Flash Drive Finder',
      icon: Icons.save_outlined,
      color: Color(0xFF3498DB),
      how: 'Return 18 or more USB flash drives that contain data.',
      tip:
          'Never open files on a found USB drive. Hand it in to the IT help desk for safe return.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Watch Wizard',
      icon: Icons.watch_outlined,
      color: Color(0xFFF1C40F),
      how: 'Find and return 7 or more watches.',
      tip:
          'Check the watch back for engravings — a name or date can make identification much easier.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Jewelry Journalist',
      icon: Icons.diamond_outlined,
      color: Color(0xFFE91E63),
      how:
          'Return 5 or more pieces of jewelry such as rings, necklaces, or bracelets.',
      tip:
          'Jewelry is easy to miss on the ground. Report findings with a detailed photo to help owners identify their piece.',
      isEarned: true,
    ),
    // ── Activity / time badges ────────────────────────────────────────────
    BadgeTutorialData(
      name: 'Master Finder',
      icon: Icons.explore_outlined,
      color: Color(0xFFE67E22),
      how: 'Find and report 50 or more lost items across the entire campus.',
      tip:
          'This is one of the hardest badges to earn. Stay consistent — every item counts.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Community Guardian',
      icon: Icons.shield_outlined,
      color: Color(0xFF3498DB),
      how:
          'Report 20 or more suspicious activities through the in-app report system.',
      tip:
          'Use the flag icon on any post you find misleading or fraudulent to contribute toward this badge.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Weekend Warrior',
      icon: Icons.weekend_outlined,
      color: Color(0xFFE74C3C),
      how: 'Stay active on weekends for 3 consecutive months.',
      tip:
          'Log in and interact with at least one post each Saturday or Sunday to keep your streak alive.',
      isEarned: true,
    ),
    BadgeTutorialData(
      name: 'Night Owl',
      icon: Icons.nights_stay_outlined,
      color: Color(0xFF8E44AD),
      how: 'Make 15 or more posts or reports after 10 PM.',
      tip:
          'Late-night library sessions or evening events are great opportunities to rack up Night Owl points.',
      isEarned: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use Twedrli'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Existing tutorial sections ──────────────────────────────────
          ...List.generate(sections.length, (index) {
            final section = sections[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: section.title,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 16),
                ...section.steps.map(
                  (item) => TutorialItem(
                    item: item,
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Divider(
                  thickness: 2,
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // ── Badges section ──────────────────────────────────────────────
          _SectionHeader(
            title: 'Badges & Achievements',
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Earn badges by actively helping the campus community. '
              'Each badge rewards a specific kind of contribution — '
              'the more you help, the more you unlock!',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),

          // Earned badges sub-header
          const SizedBox(height: 12),
          ..._badges
              .where((b) => b.isEarned)
              .map((b) => _BadgeCard(badge: b, isDark: isDark)),

          const SizedBox(height: 24),

          // Locked badges sub-header
          const SizedBox(height: 12),
          ..._badges
              .where((b) => !b.isEarned)
              .map((b) => _BadgeCard(badge: b, isDark: isDark)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primaryColor;
  const _SectionHeader({required this.title, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }
}

class _SubSectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SubSectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.grey[200] : Colors.grey[800],
      ),
    );
  }
}

// ── Badge data model ───────────────────────────────────────────────────────

class BadgeTutorialData {
  final String name;
  final IconData icon;
  final Color color;
  final String how;
  final String tip;
  final bool isEarned;

  const BadgeTutorialData({
    required this.name,
    required this.icon,
    required this.color,
    required this.how,
    required this.tip,
    this.isEarned = false,
  });
}

// ── Badge card widget ──────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final BadgeTutorialData badge;
  final bool isDark;

  const _BadgeCard({required this.badge, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = badge.isEarned ? badge.color : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: isDark ? 0 : 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(isDark ? 0.15 : 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveColor.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Icon(badge.icon, color: effectiveColor, size: 28),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          badge.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: badge.isEarned
                                ? (isDark ? Colors.white : Colors.grey[900])
                                : (isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500]),
                          ),
                        ),
                      ),
                      if (badge.isEarned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badge.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Earned',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badge.color,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // How to earn
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'How to earn: ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                        TextSpan(
                          text: badge.how,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Pro tip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: effectiveColor.withOpacity(isDark ? 0.1 : 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 14,
                          color: effectiveColor.withOpacity(0.8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            badge.tip,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Existing tutorial section & item models ────────────────────────────────

class TutorialSection {
  final String title;
  final List<TutorialItemData> steps;
  const TutorialSection({required this.title, required this.steps});
}

class TutorialItemData {
  final String imagePath;
  final String title;
  final String description;
  const TutorialItemData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

// VERSION 2: WITH REAL IMAGES FROM assets/ttr/
class TutorialItem extends StatelessWidget {
  final TutorialItemData item;
  final bool isDark;
  final Color primaryColor;

  const TutorialItem({
    super.key,
    required this.item,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: isDark ? 0 : 3,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          // Real image from assets/ttr/
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Image.asset(
              item.imagePath,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: isDark ? Colors.grey[700] : Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not found',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[600] : Colors.grey[500],
                          ),
                        ),
                        Text(
                          item.imagePath,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[700] : Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
