import 'package:flutter/material.dart';
import 'package:twedrli/Pages/profile.dart';
import 'package:twedrli/theme/theme_modifier.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5BC8F5), Color(0xFF1A8CDB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ─── Avatar (synced with ProfileScreen) ───────────────────────
              ValueListenableBuilder(
                valueListenable: profileImageNotifier,
                builder: (context, profileImage, _) {
                  return CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: profileImage != null
                          ? Image.file(
                              profileImage,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/profile.png',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF1A8CDB),
                              ),
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ─── Name ─────────────────────────────────────────────────────
              const Text(
                'Alex Rivers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 4),

              // ─── Email ────────────────────────────────────────────────────
              const Text(
                'yacine123@gmail.com',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 24),

              const Divider(
                color: Colors.white30,
                thickness: 1,
                indent: 24,
                endIndent: 24,
              ),

              const SizedBox(height: 8),

              // ─── Menu Items ───────────────────────────────────────────────
              _DrawerItem(
                icon: Icons.person_outline,
                label: 'My profile',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.mail_outline,
                label: 'Contact Us',
                onTap: () => Navigator.pop(context),
              ),

              // ─── Dark Mode Toggle ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.nightlight_round_outlined,
                      color: Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // ✅ Reads & writes the global notifier — no local state needed
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeModeNotifier,
                      builder: (context, themeMode, _) {
                        return Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (val) {
                            themeModeNotifier.value = val
                                ? ThemeMode.dark
                                : ThemeMode.light;
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.white38,
                          inactiveThumbColor: Colors.white70,
                          inactiveTrackColor: Colors.white24,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const Divider(
                color: Colors.white30,
                thickness: 1,
                indent: 24,
                endIndent: 24,
              ),

              // ─── Log Out ──────────────────────────────────────────────────
              _DrawerItem(
                icon: Icons.logout,
                label: 'Log out',
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
    );
  }
}
