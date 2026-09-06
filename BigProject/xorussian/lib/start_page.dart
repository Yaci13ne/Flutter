import 'package:flutter/material.dart';
import 'package:xorussian/game.dart';
import 'package:xorussian/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:xorussian/network_service.dart';
import 'package:xorussian/doll.dart';
import 'package:xorussian/main.dart'; // for DollSize

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final NetworkService _network = NetworkService();
  bool _isLoading = false;

  void _showLoading() => setState(() => _isLoading = true);
  void _hideLoading() => setState(() => _isLoading = false);

  List<Doll> _getInitialPieces(String owner) {
    final sizes = [
      DollSize.xs, DollSize.s, DollSize.m, DollSize.l, DollSize.xl,
      DollSize.xs, DollSize.s, DollSize.m, DollSize.l,
    ];
    return sizes.map((s) => Doll(owner, s)).toList();
  }

  Future<void> _hostGame() async {
    if (nameCtrl.text.isEmpty) return;
    _showLoading();
    try {
      final code = await _network.createRoom(
        nameCtrl.text,
        _getInitialPieces('X'),
        _getInitialPieces('O'),
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GamePage(
            blueName: nameCtrl.text,
            redName: 'Waiting...',
            roomCode: code,
            isHost: true,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e (Did you configure Firebase?)')));
      }
    }
    _hideLoading();
  }

  Future<void> _joinGame() async {
    if (nameCtrl.text.isEmpty || codeCtrl.text.isEmpty) return;
    _showLoading();
    try {
      final success = await _network.joinRoom(codeCtrl.text, nameCtrl.text);
      if (success) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GamePage(
              blueName: 'Host', // Actual name will sync from Firebase
              redName: nameCtrl.text,
              roomCode: codeCtrl.text,
              isHost: false,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid code or room full.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    _hideLoading();
  }

  void _playLocal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(
          blueName: nameCtrl.text.isEmpty ? 'Player 1' : nameCtrl.text,
          redName: 'Player 2',
          roomCode: null,
          isHost: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.coreBackgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.extension, size: 80, color: AppTheme.primaryBlue)
                      .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  Text(
                    'MATRYOSHKA',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(letterSpacing: 4),
                    textAlign: TextAlign.center,
                  ).animate().fade(duration: 800.ms).slideY(begin: 0.3, end: 0),
                  Text(
                    'TIC TAC TOE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryRed, letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ).animate().fade(duration: 1000.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 48),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Your Name',
                            prefixIcon: Icon(Icons.person, color: AppTheme.primaryBlue),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: codeCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Room Code (Join Only)',
                                  prefixIcon: Icon(Icons.numbers, color: Colors.white54),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_isLoading)
                    const CircularProgressIndicator(color: AppTheme.primaryBlue)
                  else
                    Column(
                      children: [
                        _buildPrimaryButton(
                          label: 'HOST ONLINE GAME',
                          color1: AppTheme.primaryBlue,
                          color2: AppTheme.primaryRed,
                          onPressed: _hostGame,
                        ),
                        const SizedBox(height: 16),
                        _buildPrimaryButton(
                          label: 'JOIN ONLINE GAME',
                          color1: Colors.purpleAccent,
                          color2: Colors.deepPurple,
                          onPressed: _joinGame,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _playLocal,
                          child: const Text('Play Pass-and-Play (Local)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required Color color1, required Color color2, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color1.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }
}
