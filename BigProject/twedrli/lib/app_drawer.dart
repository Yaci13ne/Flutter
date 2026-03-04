import 'dart:io';
import 'package:flutter/material.dart';
import 'package:twedrli/Pages/Settings.dart';
import 'package:twedrli/theme/theme_modifier.dart';
import 'package:twedrli/Pages/profile.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
              return ValueListenableBuilder<File?>(
                valueListenable: profileImageNotifier,
                builder: (context, profileImage, _) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage)
                              : null,
                          child: profileImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
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
        ],
      ),
    );
  }
}
