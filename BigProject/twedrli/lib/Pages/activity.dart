import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twedrli/Pages/Activity/chat.dart';
import 'package:twedrli/Pages/Activity/update.dart';
import 'package:twedrli/Pages/Activity/notifications.dart';
import 'package:twedrli/Pages/Activity/announcements.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/Login.dart';
import 'package:twedrli/Widgets/page_shell.dart';
import 'package:twedrli/main.dart'; // Import for themeModeNotifier if needed

void main() {
  runApp(const TwedrliApp());
}

class TwedrliApp extends StatelessWidget {
  const TwedrliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twedrli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFAE),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A2E),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFAE),
          brightness: Brightness.dark,
        ),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const ActivityScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// ACTIVITY DATA IS NOW HANDLED VIA activityNotifier in list.dart
// ─────────────────────────────────────────────

// ─── Main Screen ─────────────────────────────────────────────────────────────

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    _refreshActivity();
  }

  Future<void> _refreshActivity() async {
    final userId = loggedInUserIdNotifier.value;
    if (userId == null) return;

    // Fetch active chats to show recent messages in activity
    final chats = await TwedrliApi.getActiveChats(userId);
    final userNames = await TwedrliApi.getUserNames();

    final List<ActivityItem> messageActivities = chats.map((chat) {
      final contactId = chat['contact_id'] as int;
      final lastMsg = chat['last_message_at'] as String;
      final name = userNames[contactId] ?? 'User #$contactId';

      final lastText = chat['last_message'] as String? ??
          'You have an active conversation regarding a lost item.';

      return ActivityItem(
        title: 'Message from $name',
        subtitle: lastText,
        type: ActivityType.message,
        timestamp: DateTime.tryParse(lastMsg) ?? DateTime.now(),
        isUnread: false,
        userId: userId,
        relatedUserId: contactId,
      );
    }).toList();

    // Combine with existing activities and remove duplicates (by title/timestamp)
    final existing = activityNotifier.value;
    final Map<String, ActivityItem> combined = {};
    for (var act in [...existing, ...messageActivities]) {
      combined['${act.title}_${act.timestamp.millisecondsSinceEpoch}'] = act;
    }

    final sortedList = combined.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    activityNotifier.value = sortedList;
  }

  String _formatTime(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return 'recently';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.black54;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

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
                    color: const Color(0xFF00BFAE).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: Color(0xFF00BFAE),
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
                  'Sign in to see your notifications, matches, and chat history.',
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
                    backgroundColor: const Color(0xFF00BFAE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
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
            _buildHeader(theme, isDark),
            ValueListenableBuilder<List<ActivityItem>>(
              valueListenable: activityNotifier,
              builder: (context, activities, _) {
                final currentUserId = loggedInUserIdNotifier.value;
                final myActivities = activities
                    .where((a) => a.userId == null || a.userId == currentUserId)
                    .toList();

                final unreadNotifs = myActivities
                    .where((a) => a.isUnread && a.type != ActivityType.message)
                    .length;
                final unreadChats = myActivities
                    .where((a) => a.isUnread && a.type == ActivityType.message)
                    .length;

                return _buildNavButtons(
                  context,
                  theme,
                  isDark,
                  unreadNotifs: unreadNotifs,
                  unreadChats: unreadChats,
                );
              },
            ),
            Expanded(
              child: ValueListenableBuilder<List<ActivityItem>>(
                valueListenable: activityNotifier,
                builder: (context, allActivities, _) {
                  final currentUserId = loggedInUserIdNotifier.value;
                  final activities = allActivities
                      .where(
                          (a) => a.userId == null || a.userId == currentUserId)
                      .toList();

                  if (activities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded,
                              size: 64,
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No activity yet',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  final now = DateTime.now();
                  final today = activities
                      .where((a) => now.difference(a.timestamp).inDays < 1)
                      .toList();
                  final earlier = activities
                      .where((a) => now.difference(a.timestamp).inDays >= 1)
                      .toList();

                  return RefreshIndicator(
                    onRefresh: _refreshActivity,
                    color: theme.colorScheme.primary,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 80),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (today.isNotEmpty)
                          _buildSection('TODAY', today, theme, isDark),
                        if (earlier.isNotEmpty)
                          _buildSection('EARLIER', earlier, theme, isDark),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      color: theme.appBarTheme.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Container(
                color: theme.appBarTheme.backgroundColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation Buttons ──────────────────────────────────────────────────

  Widget _buildNavButtons(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required int unreadNotifs,
    required int unreadChats,
  }) {
    return Container(
      color: theme.appBarTheme.backgroundColor,
      child: Column(
        children: [
          // Red accent bar beneath the header
          Container(height: 2, color: const Color(0xFFFF3B3B)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildNavButton(
                  context,
                  label: 'Chat',
                  icon: Icons.chat_bubble_rounded,
                  badgeCount: unreadChats > 0 ? unreadChats : null,
                  color: const Color(0xFF9B59B6),
                  page: const ChatPage(),
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildNavButton(
                  context,
                  label: 'Notifications',
                  icon: Icons.notifications_rounded,
                  badgeCount: unreadNotifs > 0 ? unreadNotifs : null,
                  color: const Color(0xFF00BFAE),
                  page: const NotificationsPage(),
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildNavButton(
                  context,
                  label: 'Announcements',
                  icon: Icons.campaign_rounded,
                  color: const Color(0xFFE8840A),
                  page: const AnnouncementsPage(),
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildNavButton(
                  context,
                  label: 'Updates',
                  icon: Icons.update_rounded,
                  color: const Color(0xFF5A7AFF),
                  page: const UpdatesPage(),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Widget page,
    int? badgeCount,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.25 : 0.18),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 24),
                  if (badgeCount != null)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B3B),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section ─────────────────────────────────────────────────────────────

  Widget _buildSection(
    String title,
    List<ActivityItem> items,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[500] : const Color(0xFF8A8FA8),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildActivityTile(item, theme, isDark),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 76,
                      color:
                          isDark ? Colors.grey[800]! : const Color(0xFFECEDF2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Activity Tile ───────────────────────────────────────────────────────

  Widget _buildActivityTile(ActivityItem item, ThemeData theme, bool isDark) {
    final unreadColor = isDark
        ? theme.colorScheme.primary.withOpacity(0.15)
        : const Color(0xFFF0FFFE);

    return GestureDetector(
      onTap: () {
        // Mark as read
        if (item.isUnread) {
          final list = activityNotifier.value;
          final idx = list.indexOf(item);
          if (idx != -1) {
            list[idx] = item.copyWith(isUnread: false);
            activityNotifier.value = List.from(list);
          }
        }

        if (item.type == ActivityType.message) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(targetUserId: item.relatedUserId),
            ),
          );
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()));
        }
      },
      child: Container(
        color: item.isUnread
            ? unreadColor
            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        child: Stack(
          children: [
            if (item.isUnread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: theme.colorScheme.primary),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(item, isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildTypeIcon(item.type, theme),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: item.isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            Text(
                              item.displayTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[500]
                                    : const Color(0xFFB0B4C8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF7B8099),
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.type == ActivityType.match)
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10),
                            child: Row(
                              children: [
                                _buildActionBtn('Ignore', Colors.grey, isDark,
                                    () {
                                  activityNotifier.value = activityNotifier
                                      .value
                                      .where((a) => a != item)
                                      .toList();
                                }),
                                const SizedBox(width: 10),
                                _buildActionBtn('I think it\'s mine',
                                    const Color(0xFF00BFAE), isDark, () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const ChatPage()));
                                }),
                              ],
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

  Widget _buildActionBtn(
      String label, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ActivityItem item, bool isDark) {
    final config = _avatarConfig(item.type);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: config['bgColor'] as Color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (config['bgColor'] as Color).withOpacity(isDark ? 0.5 : 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: item.type == ActivityType.message
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _PersonPlaceholder(isDark: isDark),
            )
          : item.type == ActivityType.system
              ? Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 26,
                )
              : Center(
                  child: Icon(
                    config['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
    );
  }

  Map<String, dynamic> _avatarConfig(ActivityType type) {
    switch (type) {
      case ActivityType.approved:
        return {'bgColor': const Color(0xFF2D3561), 'icon': Icons.umbrella};
      case ActivityType.match:
        return {'bgColor': const Color(0xFFE8840A), 'icon': Icons.vpn_key};
      case ActivityType.message:
        return {'bgColor': const Color(0xFFEE8B6E), 'icon': Icons.person};
      case ActivityType.recovered:
        return {
          'bgColor': const Color(0xFF43A047),
          'icon': Icons.verified_rounded
        };
      case ActivityType.security:
        return {
          'bgColor': const Color(0xFFB0B4C8),
          'icon': Icons.person_outline,
        };
      case ActivityType.system:
        return {
          'bgColor': const Color(0xFFD8DCE8),
          'icon': Icons.phone_android,
        };
    }
  }

  Widget _buildTypeIcon(ActivityType type, ThemeData theme) {
    IconData icon;
    Color color;
    switch (type) {
      case ActivityType.approved:
      case ActivityType.recovered:
        icon = Icons.check_circle;
        color = theme.colorScheme.primary;
        break;
      case ActivityType.match:
        icon = Icons.search;
        color = const Color(0xFF5A7AFF);
        break;
      case ActivityType.message:
      case ActivityType.security:
        icon = Icons.chat_bubble;
        color = const Color(0xFF9B59B6);
        break;
      case ActivityType.system:
        return const SizedBox.shrink();
    }
    return Icon(icon, size: 15, color: color);
  }
}

// ─── Person Placeholder ───────────────────────────────────────────────────────

class _PersonPlaceholder extends StatelessWidget {
  final bool isDark;

  const _PersonPlaceholder({this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEE8B6E),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: -4,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isDark ? 0.2 : 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            top: 8,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 14, color: Color(0xFFEE8B6E)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Destination Pages ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Announcements Page ───────────────────────────────────────────────────────

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final announcements = [
      {
        'title': '🎉 Welcome to Twedrli v2.4!',
        'body':
            'We\'ve added new AI-powered matching, faster search, and a redesigned activity feed. Update now to get all the latest features.',
        'date': 'Feb 25, 2026',
        'tag': 'New Release',
        'tagColor': 0xFF00BFAE,
      },
      {
        'title': '📦 Lost & Found Fair — This Friday',
        'body':
            'Drop by the Student Union from 10am–4pm to claim items or drop off anything you\'ve found on campus.',
        'date': 'Feb 22, 2026',
        'tag': 'Campus Event',
        'tagColor': 0xFFE8840A,
      },
      {
        'title': '🔧 Scheduled Maintenance',
        'body':
            'The app will be unavailable on Sunday Feb 28 from 2–4am for infrastructure upgrades. We apologize for any inconvenience.',
        'date': 'Feb 20, 2026',
        'tag': 'Maintenance',
        'tagColor': 0xFF5A7AFF,
      },
    ];

    return PageShell(
      title: 'Announcements',
      accentColor: const Color(0xFFE8840A),
      icon: Icons.campaign_rounded,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final a = announcements[index];
          final tagColor = Color(a['tagColor'] as int);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a['tag'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tagColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        a['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey[500]
                              : const Color(0xFFB0B4C8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    a['title'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a['body'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? Colors.grey[400] : const Color(0xFF7B8099),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
