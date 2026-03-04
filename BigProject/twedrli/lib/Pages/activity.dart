import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twedrli/Pages/Activity/chat.dart';
import 'package:twedrli/Pages/Activity/update.dart';
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

// ─── Data Models ────────────────────────────────────────────────────────────

enum ActivityType { approved, match, message, recovered, security, system }

class ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final ActivityType type;
  final bool isUnread;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    this.isUnread = false,
  });
}

final List<ActivityItem> todayItems = [
  ActivityItem(
    title: 'Post Approved',
    subtitle: 'Your "Black Umbrella" is now live on...',
    time: '2m ago',
    type: ActivityType.approved,
    isUnread: true,
  ),
  ActivityItem(
    title: 'Potential Match Found',
    subtitle: 'Someone posted keys that look like ...',
    time: '1h ago',
    type: ActivityType.match,
    isUnread: true,
  ),
  ActivityItem(
    title: 'Message from Alex',
    subtitle: '"Hey! I think I found your water bottl...',
    time: '3h ago',
    type: ActivityType.message,
  ),
];

final List<ActivityItem> yesterdayItems = [
  ActivityItem(
    title: 'Item Recovered!',
    subtitle: 'You marked "Sony Headphones" as f...',
    time: '1d ago',
    type: ActivityType.recovered,
  ),
  ActivityItem(
    title: 'Campus Security',
    subtitle: '"Please pick up your ID at the front d...',
    time: '1d ago',
    type: ActivityType.security,
  ),
  ActivityItem(
    title: 'New Match Suggestion',
    subtitle: 'Is this your "HydroFlask Blue"?',
    time: '1d ago',
    type: ActivityType.match,
  ),
];

final List<ActivityItem> earlierItems = [
  ActivityItem(
    title: 'System Update',
    subtitle: 'Twedrli v2.4 is now available.',
    time: '5d ago',
    type: ActivityType.system,
  ),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),
            _buildNavButtons(context, theme, isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _buildSection('TODAY', todayItems, theme, isDark),
                  const SizedBox(height: 8),
                  _buildSection('YESTERDAY', yesterdayItems, theme, isDark),
                  const SizedBox(height: 8),
                  _buildSection('EARLIER', earlierItems, theme, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      color: theme.appBarTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Mark all read',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation Buttons ──────────────────────────────────────────────────

  Widget _buildNavButtons(BuildContext context, ThemeData theme, bool isDark) {
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
                  badgeCount: 1,
                  color: const Color(0xFF9B59B6),
                  page: const ChatPage(),
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildNavButton(
                  context,
                  label: 'Notifications',
                  icon: Icons.notifications_rounded,
                  badgeCount: 2,
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
                      color: isDark
                          ? Colors.grey[800]!
                          : const Color(0xFFECEDF2),
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

    return Container(
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
                            item.time,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
        return {'bgColor': const Color(0xFF6B5B3E), 'icon': Icons.headphones};
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

class PageShell extends StatelessWidget {
  final String title;
  final Color accentColor;
  final IconData icon;
  final Widget body;

  const PageShell({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: theme.appBarTheme.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(icon, color: accentColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: accentColor),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

// ─── Notifications Page ───────────────────────────────────────────────────────

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final notifications = [
      {
        'icon': Icons.search,
        'title': 'Potential Match Found',
        'desc': 'Someone posted keys that match your lost item.',
        'time': '1h ago',
        'unread': true,
        'color': 0xFF5A7AFF,
      },
      {
        'icon': Icons.check_circle,
        'title': 'Post Approved',
        'desc': 'Your "Black Umbrella" post is now live.',
        'time': '2m ago',
        'unread': true,
        'color': 0xFF00BFAE,
      },
      {
        'icon': Icons.search,
        'title': 'New Match Suggestion',
        'desc': 'Is this your "HydroFlask Blue"?',
        'time': '1d ago',
        'unread': false,
        'color': 0xFF5A7AFF,
      },
      {
        'icon': Icons.check_circle,
        'title': 'Item Recovered!',
        'desc': 'You marked "Sony Headphones" as found.',
        'time': '1d ago',
        'unread': false,
        'color': 0xFF00BFAE,
      },
    ];

    return PageShell(
      title: 'Notifications',
      accentColor: const Color(0xFF00BFAE),
      icon: Icons.notifications_rounded,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.5,
          indent: 76,
          color: isDark ? Colors.grey[800]! : const Color(0xFFECEDF2),
        ),
        itemBuilder: (context, index) {
          final n = notifications[index];
          final isUnread = n['unread'] as bool;
          final color = Color(n['color'] as int);
          final unreadColor = isDark
              ? const Color(0xFF00BFAE).withOpacity(0.15)
              : const Color(0xFFF0FFFE);

          return Container(
            color: isUnread
                ? unreadColor
                : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
            child: Stack(
              children: [
                if (isUnread)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 3, color: const Color(0xFF00BFAE)),
                  ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(n['icon'] as IconData, color: color, size: 24),
                  ),
                  title: Text(
                    n['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  subtitle: Text(
                    n['desc'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey[400]
                          : const Color(0xFF7B8099),
                    ),
                  ),
                  trailing: Text(
                    n['time'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey[500]
                          : const Color(0xFFB0B4C8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
                      color: isDark
                          ? Colors.grey[400]
                          : const Color(0xFF7B8099),
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
