import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/Login.dart';
import 'package:twedrli/Pages/Settings.dart';
import 'package:twedrli/theme/theme_modifier.dart';
import 'package:twedrli/Pages/profile.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Reactive DrawerHeader ──────────────────────────────────────────
          ValueListenableBuilder<String>(
            valueListenable: displayNameNotifier,
            builder: (context, displayName, _) {
              return ValueListenableBuilder<Uint8List?>(
                valueListenable: profileImageNotifier,
                builder: (context, profileImage, _) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      ValueListenableBuilder<String>(
                          valueListenable: loggedInImgUrlNotifier,
                          builder: (context, imgUrl, _) {
                            return CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                backgroundImage: profileImage != null
                                  ? MemoryImage(profileImage) as ImageProvider
                                  : imgUrl.isNotEmpty
                                  ? (imgUrl.startsWith('data:image')
                                        ? MemoryImage(
                                                base64Decode(
                                                  imgUrl.split(',').last,
                                                ),
                                              )
                                              as ImageProvider
                                        : NetworkImage(imgUrl) as ImageProvider)
                                  : null,
                              child: (profileImage == null && imgUrl.isEmpty)
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  ValueListenableBuilder<String>(
                          valueListenable: usernameNotifier,
                          builder: (context, username, _) {
                            return Text(
                              username,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          // ──────────────────────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () => Navigator.pop(context),
          ),
        const Divider(),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                themeModeNotifier.value = value
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
            ),
            onTap: () {
              themeModeNotifier.value = isDark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              isGuestNotifier.value ? Icons.login_rounded : Icons.logout_rounded,
              color: isGuestNotifier.value ? const Color(0xFF2979FF) : const Color(0xFFE74C3C),
            ),
            title: Text(
              isGuestNotifier.value ? 'Sign In' : 'Sign Out',
              style: TextStyle(
                color: isGuestNotifier.value ? const Color(0xFF2979FF) : const Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
              ),
            ),
onTap: () async {
              if (isGuestNotifier.value) {
                isGuestNotifier.value = false;
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                return;
              }

              final navigator = Navigator.of(context, rootNavigator: true);
              Navigator.pop(context); // close drawer

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  content: const Text('Are you sure you want to sign out?'),
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                profileImageNotifier.value = null;
                displayNameNotifier.value = '';
                usernameNotifier.value = '';
                isGuestNotifier.value = false;

                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          
          ),
        ],
      ),
    );
  }
}
        
