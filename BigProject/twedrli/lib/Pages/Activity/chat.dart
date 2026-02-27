

  // ─── Section ─────────────────────────────────────────────────────────────

  import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:twedrli/Pages/activity.dart';

Widget _buildSection(String title, List<ActivityItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A8FA8),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildActivityTile(item),
                  if (index < items.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 76,
                      color: Color(0xFFECEDF2),
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

  Widget _buildActivityTile(ActivityItem item) {
    return Container(
      color: item.isUnread ? const Color(0xFFF0FFFE) : Colors.white,
      child: Stack(
        children: [
          if (item.isUnread)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: const Color(0xFF00BFAE)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(item),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildTypeIcon(item.type),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: item.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB0B4C8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7B8099),
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

  Widget _buildAvatar(ActivityItem item) {
    final config = _avatarConfig(item.type);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: config['bgColor'] as Color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (config['bgColor'] as Color).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: item.type == ActivityType.message
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _PersonPlaceholder(),
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

  Widget _buildTypeIcon(ActivityType type) {
    IconData icon;
    Color color;
    switch (type) {
      case ActivityType.approved:
      case ActivityType.recovered:
        icon = Icons.check_circle;
        color = const Color(0xFF00BFAE);
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

// ─── Person Placeholder ───────────────────────────────────────────────────────

class _PersonPlaceholder extends StatelessWidget {
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
                color: Colors.white.withOpacity(0.3),
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

class _PageShell extends StatelessWidget {
  final String title;
  final Color accentColor;
  final IconData icon;
  final Widget body;

  const _PageShell({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(icon, color: accentColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
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

// ─── Chat Page ───────────────────────────────────────────────────────────────

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {
        'name': 'Alex',
        'msg': 'Hey! I think I found your water bottle 👋',
        'time': '3h ago',
        'unread': true,
      },
      {
        'name': 'Jordan',
        'msg': 'Is this the umbrella you lost?',
        'time': '1d ago',
        'unread': false,
      },
      {
        'name': 'Campus Security',
        'msg': 'Please pick up your ID at the front desk.',
        'time': '1d ago',
        'unread': false,
      },
      {
        'name': 'Maya',
        'msg': 'Found your AirPods near the library!',
        'time': '2d ago',
        'unread': false,
      },
    ];

    return _PageShell(
      title: 'Chat',
      accentColor: const Color(0xFF9B59B6),
      icon: Icons.chat_bubble_rounded,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 0.5,
          indent: 76,
          color: Color(0xFFECEDF2),
        ),
        itemBuilder: (context, index) {
          final chat = chats[index];
          final isUnread = chat['unread'] as bool;
          return Container(
            color: isUnread ? const Color(0xFFFAF5FF) : Colors.white,
            child: Stack(
              children: [
                if (isUnread)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 3, color: const Color(0xFF9B59B6)),
                  ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF9B59B6).withOpacity(0.15),
                    child: Text(
                      (chat['name'] as String)[0],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9B59B6),
                      ),
                    ),
                  ),
                  title: Text(
                    chat['name'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  subtitle: Text(
                    chat['msg'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnread
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF7B8099),
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  trailing: Text(
                    chat['time'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0B4C8),
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