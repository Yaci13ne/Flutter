// screens/character_select_screen.dart

import 'package:colorpath/models/character.dart';
import 'package:colorpath/widgets/character_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen>
    with SingleTickerProviderStateMixin {
  int _pickingPlayer = 1;
  GameCharacter? _p1Selection;
  GameCharacter? _p2Selection;
  int? _hoveredIndex;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _selectCharacter(GameCharacter char, GameState gs) {
    if (!gs.isUnlocked(_pickingPlayer, char.id)) {
      _shakeCtrl.forward(from: 0);
      return;
    }
    setState(() {
      if (_pickingPlayer == 1) {
        _p1Selection = char;
        _pickingPlayer = 2;
      } else {
        if (char.id == _p1Selection?.id) {
          _shakeCtrl.forward(from: 0);
          return;
        }
        _p2Selection = char;
      }
    });
  }

  void _confirmAndStart(GameState gs) {
    if (_p1Selection == null || _p2Selection == null) return;
    gs.confirmCharacters(_p1Selection!, _p2Selection!);
  }

  void _reset() {
    setState(() {
      _pickingPlayer = 1;
      _p1Selection = null;
      _p2Selection = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final bool bothPicked = _p1Selection != null && _p2Selection != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(gs),
            _buildSelectionStatus(),
            const SizedBox(height: 8),
            Expanded(child: _buildGrid(gs)),
            _buildFooter(gs, bothPicked),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(GameState gs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Text(
        'SELECT YOUR FIGHTER',
        textAlign: TextAlign.center,
        style: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSelectionStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _playerSlot(1, _p1Selection, const Color(0xFF4BACFF)),
          const Spacer(),
          AnimatedBuilder(
            animation: _shakeAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(_shakeAnim.value, 0),
              child: child,
            ),
            child: Text(
              'VS',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
              ),
            ),
          ),
          const Spacer(),
          _playerSlot(2, _p2Selection, const Color(0xFFFF4B4B)),
        ],
      ),
    );
  }

  Widget _playerSlot(int player, GameCharacter? sel, Color accent) {
    final isPickingThis = _pickingPlayer == player &&
        !(player == 1 && _p1Selection != null) &&
        !(player == 2 && _p2Selection != null);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: sel != null
            ? accent.withOpacity(0.15)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPickingThis
              ? accent.withOpacity(0.8)
              : (sel != null ? accent.withOpacity(0.4) : Colors.white12),
          width: isPickingThis ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'P$player',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          if (sel != null && sel.imagePath.isNotEmpty)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(sel.imagePath),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: accent, width: 2),
              ),
            )
          else
            Text(
            (isPickingThis ? '▶' : '?'),
              style: const TextStyle(fontSize: 32),
            ),
          const SizedBox(height: 4),
          Text(
            sel?.name ?? (isPickingThis ? 'Picking...' : 'Waiting'),
            style: GoogleFonts.rubik(
              fontSize: 11,
              color: sel != null ? Colors.white : Colors.white38,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (sel != null)
            Text(
              sel.subtitle,
              style: GoogleFonts.rubik(fontSize: 9, color: Colors.white38),
              maxLines: 1,
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(GameState gs) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: kAllCharacters.length,
      itemBuilder: (_, i) {
        final char = kAllCharacters[i];
        final unlocked = gs.isUnlocked(_pickingPlayer, char.id);
        final isP1 = _p1Selection?.id == char.id;
        final isP2 = _p2Selection?.id == char.id;
        return _CharacterCard(
          character: char,
          unlocked: unlocked,
          isP1Selected: isP1,
          isP2Selected: isP2,
          isHovered: _hoveredIndex == i,
          onTap: () => _selectCharacter(char, gs),
          onHover: (h) => setState(() => _hoveredIndex = h ? i : null),
          winsNeeded: _getWinsNeededForCharacter(char, gs),
        );
      },
    );
  }

  int _getWinsNeededForCharacter(GameCharacter char, GameState gs) {
    if (char.startsUnlocked) return 0;
    final unlockOrderIndex = kUnlockOrder.indexOf(char.id);
    if (unlockOrderIndex == -1) return 0;
    return unlockOrderIndex + 1;
  }

  Widget _buildFooter(GameState gs, bool bothPicked) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          if (_p1Selection != null)
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, size: 16, color: Colors.white38),
              label: Text(
                'Reset',
                style: GoogleFonts.rubik(color: Colors.white38, fontSize: 13),
              ),
            ),
          const Spacer(),
          AnimatedOpacity(
            opacity: bothPicked ? 1 : 0.35,
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: bothPicked ? () => _confirmAndStart(gs) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                bothPicked ? 'FIGHT!' : 'Select both fighters',
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Character card with image support ─────────────────────────────────────────

class _CharacterCard extends StatelessWidget {
  final GameCharacter character;
  final bool unlocked;
  final bool isP1Selected;
  final bool isP2Selected;
  final bool isHovered;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;
  final int winsNeeded;

  const _CharacterCard({
    required this.character,
    required this.unlocked,
    required this.isP1Selected,
    required this.isP2Selected,
    required this.isHovered,
    required this.onTap,
    required this.onHover,
    this.winsNeeded = 0,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white12;
    if (isP1Selected) borderColor = const Color(0xFF4BACFF);
    if (isP2Selected) borderColor = const Color(0xFFFF4B4B);

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: unlocked
                ? (isP1Selected || isP2Selected
                    ? borderColor.withOpacity(0.18)
                    : (isHovered
                        ? Colors.white.withOpacity(0.07)
                        : Colors.white.withOpacity(0.04)))
                : Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unlocked
                  ? (isP1Selected || isP2Selected
                      ? borderColor
                      : Colors.white.withOpacity(isHovered ? 0.3 : 0.1))
                  : Colors.white12,
              width: isP1Selected || isP2Selected ? 2.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: (isP1Selected || isP2Selected || isHovered) && unlocked
                      ? 1.12
                      : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: unlocked
                      ? CharacterImage(
                          imagePath: character.imagePath,
                          size: 70,
                          borderColor:
                              isP1Selected || isP2Selected ? borderColor : null,
                          borderWidth: 2,
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.03),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '🔒',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  unlocked ? character.name : '???',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? Colors.white : Colors.white24,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  unlocked
                      ? character.subtitle
                      : (winsNeeded > 0
                          ? 'Win $winsNeeded match to unlock'
                          : '???'),
                  style: GoogleFonts.rubik(
                    fontSize: 9,
                    color: unlocked ? Colors.white38 : Colors.white24,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
