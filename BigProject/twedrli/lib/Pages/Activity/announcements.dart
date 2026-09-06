import 'package:flutter/material.dart';
import 'package:twedrli/Widgets/page_shell.dart';

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
