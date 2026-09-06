import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Widgets/page_shell.dart';
import 'package:twedrli/Pages/Activity/chat.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScanOverlay(context),
        backgroundColor: const Color(0xFF00BFAE),
        icon: const Icon(Icons.radar, color: Colors.white),
        label: const Text(
          'Scan for Matches',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: PageShell(
        title: 'Notifications',
        accentColor: const Color(0xFF00BFAE),
        icon: Icons.notifications_rounded,
        body: ValueListenableBuilder<List<ActivityItem>>(
          valueListenable: activityNotifier,
          builder: (context, allActivities, _) {
            final currentUserId = loggedInUserIdNotifier.value;
            final activities = allActivities.where((a) => a.userId == null || a.userId == currentUserId).toList();

            if (activities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 64,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: activities.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 0.5,
                indent: 76,
                color: isDark ? Colors.grey[800]! : const Color(0xFFECEDF2),
              ),
              itemBuilder: (context, index) {
                final n = activities[index];
                final isUnread = n.isUnread;

                // Map types to icons/colors
                IconData icon;
                Color color;
                switch (n.type) {
                  case ActivityType.approved:
                    icon = Icons.check_circle;
                    color = const Color(0xFF00BFAE);
                    break;
                  case ActivityType.match:
                    icon = Icons.search;
                    color = const Color(0xFF5A7AFF);
                    break;
                  case ActivityType.message:
                    icon = Icons.chat_bubble;
                    color = const Color(0xFF9B59B6);
                    break;
                  case ActivityType.recovered:
                    icon = Icons.verified;
                    color = const Color(0xFFE8840A);
                    break;
                  case ActivityType.security:
                    icon = Icons.security;
                    color = Colors.grey;
                    break;
                  case ActivityType.system:
                    icon = Icons.info;
                    color = const Color(0xFF00BFAE);
                    break;
                }

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
                          child: Container(
                            width: 3,
                            color: const Color(0xFF00BFAE),
                          ),
                        ),
                      Column(
                        children: [
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
                              child: Icon(icon, color: color, size: 24),
                            ),
                            title: Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            subtitle: Text(
                              n.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : const Color(0xFF7B8099),
                              ),
                            ),
                            onTap: () {
                              if (n.isUnread) {
                                final list = activityNotifier.value;
                                final idx = list.indexOf(n);
                                if (idx != -1) {
                                  list[idx] = n.copyWith(isUnread: false);
                                  activityNotifier.value = List.from(list);
                                }
                              }
                            },
                            trailing: Text(
                              n.displayTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[500]
                                    : const Color(0xFFB0B4C8),
                              ),
                            ),
                          ),
                          if (n.type == ActivityType.match)
                            Padding(
                              padding: const EdgeInsets.only(left: 76, bottom: 12),
                              child: Row(
                                children: [
                                  _buildActionBtn('Ignore', Colors.grey, isDark, () {
                                    activityNotifier.value = activityNotifier.value
                                        .where((a) => a != n)
                                        .toList();
                                  }),
                                  const SizedBox(width: 10),
                                  _buildActionBtn('I think it\'s mine', const Color(0xFF00BFAE), isDark, () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
                                  }),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, bool isDark, VoidCallback onTap) {
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
  void _showScanOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ScanOverlay(),
    );
  }
}

class _ScanOverlay extends StatefulWidget {
  const _ScanOverlay();

  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        final newMatches = TwedrliApi.checkPotentialMatches();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newMatches > 0 
                ? 'Scan complete! Found $newMatches potential matches.' 
                : 'Scan complete! No new matches found.'),
            backgroundColor: const Color(0xFF00BFAE),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: _RadarPainter(_controller.value),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Scanning for Matches...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Using AI to compare your lost items\nwith recently found reports',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..color = const Color(0xFF00BFAE).withOpacity(1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, maxRadius * progress, paint);
    canvas.drawCircle(center, maxRadius * (progress > 0.5 ? progress - 0.5 : progress + 0.5), paint..color = paint.color.withOpacity((1-progress).clamp(0, 1)));

    final corePaint = Paint()
      ..color = const Color(0xFF00BFAE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
