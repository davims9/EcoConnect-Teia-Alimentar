import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/phase.dart';
import '../services/game_service.dart';
import 'hover_button.dart';
import 'audio_toggle_button.dart';

/// Top HUD for the game screen — styled cards for biome, score, connections,
/// timer, back button and audio toggle.
///
/// Uses [google_fonts] (Nunito) for a rounded, friendly look on the HUD only.
/// Cards follow the UI/UX identity guide: dark green translucent background,
/// green borders, rounded corners and soft shadow.
class GameTopHud extends StatelessWidget {
  final VoidCallback onBackTap;

  const GameTopHud({super.key, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, service, _) {
        final phase = service.currentPhase;
        final made = service.playerConnections.length;
        final total = service.correctConnections.length;

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4,
            left: 8,
            right: 8,
            bottom: 10,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B3D22),
                Color(0xFF0B3D22),
                Colors.transparent,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BackButton(onTap: onBackTap),
                const SizedBox(width: 8),
                if (phase != null) _BiomeCard(phase: phase),
                const SizedBox(width: 8),
                _ScoreCard(score: service.score),
                const SizedBox(width: 8),
                _ConnectionCard(made: made, total: total),
                const SizedBox(width: 8),
                _TimerCard(seconds: service.remainingSeconds),
                const SizedBox(width: 8),
                const AudioToggleButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable card wrapper
// ---------------------------------------------------------------------------

/// A single HUD card with dark-green translucent background, green border,
/// rounded corners and a soft green glow.
class _HudCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _HudCard({
    required this.child,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D22).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (borderColor ?? const Color(0xFF2E7D32)).withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Individual card widgets
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF0B3D22).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFFF0FDF4),
          size: 20,
        ),
      ),
    );
  }
}

class _BiomeCard extends StatelessWidget {
  final Phase phase;

  const _BiomeCard({required this.phase});

  IconData _biomeIcon() {
    switch (phase.biome.toLowerCase()) {
      case 'campo':
        return Icons.grass_rounded;
      case 'floresta':
        return Icons.forest_rounded;
      case 'oceano':
        return Icons.water_drop_rounded;
      case 'pantanal':
        return Icons.nature_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _HudCard(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_biomeIcon(), size: 18, color: const Color(0xFFBBF7D0)),
          const SizedBox(width: 6),
          Text(
            phase.name,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF0FDF4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;

  const _ScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return _HudCard(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 18,
            color: const Color(0xFFFFD43B),
          ),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFFD43B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final int made;
  final int total;

  const _ConnectionCard({required this.made, required this.total});

  @override
  Widget build(BuildContext context) {
    return _HudCard(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link_rounded,
            size: 16,
            color: const Color(0xFF7ED957),
          ),
          const SizedBox(width: 4),
          Text(
            '$made/$total',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF0FDF4),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  final int seconds;

  const _TimerCard({required this.seconds});

  String _formatTime(int totalSeconds) {
    final min = totalSeconds ~/ 60;
    final sec = totalSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLow = seconds <= 30;
    return _HudCard(
      borderColor: isLow ? const Color(0xFFEF4444) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLow ? Icons.timer_off_rounded : Icons.timer_outlined,
            size: 16,
            color: isLow ? const Color(0xFFEF4444) : const Color(0xFFBBF7D0),
          ),
          const SizedBox(width: 4),
          Text(
            _formatTime(seconds),
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isLow ? const Color(0xFFEF4444) : const Color(0xFFF0FDF4),
            ),
          ),
        ],
      ),
    );
  }
}
