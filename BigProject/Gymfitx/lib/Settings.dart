import 'package:flutter/material.dart';
import 'package:flutter_application_1/tutorial.dart';
import 'package:provider/provider.dart';
import 'legal_pages.dart';
import 'loginscreen.dart';
import 'user_provider.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleDarkMode;
  final bool isDarkMode;

  const SettingsScreen({
    super.key, 
    required this.toggleDarkMode,
    required this.isDarkMode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _mealReminders = false;
  String _selectedDiet = 'Balanced';

  final List<String> _dietOptions = [
    'Balanced', 'Keto', 'Vegetarian', 'Vegan', 'Paleo', 'Low-Carb', 'Mediterranean'
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Profile'),
            _buildProfileCard(userProvider, isDarkMode),
            const SizedBox(height: 24),
            _buildSectionHeader('Nutrition Preferences'),
            _buildDietPreferenceDropdown(),
            const SizedBox(height: 16),
      
            const SizedBox(height: 24),
            _buildSectionHeader('Notifications'),
            _buildSettingSwitch(
              title: 'Enable Notifications',
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildSettingSwitch(
              title: 'Meal Reminders',
              value: _mealReminders,
              onChanged: (val) => setState(() => _mealReminders = val),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Appearance'),
    ListTile(
            leading: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, 
                color: isDarkMode ? Color.fromARGB(255, 243, 240, 240) : const Color.fromARGB(255, 0, 0, 0)),
            title: Text("Dark Mode", 
                style: TextStyle(color: isDarkMode ? Color.fromARGB(255, 243, 240, 240) : const Color.fromARGB(255, 0, 0, 0))),
            onTap: widget.toggleDarkMode,
          ),
            const SizedBox(height: 24),
            _buildSectionHeader('Help & Support'),
            _buildActionTile(title: 'FAQ', icon: Icons.help_outline, onTap: () => _showFaqDialog(context)),
            _buildActionTile(title: 'Contact Support', icon: Icons.support_agent, onTap: () => _contactSupport(context)),
            _buildActionTile(title: 'Tutorial', icon: Icons.school_outlined, onTap: () => _showTutorial(context)),
            const SizedBox(height: 16),
            _buildSectionHeader('About'),
            _buildActionTile(title: 'Privacy Policy', icon: Icons.privacy_tip_outlined, onTap: () => _openPrivacyPolicy(context)),
            _buildActionTile(title: 'Terms of Service', icon: Icons.description_outlined, onTap: () => _openTermsOfService(context)),
            _buildActionTile(
              title: 'App Version', 
              icon: Icons.info_outline, 
              onTap: () => _showAppVersionDialog(context),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Account'),
            _buildActionTile(title: 'Change Password', icon: Icons.lock_outline, onTap: () {}),
            _buildActionTile(title: 'Logout', icon: Icons.logout, color: Colors.orange, onTap: () => _confirmLogout(context)),
            _buildActionTile(title: 'Delete Account', icon: Icons.delete_outline, color: Colors.red, onTap: () => _confirmDeleteAccount(context)),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'GymfitX v1.0.0',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _buildProfileCard(UserProvider userProvider, bool isDarkMode) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              backgroundImage: userProvider.user.profileImage != null
                  ? FileImage(userProvider.user.profileImage!)
                  : const NetworkImage(
                      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop",
                    ) as ImageProvider,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProvider.user.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProvider.user.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPreferenceDropdown() {
    return _buildSettingDropdown(
      label: 'Diet Preference',
      value: _selectedDiet,
      options: _dietOptions,
      onChanged: (val) => setState(() {
        if (val != null) _selectedDiet = val;
      }),
    );
  }

  Widget _buildSettingDropdown({
    required String label,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showFaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFaqItem(
                question: 'How do I change my profile picture?', 
                answer: 'Go to your Profile screen and tap on your profile picture.'
              ),
              const Divider(),
              _buildFaqItem(
                question: 'How do I track my macros?', 
                answer: 'Go to the Dashboard in home page.'
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

  Widget _buildFaqItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(answer),
        ],
      ),
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
                const Text('Have questions or need help? Reach out to our support team.', style: TextStyle(fontSize: 16)),
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

  void _showAppVersionDialog(BuildContext context) {
    final packageInfo = PackageInfo(
      appName: 'GymfitX',
      packageName: 'com.gymfitx.app',
      version: '1.1.0',
      buildNumber: '10100',
      buildSignature: '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionInfoRow('App Name', packageInfo.appName),
            _buildVersionInfoRow('Version', '${packageInfo.version} (${packageInfo.buildNumber})'),
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

  Widget _buildVersionInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

void _showTutorial(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TutorialPage()), // Navigate to TutorialPage
  );
}

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
    );
  }

  void _openTermsOfService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PackageInfo {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildSignature;

  PackageInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
  });
}