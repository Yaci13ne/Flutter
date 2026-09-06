import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xorussian/game.dart';
import 'package:xorussian/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:xorussian/network_service.dart';

class ResultPage extends StatefulWidget {
  final String result;
  final String blueName;
  final String redName;
  final Color? winnerColor;
  final int blueWins;
  final int redWins;
  final String? roomCode;
  final bool? isHost;

  const ResultPage({
    super.key,
    required this.result,
    required this.blueName,
    required this.redName,
    required this.blueWins,
    required this.redWins,
    this.winnerColor,
    this.roomCode,
    this.isHost,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final NetworkService _network = NetworkService();
  StreamSubscription<RoomState?>? _sub;
  Timer? _timer;
  int _timeLeft = 15;
  bool _rematchRequested = false;
  bool _rematchFinalized = false;

  @override
  void initState() {
    super.initState();
    if (widget.roomCode != null) {
      _startOnlineTimer();
    }
  }

  void _startOnlineTimer() {
    _sub = _network.streamRoom(widget.roomCode!).listen((state) {
      if (state == null) return;
      if (state.hostRematch && state.guestRematch) {
        _rematchFinalized = true;
        
        // Host resets the room state in Firebase for the next match
        if (widget.isHost == true) {
          _network.restartRoom(widget.roomCode!);
        }
      }

      // Wait until the room is ACTUALLY reset (winner wiped) to prevent instant bounce-backs!
      if (_rematchFinalized && state.winner.isEmpty) {
        _sub?.cancel();
        _timer?.cancel();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GamePage(
                blueName: widget.blueName,
                redName: widget.redName,
                blueWins: widget.blueWins,
                redWins: widget.redWins,
                roomCode: widget.roomCode,
                isHost: widget.isHost!,
              ),
            ),
          );
        }
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            timer.cancel();
            _sub?.cancel();
            // Pop to StartPage (main menu)
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.coreBackgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Result header with icon
                Container(
                  padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: widget.winnerColor?.withValues(alpha: 0.5) ?? AppTheme.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.winnerColor ?? Colors.black).withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 80,
                        color: widget.winnerColor ?? Colors.white,
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(begin: -10, end: 10, duration: 2.seconds),
                      const SizedBox(height: 24),
                      const Text(
                        'MATCH CONCLUDED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: Colors.white70,
                        ),
                      ).animate().fade(duration: 500.ms).slideY(),
                      const SizedBox(height: 16),
                      Text(
                        widget.result.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: widget.winnerColor ?? Colors.white,
                          fontSize: 32,
                        ),
                      ).animate().fade(duration: 800.ms).scale(curve: Curves.easeOutBack),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.2),
                
                const SizedBox(height: 48),

                // Player information section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SCOREBOARD',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPlayerRow(
                        name: widget.blueName,
                        color: AppTheme.primaryBlue,
                        wins: widget.blueWins,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Colors.white12, height: 1),
                      ),
                      _buildPlayerRow(
                        name: widget.redName,
                        color: AppTheme.primaryRed,
                        wins: widget.redWins,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action buttons
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryRed]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(-5, 5)),
                          BoxShadow(color: AppTheme.primaryRed.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(5, 5)),
                        ]
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.roomCode == null) {
                            // Local mode
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GamePage(
                                  blueName: widget.blueName,
                                  redName: widget.redName,
                                  blueWins: widget.blueWins,
                                  redWins: widget.redWins,
                                ),
                              ),
                            );
                          } else {
                            // Online mode
                            if (_rematchRequested) return;
                            setState(() {
                              _rematchRequested = true;
                            });
                            _network.requestRematch(widget.roomCode!, widget.isHost!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          widget.roomCode == null
                              ? 'PLAY AGAIN'
                              : (_rematchRequested ? 'WAITING... [$_timeLeft]' : 'REQUEST REMATCH [$_timeLeft]'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('MAIN MENU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow({
    required String name,
    required Color color,
    required int wins,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        Text(
          '$wins WINS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
