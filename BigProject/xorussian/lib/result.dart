import 'package:flutter/material.dart';
import 'package:xorussian/game.dart';
import 'package:xorussian/main.dart';

class ResultPage extends StatelessWidget {
  final String result;
  final String blueName;
  final String redName;
  final Color?
  winnerColor; // Optional: Can pass winner color for dynamic theming

  final int blueWins;
  final int redWins;

  const ResultPage({
    super.key,
    required this.result,
    required this.blueName,
    required this.redName,
    required this.blueWins,
    required this.redWins,
    this.winnerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.scaffoldBackgroundColor
          : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Game Results',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode
            ? theme.appBarTheme.backgroundColor
            : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : theme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Result header with icon
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: isDarkMode ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDarkMode
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: winnerColor ?? theme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MATCH CONCLUDED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: winnerColor ?? theme.primaryColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Player information section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participants',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPlayerRow(
                      context: context,
                      name: blueName,
                      color: Colors.blue,
                      isDarkMode: isDarkMode,
                      wins: blueWins,
                    ),

                    const SizedBox(height: 12),
                    _buildPlayerRow(
                      context: context,
                      name: redName,
                      color: Colors.red,
                      isDarkMode: isDarkMode,
                      wins: redWins,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                    onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GamePage(
                              blueName: blueName,
                              redName: redName,
                              blueWins: blueWins,
                              redWins: redWins,
                            ),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Play Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode
                            ? Colors.grey[300]
                            : Colors.grey[700],
                        side: BorderSide(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Return to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow({
    required BuildContext context,
    required String name,
    required Color color,
    required bool isDarkMode,
    required int wins,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$name - Wins: $wins',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
