import 'package:flutter/material.dart';
import 'package:twedrli/Pages/Login.dart';
import 'package:twedrli/Pages/TutorialPage.dart';
import 'package:twedrli/theme/theme_modifier.dart';
import 'package:twedrli/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _matchAlerts = true;
  bool _messageAlerts = true;
  bool _saveHistory = true;

  String _selectedDistance = '1 km';
  String _selectedSort = 'Newest First';
  String _selectedLanguage = 'English';

  final List<String> _distanceOptions = [
    '500 m',
    '1 km',
    '2 km',
    '5 km',
    '10 km',
  ];
  final List<String> _sortOptions = [
    'Newest First',
    'Oldest First',
    'Most Relevant',
  ];
  final List<String> _languageOptions = [
    'English',
    'French',
    'Spanish',
    'Arabic',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionHeader('Profile', isDark),
            _buildProfileCard(isDark),
            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader('Appearance', isDark),
            _buildThemeToggle(isDark, primaryColor),
            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionHeader('Notifications', isDark),
            _buildSettingSwitch(
              title: 'Enable Notifications',
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
              isDark: isDark,
            ),
            if (_notificationsEnabled) ...[
              _buildSettingSwitch(
                title: 'Email Notifications',
                value: _emailNotifications,
                onChanged: (val) => setState(() => _emailNotifications = val),
                isDark: isDark,
              ),
              _buildSettingSwitch(
                title: 'Push Notifications',
                value: _pushNotifications,
                onChanged: (val) => setState(() => _pushNotifications = val),
                isDark: isDark,
              ),
              _buildSettingSwitch(
                title: 'Match Alerts',
                value: _matchAlerts,
                onChanged: (val) => setState(() => _matchAlerts = val),
                isDark: isDark,
              ),
              _buildSettingSwitch(
                title: 'Message Alerts',
                value: _messageAlerts,
                onChanged: (val) => setState(() => _messageAlerts = val),
                isDark: isDark,
              ),
            ],
            const SizedBox(height: 16),

            // Search Preferences
            _buildSectionHeader('Search Preferences', isDark),
            _buildSettingDropdown(
              label: 'Search Radius',
              value: _selectedDistance,
              options: _distanceOptions,
              onChanged: (val) => setState(() => _selectedDistance = val!),
              isDark: isDark,
            ),
            _buildSettingDropdown(
              label: 'Default Sort',
              value: _selectedSort,
              options: _sortOptions,
              onChanged: (val) => setState(() => _selectedSort = val!),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Language
            _buildSectionHeader('Language', isDark),
            _buildSettingDropdown(
              label: 'App Language',
              value: _selectedLanguage,
              options: _languageOptions,
              onChanged: (val) => setState(() => _selectedLanguage = val!),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Privacy
            _buildSectionHeader('Privacy', isDark),
            _buildSettingSwitch(
              title: 'Save Search History',
              value: _saveHistory,
              onChanged: (val) => setState(() => _saveHistory = val),
              isDark: isDark,
              subtitle: 'Allow app to remember your searches',
            ),
            const SizedBox(height: 24),

            // Help & Support
            _buildSectionHeader('Help & Support', isDark),
            _buildActionTile(
              title: 'FAQ',
              icon: Icons.help_outline,
              onTap: () => _showFaqDialog(context, isDark),
              isDark: isDark,
            ),
            _buildActionTile(
              title: 'Contact Support',
              icon: Icons.support_agent,
              onTap: () => _contactSupport(context, isDark),
              isDark: isDark,
            ),
            _buildActionTile(
              title: 'Tutorial',
              icon: Icons.school_outlined,
              onTap: () => _showTutorial(context),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // About
            _buildSectionHeader('About', isDark),
            _buildActionTile(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => _openPrivacyPolicy(context, isDark),
              isDark: isDark,
            ),
            _buildActionTile(
              title: 'Terms of Service',
              icon: Icons.description_outlined,
              onTap: () => _openTermsOfService(context, isDark),
              isDark: isDark,
            ),
            _buildActionTile(
              title: 'App Version',
              icon: Icons.info_outline,
              onTap: () => _showAppVersionDialog(context, isDark),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Account
            _buildSectionHeader('Account', isDark),
            _buildActionTile(
              title: 'Change Password',
              icon: Icons.lock_outline,
              onTap: () => _showComingSoon(context),
              isDark: isDark,
            ),
            _buildActionTile(
              title: 'Logout',
              icon: Icons.logout,
              color: Colors.orange,
              onTap: () => _confirmLogout(context),
              isDark: isDark,
            ),
            _buildActionTile(
              title: 'Delete Account',
              icon: Icons.delete_outline,
              color: Colors.red,
              onTap: () => _confirmDeleteAccount(context),
              isDark: isDark,
            ),
            const SizedBox(height: 32),

            // Version
            Center(
              child: Text(
                'Twedrli v2.4.0',
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: isDark ? Colors.grey[800] : Colors.blue[50],
              backgroundImage: const AssetImage(
                'assets/profile_placeholder.png',
              ),
              child: const Icon(Icons.person, size: 30, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alex Rivers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@arivers_24',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Computer Science',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: isDark ? Colors.blue[400] : Colors.blue,
              ),
              onPressed: () => _showComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark, Color primaryColor) {
    return ListTile(
      leading: Icon(
        isDark ? Icons.nightlight_round : Icons.wb_sunny,
        color: isDark ? Colors.amber : primaryColor,
      ),
      title: Text(
        "Dark Mode",
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: (value) {
          themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
        },
        activeColor: primaryColor,
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required void Function(bool) onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSettingDropdown({
    required String label,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final iconColor = color ?? (isDark ? Colors.blue[400] : Colors.blue);

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showFaqDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Frequently Asked Questions',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFaqItem(
                context,
                question: 'How do I report a lost item?',
                answer:
                    'Tap the + button on the home screen and fill out the form with item details and photos.',
                isDark: isDark,
              ),
              const Divider(),
              _buildFaqItem(
                context,
                question: 'How do I claim a found item?',
                answer:
                    'Navigate to the item details and tap the "Claim Item" button. The finder will be notified.',
                isDark: isDark,
              ),
              const Divider(),
              _buildFaqItem(
                context,
                question: 'How does the matching system work?',
                answer:
                    'Our AI compares lost and found items based on description, color, category, and location.',
                isDark: isDark,
              ),
              const Divider(),
              _buildFaqItem(
                context,
                question: 'Is my contact information private?',
                answer:
                    'Yes, your contact info is only shared when you initiate contact about an item.',
                isDark: isDark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Contact Support',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.email,
                color: isDark ? Colors.blue[400] : Colors.blue,
              ),
              title: Text(
                'Email Us',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              subtitle: Text(
                'support@twedrli.com',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email client...')),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.chat,
                color: isDark ? Colors.blue[400] : Colors.blue,
              ),
              title: Text(
                'Live Chat',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              subtitle: Text(
                'Available 24/7',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting live chat...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTutorial(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening tutorial...')));
  }

  void _openPrivacyPolicy(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your privacy is important to us. This policy explains how we collect, use, and protect your personal information.',
              ),
              const SizedBox(height: 16),
              Text(
                'Last updated: February 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _openTermsOfService(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Terms of Service',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'By using Twedrli, you agree to these terms. Please read them carefully before using our services.',
              ),
              const SizedBox(height: 16),
              Text(
                'Version 2.4',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agree'),
          ),
        ],
      ),
    );
  }

  void _showAppVersionDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'App Information',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionInfoRow('App Name', 'Twedrli', isDark),
            _buildVersionInfoRow('Version', '2.4.0', isDark),
            _buildVersionInfoRow('Build', '2026.02.28', isDark),
            _buildVersionInfoRow('Platform', 'iOS / Android', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Delete Account',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
