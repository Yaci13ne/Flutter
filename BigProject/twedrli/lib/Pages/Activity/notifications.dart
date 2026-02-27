
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:twedrli/Pages/activity.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 0.5,
          indent: 76,
          color: Color(0xFFECEDF2),
        ),
        itemBuilder: (context, index) {
          final n = notifications[index];
          final isUnread = n['unread'] as bool;
          final color = Color(n['color'] as int);
          return Container(
            color: isUnread ? const Color(0xFFF0FFFE) : Colors.white,
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
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(n['icon'] as IconData, color: color, size: 24),
                  ),
                  title: Text(
                    n['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  subtitle: Text(
                    n['desc'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7B8099),
                    ),
                  ),
                  trailing: Text(
                    n['time'] as String,
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
