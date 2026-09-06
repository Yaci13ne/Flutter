import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:twedrli/Lists/list.dart';
import 'package:twedrli/Pages/Login.dart';
import 'package:twedrli/Pages/TutorialPage.dart';
import 'package:twedrli/Pages/profile.dart';
import 'package:twedrli/Pages/setup_profile_screen.dart';
import 'package:twedrli/theme/theme_modifier.dart';
import 'package:twedrli/main.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  // ── Notification toggles ────────────────────────────────────────────────────
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _matchAlerts = true;
  bool _messageAlerts = true;
  bool _weeklyDigest = false;

  // ── Quiet hours ─────────────────────────────────────────────────────────────
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);

  // ── Privacy & history ───────────────────────────────────────────────────────
  bool _saveHistory = true;
  bool _locationEnabled = true;
  bool _analyticsEnabled = true;
  bool _personalisedAds = false;

  // ── Security ────────────────────────────────────────────────────────────────
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  bool _loginAlerts = true;

  // ── Accessibility (Now using global notifiers) ──────────────────────────────

  // ── Search preferences (Now using global notifiers) ─────────────────────────

  // ── Options ─────────────────────────────────────────────────────────────────
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

  // ── Blocked users (mock) ────────────────────────────────────────────────────
  final List<Map<String, String>> _blockedUsers = [
    {'name': 'Jordan Blake', 'handle': '@jblake'},
    {'name': 'Sam Torres', 'handle': '@storres99'},
  ];

  // ── Cache size (mock) ───────────────────────────────────────────────────────
  String _cacheSize = '47.3 MB';

  // ── Animation controller ────────────────────────────────────────────────────
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F12) : const Color(0xFFF4F6FA),
      appBar: _buildAppBar(isDark, scheme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile ────────────────────────────────────────────────────
              _section('Profile', isDark),
              _profileCard(isDark, scheme),
              const SizedBox(height: 24),

              // ── Appearance ─────────────────────────────────────────────────
              _section('Appearance', isDark),
              _card(isDark, [
                _themeToggle(isDark, scheme),
                _divider(isDark),
                ValueListenableBuilder<double>(
                  valueListenable: textScaleNotifier,
                  builder: (context, scale, _) =>
                      _accessibilitySlider(isDark, scheme, scale),
                ),
                _divider(isDark),
                ValueListenableBuilder<bool>(
                  valueListenable: reduceMotionNotifier,
                  builder: (context, value, _) => _switchTile(
                    title: 'Reduce Motion',
                    subtitle: 'Minimise animations throughout the app',
                    icon: Icons.animation_outlined,
                    value: value,
                    onChanged: (v) => reduceMotionNotifier.value = v,
                    isDark: isDark,
                    scheme: scheme,
                  ),
                ),
                _divider(isDark),
                ValueListenableBuilder<bool>(
                  valueListenable: highContrastNotifier,
                  builder: (context, value, _) => _switchTile(
                    title: 'High Contrast',
                    subtitle: 'Improve readability with stronger contrast',
                    icon: Icons.contrast_outlined,
                    value: value,
                    onChanged: (v) => highContrastNotifier.value = v,
                    isDark: isDark,
                    scheme: scheme,
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // ── Notifications ──────────────────────────────────────────────
              _section('Notifications', isDark),
              _card(isDark, [
                _switchTile(
                  title: 'Enable Notifications',
                  subtitle: 'Receive all app notifications',
                  icon: Icons.notifications_outlined,
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  isDark: isDark,
                  scheme: scheme,
                ),
                if (_notificationsEnabled) ...[
                  _divider(isDark),
                  _switchTile(
                    title: 'Email Notifications',
                    icon: Icons.email_outlined,
                    value: _emailNotifications,
                    onChanged: (v) => setState(() => _emailNotifications = v),
                    isDark: isDark,
                    scheme: scheme,
                  ),
                  _divider(isDark),
                  _switchTile(
                    title: 'Push Notifications',
                    icon: Icons.mobile_friendly_outlined,
                    value: _pushNotifications,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                    isDark: isDark,
                    scheme: scheme,
                  ),
                  _divider(isDark),
                  _switchTile(
                    title: 'Match Alerts',
                    icon: Icons.link_outlined,
                    value: _matchAlerts,
                    onChanged: (v) => setState(() => _matchAlerts = v),
                    isDark: isDark,
                    scheme: scheme,
                  ),
                  _divider(isDark),
                  _switchTile(
                    title: 'Message Alerts',
                    icon: Icons.chat_bubble_outline,
                    value: _messageAlerts,
                    onChanged: (v) => setState(() => _messageAlerts = v),
                    isDark: isDark,
                    scheme: scheme,
                  ),
                  _divider(isDark),
                  _switchTile(
                    title: 'Weekly Digest',
                    subtitle: 'Summary email every Monday',
                    icon: Icons.calendar_today_outlined,
                    value: _weeklyDigest,
                    onChanged: (v) => setState(() => _weeklyDigest = v),
                    isDark: isDark,
                    scheme: scheme,
                  ),
                  _divider(isDark),
                  _switchTile(
                    title: 'Quiet Hours',
                    subtitle: _quietHoursEnabled
                        ? '${_quietStart.format(context)} – ${_quietEnd.format(context)}'
                        : 'Mute notifications at set times',
                    icon: Icons.do_not_disturb_on_outlined,
                    value: _quietHoursEnabled,
                    onChanged: (v) => setState(() => _quietHoursEnabled = v),
                    isDark: isDark,
                    scheme: scheme,
                    trailing: _quietHoursEnabled
                        ? TextButton(
                            onPressed: () => _pickQuietHours(context, isDark),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ]),
              const SizedBox(height: 24),

              // ── Security ───────────────────────────────────────────────────
              _section('Security', isDark),
              _card(isDark, [
                _switchTile(
                  title: 'Two-Factor Authentication',
                  subtitle: _twoFactorEnabled
                      ? 'Enabled via authenticator app'
                      : 'Add an extra layer of security',
                  icon: Icons.verified_user_outlined,
                  value: _twoFactorEnabled,
                  onChanged: (v) => _toggle2FA(context, v, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                  accentColor: Colors.green,
                ),
                _divider(isDark),
                _switchTile(
                  title: 'Biometric Login',
                  subtitle: 'Use Face ID or fingerprint to log in',
                  icon: Icons.fingerprint_outlined,
                  value: _biometricEnabled,
                  onChanged: (v) => setState(() => _biometricEnabled = v),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _switchTile(
                  title: 'Login Alerts',
                  subtitle: 'Get notified of new sign-ins',
                  icon: Icons.login_outlined,
                  value: _loginAlerts,
                  onChanged: (v) => setState(() => _loginAlerts = v),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Change Password',
                  subtitle: 'Last changed 3 months ago',
                  icon: Icons.lock_outline,
                  onTap: () =>
                      _showChangePasswordDialog(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Active Sessions',
                  subtitle: '2 devices currently signed in',
                  icon: Icons.devices_outlined,
                  onTap: () => _showActiveSessions(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
              ]),
              const SizedBox(height: 24),

              // ── Search Preferences ─────────────────────────────────────────
              _section('Search Preferences', isDark),
              _card(isDark, [
                ValueListenableBuilder<String>(
                  valueListenable: searchRadiusNotifier,
                  builder: (context, value, _) => _dropdownTile(
                    label: 'Search Radius',
                    icon: Icons.radar_outlined,
                    value: value,
                    options: _distanceOptions,
                    onChanged: (v) => searchRadiusNotifier.value = v!,
                    isDark: isDark,
                    scheme: scheme,
                  ),
                ),
                _divider(isDark),
                ValueListenableBuilder<String>(
                  valueListenable: defaultSortNotifier,
                  builder: (context, value, _) => _dropdownTile(
                    label: 'Default Sort',
                    icon: Icons.sort_outlined,
                    value: value,
                    options: _sortOptions,
                    onChanged: (v) => defaultSortNotifier.value = v!,
                    isDark: isDark,
                    scheme: scheme,
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // ── Language ───────────────────────────────────────────────────
              _section('Language & Region', isDark),
              _card(isDark, [
                ValueListenableBuilder<String>(
                  valueListenable: appLanguageNotifier,
                  builder: (context, value, _) => _dropdownTile(
                    label: 'App Language',
                    icon: Icons.language_outlined,
                    value: value,
                    options: _languageOptions,
                    onChanged: (v) => appLanguageNotifier.value = v!,
                    isDark: isDark,
                    scheme: scheme,
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // ── Privacy ────────────────────────────────────────────────────
              _section('Privacy', isDark),
              _card(isDark, [
                _switchTile(
                  title: 'Save Search History',
                  subtitle: 'Remember recent searches',
                  icon: Icons.history_outlined,
                  value: _saveHistory,
                  onChanged: (v) => setState(() => _saveHistory = v),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _switchTile(
                  title: 'Location Services',
                  subtitle: 'Enable precise location for nearby items',
                  icon: Icons.location_on_outlined,
                  value: _locationEnabled,
                  onChanged: (v) => setState(() => _locationEnabled = v),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _switchTile(
                  title: 'Analytics & Diagnostics',
                  subtitle: 'Help improve the app with usage data',
                  icon: Icons.bar_chart_outlined,
                  value: _analyticsEnabled,
                  onChanged: (v) => setState(() => _analyticsEnabled = v),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _switchTile(
                  title: 'Personalised Ads',
                  subtitle: 'Use activity to show relevant ads',
                  icon: Icons.ads_click_outlined,
                  value: _personalisedAds,
                  onChanged: (v) => setState(() => _personalisedAds = v),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Blocked Users',
                  subtitle: '${_blockedUsers.length} blocked',
                  icon: Icons.block_outlined,
                  onTap: () => _showBlockedUsers(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
              ]),
              const SizedBox(height: 24),

              // ── Data & Storage ─────────────────────────────────────────────
              _section('Data & Storage', isDark),
              _card(isDark, [
                _actionTile(
                  title: 'Cache',
                  subtitle: _cacheSize,
                  icon: Icons.storage_outlined,
                  onTap: () => _clearCache(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                  trailingLabel: 'Clear',
                  trailingColor: Colors.orange,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Export My Data',
                  subtitle: 'Download a copy of your account data',
                  icon: Icons.download_outlined,
                  onTap: () => _exportData(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Backup & Sync',
                  subtitle: 'Last backed up: Today at 09:14',
                  icon: Icons.backup_outlined,
                  onTap: () => _runBackup(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
              ]),
              const SizedBox(height: 24),

              // ── Help & Support ─────────────────────────────────────────────
              _section('Help & Support', isDark),
              _card(isDark, [
                _actionTile(
                  title: 'FAQ',
                  icon: Icons.help_outline,
                  onTap: () => _showFaqDialog(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Contact Support',
                  subtitle: 'Available 24/7',
                  icon: Icons.support_agent_outlined,
                  onTap: () => _contactSupport(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Tutorial',
                  subtitle: 'Re-watch the onboarding guide',
                  icon: Icons.school_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TutorialPage()),
                  ),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Send Feedback',
                  icon: Icons.rate_review_outlined,
                  onTap: () => _sendFeedback(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
              ]),
              const SizedBox(height: 24),

              // ── About ──────────────────────────────────────────────────────
              _section('About', isDark),
              _card(isDark, [
                _actionTile(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _showTextDialog(
                    context,
                    isDark,
                    scheme,
                    title: 'Privacy Policy',
                    body:
                        'Your privacy is important to us. This policy explains how we collect, use, and protect your personal information when you use Twedrli.\n\nWe collect only what is necessary to provide the service, never sell your data, and give you full control over your information at any time.',
                    updated: 'Last updated: February 2026',
                    acceptLabel: 'Accept',
                  ),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Terms of Service',
                  icon: Icons.description_outlined,
                  onTap: () => _showTextDialog(
                    context,
                    isDark,
                    scheme,
                    title: 'Terms of Service',
                    body:
                        'By using Twedrli, you agree to use the platform lawfully and respectfully. You are responsible for the accuracy of any content you post. Twedrli reserves the right to suspend accounts that violate these terms.',
                    updated: 'Version 2.4 — February 2026',
                    acceptLabel: 'Agree',
                  ),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'App Version',
                  subtitle: 'Twedrli v2.4.0 (Build 2026.02.28)',
                  icon: Icons.info_outline,
                  onTap: () => _showAppVersionDialog(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
              ]),
              const SizedBox(height: 24),

              // ── Account ────────────────────────────────────────────────────
              _section('Account', isDark),
              _card(isDark, [
                _actionTile(
                  title: 'Logout',
                  icon: Icons.logout_outlined,
                  color: Colors.orange,
                  onTap: () => _confirmLogout(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
                _divider(isDark),
                _actionTile(
                  title: 'Delete Account',
                  subtitle: 'Permanently remove all your data',
                  icon: Icons.delete_forever_outlined,
                  color: Colors.red,
                  onTap: () => _confirmDeleteAccount(context, isDark, scheme),
                  isDark: isDark,
                  scheme: scheme,
                ),
              ]),
              const SizedBox(height: 36),

              // ── Footer ─────────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      'Twedrli',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v2.4.0 · Made with ♥',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isDark, ColorScheme scheme) {
    return AppBar(
      backgroundColor:
          isDark ? const Color(0xFF0F0F12) : const Color(0xFFF4F6FA),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Settings',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white70 : Colors.black87,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _section(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CARD WRAPPER
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _card(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 56,
        color: isDark ? Colors.white10 : Colors.black12,
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // PROFILE CARD
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _profileCard(bool isDark, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2030), const Color(0xFF16172A)]
              : [Colors.white, const Color(0xFFF0F4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              ValueListenableBuilder<Uint8List?>(
                valueListenable: profileImageNotifier,
                builder: (context, profileImage, _) {
                  return ValueListenableBuilder<String>(
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
                                        base64Decode(imgUrl.split(',').last),
                                      ) as ImageProvider
                                    : NetworkImage(imgUrl) as ImageProvider)
                                : null,
                        child: (profileImage == null && imgUrl.isEmpty)
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E2030) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: displayNameNotifier,
                      builder: (context, displayName, _) {
                        return Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: scheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ValueListenableBuilder<String>(
                  valueListenable: usernameNotifier,
                  builder: (context, username, _) {
                    return Text(
                      username,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  'Computer Science',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SetupProfileScreen(
                    fullName: displayNameNotifier.value,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Edit',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(
      BuildContext context, bool isDark, ColorScheme scheme) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Change Password',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogTextField(isDark, oldController, 'Current Password',
                obscure: true),
            const SizedBox(height: 12),
            _dialogTextField(isDark, newController, 'New Password',
                obscure: true),
            const SizedBox(height: 12),
            _dialogTextField(isDark, confirmController, 'Confirm New Password',
                obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newController.text != confirmController.text) {
                _snack(context, 'Passwords do not match', color: Colors.red);
                return;
              }
              Navigator.pop(context);
              _snack(context, 'Password updated successfully',
                  icon: Icons.lock_person, color: Colors.green);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _dialogTextField(
      bool isDark, TextEditingController controller, String hint,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _runBackup(BuildContext context, bool isDark, ColorScheme scheme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Backing Up...',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            LinearProgressIndicator(color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Syncing your data with the cloud',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
        actions: [],
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _snack(context, 'Backup complete',
          icon: Icons.cloud_done, color: scheme.primary);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // THEME TOGGLE
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _themeToggle(bool isDark, ColorScheme scheme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (isDark ? Colors.amber : scheme.primary).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
          color: isDark ? Colors.amber : scheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        'Dark Mode',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: CupertinoSwitch(
        value: isDark,
        activeColor: scheme.primary,
        onChanged: (value) {
          themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FONT SIZE SLIDER
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _accessibilitySlider(bool isDark, ColorScheme scheme, double scale) {
    final labels = ['Small', 'Default', 'Large', 'X-Large'];
    final snapped = ((scale - 0.8) / 0.2).round().clamp(0, 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.text_fields_outlined,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Text Size',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    labels[snapped],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: scale,
            min: 0.8,
            max: 1.4,
            divisions: 3,
            activeColor: scheme.primary,
            inactiveColor: scheme.primary.withOpacity(0.15),
            onChanged: (v) => textScaleNotifier.value = v,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // REUSABLE TILES
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _switchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required void Function(bool) onChanged,
    required bool isDark,
    required ColorScheme scheme,
    Color? accentColor,
    Widget? trailing,
  }) {
    final color = accentColor ?? scheme.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            )
          : null,
      trailing: trailing ??
          CupertinoSwitch(
            value: value,
            activeColor: color,
            onChanged: onChanged,
          ),
    );
  }

  Widget _actionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
    required bool isDark,
    required ColorScheme scheme,
    String? trailingLabel,
    Color? trailingColor,
  }) {
    final iconColor = color ?? scheme.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isDark ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            )
          : null,
      trailing: trailingLabel != null
          ? Text(
              trailingLabel,
              style: TextStyle(
                color: trailingColor ?? scheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white24 : Colors.black26,
              size: 20,
            ),
    );
  }

  Widget _dropdownTile({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
    required bool isDark,
    required ColorScheme scheme,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: scheme.primary, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isDark ? Colors.white38 : Colors.black38,
          size: 18,
        ),
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 14,
        ),
        dropdownColor: isDark ? const Color(0xFF1E1E2A) : Colors.white,
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DIALOGS & ACTIONS
  // ─────────────────────────────────────────────────────────────────────────────

  void _toggle2FA(
    BuildContext context,
    bool enable,
    bool isDark,
    ColorScheme scheme,
  ) {
    if (enable) {
      showDialog(
        context: context,
        builder: (_) => _styledDialog(
          isDark: isDark,
          title: 'Enable Two-Factor Auth',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.security_rounded, size: 48, color: scheme.primary),
              const SizedBox(height: 12),
              Text(
                'Scan the QR code below with your authenticator app (Google Authenticator, Authy, etc.).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 80,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'DEMO-SECRET-KEY-12345',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _twoFactorEnabled = true);
                _snack(
                  context,
                  '2FA enabled successfully',
                  icon: Icons.check_circle,
                  color: Colors.green,
                );
              },
              child: const Text('Enable'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _twoFactorEnabled = false);
    }
  }

  void _pickQuietHours(BuildContext context, bool isDark) async {
    final start = await showTimePicker(
      context: context,
      initialTime: _quietStart,
      helpText: 'Quiet hours start',
    );
    if (start == null) return;
    if (!mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: _quietEnd,
      helpText: 'Quiet hours end',
    );
    if (end == null) return;
    setState(() {
      _quietStart = start;
      _quietEnd = end;
    });
  }

  void _showActiveSessions(
    BuildContext context,
    bool isDark,
    ColorScheme scheme,
  ) {
    final sessions = [
      {
        'device': 'Samsung Galaxy M55s · Android',
        'location': 'Tlemcen, DZ',
        'time': 'Now',
        'current': true,
      },
    ];
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Active Sessions',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sessions.map((s) {
            final isCurrent = s['current'] == true;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isCurrent ? Icons.smartphone_rounded : Icons.laptop_rounded,
                color: isCurrent ? Colors.green : scheme.primary,
              ),
              title: Text(
                s['device']! as String,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${s['location'] as String}· ${s['time'] as String}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              trailing: isCurrent
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'This device',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _snack(
                          context,
                          'Session revoked',
                          icon: Icons.logout,
                          color: Colors.orange,
                        );
                      },
                      child: const Text(
                        'Revoke',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
            );
          }).toList(),
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

  void _showBlockedUsers(
    BuildContext context,
    bool isDark,
    ColorScheme scheme,
  ) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => _styledDialog(
          isDark: isDark,
          title: 'Blocked Users',
          content: _blockedUsers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No blocked users.',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _blockedUsers.map((u) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: scheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person_outline,
                          color: scheme.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        u['name']!,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        u['handle']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          setLocal(() => _blockedUsers.remove(u));
                          setState(() {});
                        },
                        child: const Text(
                          'Unblock',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache(BuildContext context, bool isDark, ColorScheme scheme) {
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Clear Cache',
        content: Text(
          'This will free up $_cacheSize of storage. The app may be slightly slower until data is rebuilt.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _cacheSize = '0 B');
              _snack(
                context,
                'Cache cleared',
                icon: Icons.check_circle,
                color: Colors.green,
              );
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, bool isDark, ColorScheme scheme) {
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Export My Data',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We will prepare a JSON export of your account data including:',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              'Profile information',
              'Posted items',
              'Search history',
              'Messages',
            ].map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You will receive a download link within 24 hours via email.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _snack(
                context,
                'Export requested — check your email',
                icon: Icons.download_done,
                color: scheme.primary,
              );
            },
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context, bool isDark, ColorScheme scheme) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Send Feedback',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We d love to hear what you think!',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Your feedback...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _snack(
                context,
                'Thank you for your feedback!',
                icon: Icons.favorite,
                color: Colors.pink,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context, bool isDark, ColorScheme scheme) {
    final faqs = [
      {
        'q': 'How do I report a lost item?',
        'a':
            'Tap the + button on the home screen and fill out the form with item details and photos.',
      },
      {
        'q': 'How do I claim a found item?',
        'a':
            'Navigate to the item details and tap "Claim Item". The finder will be notified.',
      },
      {
        'q': 'How does the matching system work?',
        'a':
            'Our AI compares items based on description, colour, category, and location proximity.',
      },
      {
        'q': 'Is my contact information private?',
        'a':
            'Yes. Contact info is only shared when you initiate contact about an item.',
      },
      {
        'q': 'Can I edit a posted item?',
        'a':
            'Yes, tap the three-dot menu on any of your posts to edit or delete.',
      },
    ];

    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'FAQ',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: faqs.map((f) {
            return ExpansionTile(
              tilePadding: EdgeInsets.zero,
              iconColor: scheme.primary,
              collapsedIconColor: isDark ? Colors.white38 : Colors.black38,
              title: Text(
                f['q']!,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    f['a']!,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
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

  void _contactSupport(BuildContext context, bool isDark, ColorScheme scheme) {
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Contact Support',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _contactOption(
              context,
              isDark,
              scheme,
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'support@twedrli.com',
              onTap: () {
                Navigator.pop(context);
                _snack(context, 'Opening email client…');
              },
            ),
            const SizedBox(height: 8),
            _contactOption(
              context,
              isDark,
              scheme,
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Live Chat',
              subtitle: 'Available 24/7',
              badge: 'Online',
              onTap: () {
                Navigator.pop(context);
                _snack(context, 'Starting live chat…');
              },
            ),
            const SizedBox(height: 8),
            _contactOption(
              context,
              isDark,
              scheme,
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+1 (800) 123-4567',
              badge: 'Mon–Fri',
              onTap: () {
                Navigator.pop(context);
                _snack(context, 'Dialling support…');
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

  Widget _contactOption(
    BuildContext context,
    bool isDark,
    ColorScheme scheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTextDialog(
    BuildContext context,
    bool isDark,
    ColorScheme scheme, {
    required String title,
    required String body,
    required String updated,
    required String acceptLabel,
  }) {
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              updated,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(acceptLabel),
          ),
        ],
      ),
    );
  }

  void _showAppVersionDialog(
    BuildContext context,
    bool isDark,
    ColorScheme scheme,
  ) {
    final rows = {
      'App Name': 'Twedrli',
      'Version': '2.4.0',
      'Build': '2026.02.28',
      'Platform': 'iOS / Android',
      'SDK': 'Flutter 3.x',
    };
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'App Information',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: rows.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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

  void _confirmLogout(BuildContext context, bool isDark, ColorScheme scheme) {
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Log Out',
        icon: Icons.logout_outlined,
        iconColor: Colors.orange,
        content: Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(
    BuildContext context,
    bool isDark,
    ColorScheme scheme,
  ) {
    showDialog(
      context: context,
      builder: (_) => _styledDialog(
        isDark: isDark,
        title: 'Delete Account',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '⚠️  This action is permanent and cannot be undone. All your posts, messages, and account data will be permanently erased.',
                style: TextStyle(
                  color: isDark ? Colors.red[300] : Colors.red[700],
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _snack(
                context,
                'Account deleted',
                icon: Icons.delete_forever,
                color: Colors.red,
              );
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER: STYLED DIALOG
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _styledDialog({
    required bool isDark,
    required String title,
    IconData? icon,
    Color? iconColor,
    required Widget content,
    required List<Widget> actions,
  }) {
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1C1C28) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(child: content),
      actions: actions,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // HELPER: SNACKBAR
  // ─────────────────────────────────────────────────────────────────────────────
  void _snack(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color ?? Colors.blueGrey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showComingSoon(BuildContext context) =>
      _snack(context, 'Coming soon!', icon: Icons.rocket_launch_outlined);
}
