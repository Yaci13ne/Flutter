import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Settings.dart';
import 'loginscreen.dart';
import 'user_provider.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback toggleDarkMode;
  final bool isDarkMode;

  const Sidebar(
      {super.key, required this.toggleDarkMode, required this.isDarkMode});

@override
Widget build(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context);

  return Drawer(
    child: Container(
      color: isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userProvider.user.name,
              style: TextStyle(
                color: isDarkMode
                    ? const Color.fromARGB(255, 243, 240, 240)
                    : const Color.fromARGB(255, 0, 0, 0),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              userProvider.user.email,
              style: TextStyle(
                  color: isDarkMode
                      ? const Color.fromARGB(255, 243, 240, 240)
                      : const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Roboto'),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: userProvider.user.profileImage != null
                  ? FileImage(userProvider.user.profileImage!)
                  : const NetworkImage(
                      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop",
                    ) as ImageProvider,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 76, 175, 80),
                  isDarkMode
                      ? const Color.fromARGB(255, 18, 18, 18)
                      : const Color.fromARGB(255, 255, 255, 255)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SizedBox(height: 20),
        
          _buildDrawerItem(
            Icons.settings,
            "Settings",
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    toggleDarkMode:
                        toggleDarkMode, // Pass the same function from Sidebar
                    isDarkMode: isDarkMode, // Pass the same value from Sidebar
                  ),
                ),
              );
            },
          ),
          _buildDrawerItem(Icons.mail, "Contact Us",
              onTap: () => _contactSupport(context)),
          SizedBox(height: 50),
          Divider(),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: isDarkMode
                    ? Color.fromARGB(255, 243, 240, 240)
                    : const Color.fromARGB(255, 0, 0, 0)),
            title: Text("Dark Mode",
                style: TextStyle(
                    color: isDarkMode
                        ? Color.fromARGB(255, 243, 240, 240)
                        : const Color.fromARGB(255, 0, 0, 0))),
            onTap: toggleDarkMode,
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Log out", style: TextStyle(color: Colors.red)),
            onTap: () {
      Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );            },
          ),
        ],
      ),
    )  );
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon,
          color: isDarkMode
              ? Color.fromARGB(255, 255, 255, 255)
              : const Color.fromARGB(255, 0, 0, 0)),
      title: Text(title,
          style: TextStyle(
              color: isDarkMode
                  ? Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 0, 0, 0))),
      onTap: onTap,
    );
  }

  void _contactSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Contact Support')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                    'Have questions or need help? Reach out to our support team.',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email Us'),
                  subtitle: const Text('support@gymfitx.com'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
