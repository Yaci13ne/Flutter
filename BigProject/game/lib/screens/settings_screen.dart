import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            letterSpacing: 4,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('BOARD'),
            const SizedBox(height: 16),
            _SettingCard(
              label: 'Grid Size',
              child: Row(
                children: [
                  _SizeButton(
                    label: '8×8',
                    selected: settings.gridSize == 8,
                    onTap: () => settings.setGridSize(8),
                  ),
                  const SizedBox(width: 12),
                  _SizeButton(
                    label: '10×10',
                    selected: settings.gridSize == 10,
                    onTap: () => settings.setGridSize(10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SettingCard(
              label: 'Special Tiles',
              trailing: Switch(
                value: settings.specialTilesEnabled,
                onChanged: settings.setSpecialTilesEnabled,
                activeColor: AppTheme.neonGreen,
              ),
            ),
            const SizedBox(height: 12),
            _SettingCard(
              label: 'Wall Placement Mode',
              trailing: Switch(
                value: settings.wallModeEnabled,
                onChanged: settings.setWallModeEnabled,
                activeColor: AppTheme.neonBlue,
              ),
            ),
            const SizedBox(height: 32),
            _SectionLabel('AUDIO'),
            const SizedBox(height: 16),
            _SettingCard(
              label: 'Sound Effects',
              trailing: Switch(
                value: settings.soundEnabled,
                onChanged: settings.setSoundEnabled,
                activeColor: AppTheme.neonBlue,
              ),
            ),
            const SizedBox(height: 40),
            _SectionLabel('HOW TO PLAY'),
            const SizedBox(height: 16),
            const _RuleCard(
              icon: '🎯',
              title: 'Objective',
              desc: 'Reach the opponent\'s starting row before they reach yours.',
            ),
            const SizedBox(height: 8),
            const _RuleCard(
              icon: '🏃',
              title: 'Movement',
              desc: 'Jump to the nearest tile of the same color in any direction.',
            ),
            const SizedBox(height: 8),
            const _RuleCard(
              icon: '🧱',
              title: 'Walls',
              desc: 'Place walls between tiles to block opponent movement. Both players must always have a valid path.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 11,
        letterSpacing: 4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final Widget? child;

  const _SettingCard({required this.label, this.trailing, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
              if (trailing != null) trailing!,
            ],
          ),
          if (child != null) ...[const SizedBox(height: 12), child!],
        ],
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SizeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.neonBlue.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: selected ? AppTheme.neonBlue : Colors.white24,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.neonBlue : Colors.white54,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const _RuleCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
