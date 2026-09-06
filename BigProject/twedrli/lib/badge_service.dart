import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ─────────────────────────────────────────────
// BADGE SERVICE
// Single source of truth for all badge logic.
// ─────────────────────────────────────────────

/// Notifier holding the current user's earned badge flags (b1–b29).
/// Index 0 = b1, index 28 = b29.
final ValueNotifier<List<bool>> userBadgesNotifier =
    ValueNotifier<List<bool>>(List.filled(29, false));

/// Notifier for the badge row ID (needed for PUT /badges/:id)
final ValueNotifier<int?> badgeRowIdNotifier = ValueNotifier<int?>(null);

/// Whether all 29 badges are earned → user is "verified"
bool get isUserVerified => userBadgesNotifier.value.every((b) => b);

/// Count of earned badges
int get earnedBadgeCount => userBadgesNotifier.value.where((b) => b).length;

const String _base = 'https://twedrliapi.linguaflo.me';

class BadgeService {
  // ── Load badges from API for given userId ──────────────────────────────────
  static Future<void> loadBadges(int userId) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/badges/$userId'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        badgeRowIdNotifier.value = data['id'] as int?;
        final flags = List<bool>.generate(29, (i) {
          final val = data['b${i + 1}'];
          if (val == null) return false;
          if (val is bool) return val;
          return val == 1 || val == true;
        });
        userBadgesNotifier.value = flags;
        debugPrint(
          '🏅 Badges loaded: ${flags.where((b) => b).length}/29 earned',
        );
      }
    } catch (e) {
      debugPrint('Badge load error: $e');
    }
  }

  // ── Award a specific badge (1-indexed, b1=1 … b29=29) ────────────────────
  // Only sends to API if not already earned.
  static Future<void> awardBadge(int badgeNumber) async {
    if (badgeNumber < 1 || badgeNumber > 29) return;
    final idx = badgeNumber - 1;
    if (userBadgesNotifier.value[idx]) return; // already earned

    final rowId = badgeRowIdNotifier.value;
    if (rowId == null) return;

    try {
      final res = await http
          .put(
            Uri.parse('$_base/badges/$rowId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'b$badgeNumber': true}),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        // Update local notifier
        final updated = List<bool>.from(userBadgesNotifier.value);
        updated[idx] = true;
        userBadgesNotifier.value = updated;
        debugPrint('🏅 Badge b$badgeNumber awarded!');
      }
    } catch (e) {
      debugPrint('Badge award error: $e');
    }
  }

  // ── Check and auto-award badges based on current state ───────────────────
  // Call this after login, after posting, after profile setup.
  static Future<void> checkAndAwardBadges({
    required int userId,
    required List<dynamic> allItems, // List<LostFoundItem>
    required bool hasProfilePhoto,
    required bool hasProfileSetup,
  }) async {
    final myItems = allItems
        .where((item) => item.userId == userId)
        .toList();

    final claimedCount =
        myItems.where((item) => item.status.name == 'claimed').length;
    final foundCount =
        myItems.where((item) => item.status.name == 'found').length;
    final totalPosts = myItems.length;
    final postsWithDescription =
        myItems.where((item) => item.description.isNotEmpty).length;

    final now = DateTime.now();
    final isWeekend = now.weekday == DateTime.saturday ||
        now.weekday == DateTime.sunday;
    final isNightTime = now.hour >= 22 || now.hour < 4;

    // Check posts for fast finder (found within 24h of report)
    final hasFastFind = myItems.any((item) =>
        item.status.name == 'found' &&
        now.difference(item.timestamp).inHours <= 24);

    // b1 — Campus Hero: 5+ claimed items
    if (claimedCount >= 5) await awardBadge(1);

    // b2 — Fast Finder: found an item within 24h
    if (hasFastFind) await awardBadge(2);

    // b3 — Trusted User: profile fully set up with photo
    if (hasProfilePhoto && hasProfileSetup) await awardBadge(3);

    // b4 — Early Bird: user ID ≤ 100
    if (userId <= 100) await awardBadge(4);

    // b5 — Team Player: 3+ claimed
    if (claimedCount >= 3) await awardBadge(5);

    // b6 — Sharp Eye: 10+ posts with description
    if (postsWithDescription >= 10) await awardBadge(6);

    // b7 — Master Finder: 50+ found posts
    if (foundCount >= 50) await awardBadge(7);

    // b8 — Community Guardian: 20+ posts total
    if (totalPosts >= 20) await awardBadge(8);

    // b9 — Weekend Warrior: currently posting on a weekend
    if (isWeekend && totalPosts > 0) await awardBadge(9);

    // b10 — Night Owl: posting after 10 PM
    if (isNightTime && totalPosts > 0) await awardBadge(10);

    // b11 — Library Legend: 3+ posts in library location
    final libraryPosts = myItems
        .where((item) => item.location
            .toLowerCase()
            .contains('biblioth'))
        .length;
    if (libraryPosts >= 3) await awardBadge(11);

    // b12 — Gym Hero: 3+ posts in gym location
    final gymPosts = myItems
        .where((item) =>
            item.location.toLowerCase().contains('sport') ||
            item.location.toLowerCase().contains('gym'))
        .length;
    if (gymPosts >= 3) await awardBadge(12);

    // b13 — Cafeteria King: 3+ posts in restaurant location
    final cafePosts = myItems
        .where((item) => item.location.toLowerCase().contains('restaurant'))
        .length;
    if (cafePosts >= 3) await awardBadge(13);

    // b14 — Tech Genius: 5+ electronics posts
    final techPosts = myItems
        .where((item) =>
            item.category.toLowerCase() == 'electronics' ||
            _isTechItem(item.title))
        .length;
    if (techPosts >= 5) await awardBadge(14);

    // b15 — Key Master: 5+ key posts
    final keyPosts = myItems
        .where((item) => _isKeyItem(item.title))
        .length;
    if (keyPosts >= 5) await awardBadge(15);

    // b16 — Wallet Warrior: 5+ wallet posts
    final walletPosts = myItems
        .where((item) => _isWalletItem(item.title))
        .length;
    if (walletPosts >= 5) await awardBadge(16);

    // b17 — Phone Finder: 5+ phone posts
    final phonePosts = myItems
        .where((item) => _isPhoneItem(item.title))
        .length;
    if (phonePosts >= 5) await awardBadge(17);

    // b18 — Backpack Buddy: 5+ backpack posts
    final backpackPosts = myItems
        .where((item) => _isBackpackItem(item.title))
        .length;
    if (backpackPosts >= 5) await awardBadge(18);

    // b19 — ID Expert: 5+ ID posts
    final idPosts = myItems
        .where((item) => _isIdItem(item.title))
        .length;
    if (idPosts >= 5) await awardBadge(19);

    // b20 — Water Bottle Collector: 5+ water bottle posts
    final bottlePosts = myItems
        .where((item) => _isBottleItem(item.title))
        .length;
    if (bottlePosts >= 5) await awardBadge(20);

    // b21 — Umbrella Saver: 3+ umbrella posts
    final umbrellaPosts = myItems
        .where((item) => item.title.toLowerCase().contains('umbrella'))
        .length;
    if (umbrellaPosts >= 3) await awardBadge(21);

    // b22 — Charger Champion: 3+ charger posts
    final chargerPosts = myItems
        .where((item) => item.title.toLowerCase().contains('charger'))
        .length;
    if (chargerPosts >= 3) await awardBadge(22);

    // b23 — Glasses Guardian: 3+ glasses posts
    final glassesPosts = myItems
        .where((item) =>
            item.title.toLowerCase().contains('glass') ||
            item.title.toLowerCase().contains('lunette'))
        .length;
    if (glassesPosts >= 3) await awardBadge(23);

    // b24 — Notebook Ninja: 5+ notebook posts
    final notebookPosts = myItems
        .where((item) =>
            item.title.toLowerCase().contains('notebook') ||
            item.title.toLowerCase().contains('cahier'))
        .length;
    if (notebookPosts >= 5) await awardBadge(24);

    // b25 — Calculator Crusader: 3+ calculator posts
    final calcPosts = myItems
        .where((item) => item.title.toLowerCase().contains('calculat'))
        .length;
    if (calcPosts >= 3) await awardBadge(25);

    // b26 — Headphone Hero: 3+ headphone posts
    final headphonePosts = myItems
        .where((item) =>
            item.title.toLowerCase().contains('headphone') ||
            item.title.toLowerCase().contains('earphone') ||
            item.title.toLowerCase().contains('airpod'))
        .length;
    if (headphonePosts >= 3) await awardBadge(26);

    // b27 — Flash Drive Finder: 3+ USB posts
    final usbPosts = myItems
        .where((item) =>
            item.title.toLowerCase().contains('usb') ||
            item.title.toLowerCase().contains('flash drive'))
        .length;
    if (usbPosts >= 3) await awardBadge(27);

    // b28 — Watch Wizard: 3+ watch posts
    final watchPosts = myItems
        .where((item) => item.title.toLowerCase().contains('watch'))
        .length;
    if (watchPosts >= 3) await awardBadge(28);

    // b29 — Jewelry Journalist: 3+ jewelry posts
    final jewelryPosts = myItems
        .where((item) =>
            item.title.toLowerCase().contains('jewel') ||
            item.title.toLowerCase().contains('ring') ||
            item.title.toLowerCase().contains('necklace') ||
            item.title.toLowerCase().contains('bracelet'))
        .length;
    if (jewelryPosts >= 3) await awardBadge(29);
  }

  // ── Item type helpers ──────────────────────────────────────────────────────
  static bool _isTechItem(String title) {
    final t = title.toLowerCase();
    return t.contains('phone') ||
        t.contains('laptop') ||
        t.contains('tablet') ||
        t.contains('computer') ||
        t.contains('device');
  }

  static bool _isKeyItem(String title) {
    final t = title.toLowerCase();
    return t.contains('key') || t.contains('clé') || t.contains('cle');
  }

  static bool _isWalletItem(String title) {
    final t = title.toLowerCase();
    return t.contains('wallet') ||
        t.contains('purse') ||
        t.contains('portefeuille');
  }

  static bool _isPhoneItem(String title) {
    final t = title.toLowerCase();
    return t.contains('phone') ||
        t.contains('iphone') ||
        t.contains('samsung') ||
        t.contains('mobile');
  }

  static bool _isBackpackItem(String title) {
    final t = title.toLowerCase();
    return t.contains('backpack') ||
        t.contains('bag') ||
        t.contains('sac');
  }

  static bool _isIdItem(String title) {
    final t = title.toLowerCase();
    return t.contains('id') ||
        t.contains('card') ||
        t.contains('carte') ||
        t.contains('passport');
  }

  static bool _isBottleItem(String title) {
    final t = title.toLowerCase();
    return t.contains('bottle') ||
        t.contains('bouteille') ||
        t.contains('water');
  }
}
