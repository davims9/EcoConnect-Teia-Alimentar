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
/// **Design system (all values in logical pixels):**
/// | Token              | Value   |
/// |--------------------|---------|
/// | Card / btn height  | 48      |
/// | Card radius        | 14      |
/// | Card H padding     | 16      |
/// | Border width       | 1.5     |
/// | Icon size          | 22      |
/// | Font size (main)   | 16      |
/// | Element gap        | 14      |
/// | Background         | #0B3D22 |
/// | Border / glow      | #2E7D32 |
///
/// **Layout strategy (wide ≥ 650 dp):**
/// A centered row capped at 1000 dp max-width with proportional flexes
/// — connection card gets flex 5, biome and score get flex 3 each.
///
/// **Layout strategy (compact < 650 dp):**
/// A scrollable horizontal row with shorter labels and no progress bar.
class GameTopHud extends StatelessWidget {
  final VoidCallback onBackTap;

  const GameTopHud({super.key, required this.onBackTap});

  static const double _compactBreakpoint = 650;
  static const double _maxContainerWidth = 1000;
  static const double _cardHeight = 48;
  static const double _iconSize = 22;
  static const double _fontSize = 16;
  static const double _gap = 14;
  static const double _compactGap = 8;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, service, _) {
        final phase = service.currentPhase;
        final correct = service.correctCount;
        final total = service.correctConnections.length;

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 6,
            left: 10,
            right: 10,
            bottom: 8,
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
          child: _buildRow(
            phase: phase,
            score: service.score,
            correct: correct,
            total: total,
            seconds: service.remainingSeconds,
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------------
  // Responsive row
  // -----------------------------------------------------------------------

  Widget _buildRow({
    Phase? phase,
    required int score,
    required int correct,
    required int total,
    required int seconds,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < _compactBreakpoint;
        final gap = compact ? _compactGap : _gap;

        if (compact) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BackButton(onTap: onBackTap),
                SizedBox(width: gap),
                if (phase != null) _BiomeCard(phase: phase, compact: true),
                SizedBox(width: gap),
                _ScoreCard(score: score, compact: true),
                SizedBox(width: gap),
                _ConnectionCard(correct: correct, total: total, compact: true),
                SizedBox(width: gap),
                _TimerCard(seconds: seconds),
                SizedBox(width: gap),
                const AudioToggleButton(),
              ],
            ),
          );
        }

        // --- Wide ---
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _maxContainerWidth,
            ),
            child: Row(
              children: [
                _BackButton(onTap: onBackTap),
                SizedBox(width: gap),
                Expanded(flex: 3, child: _BiomeCard(phase: phase)),
                SizedBox(width: gap),
                Expanded(flex: 3, child: _ScoreCard(score: score)),
                SizedBox(width: gap),
                Expanded(
                  flex: 5,
                  child: _ConnectionCard(correct: correct, total: total),
                ),
                SizedBox(width: gap),
                _TimerCard(seconds: seconds),
                SizedBox(width: gap),
                const AudioToggleButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// Shared card shell
// ===========================================================================

/// Reusable HUD card shell.
///
/// Every card has an exact 48 px height, 14 px border-radius, 16 px
/// horizontal padding, 88 % dark-green background, green border and a
/// soft glow — the shared design system.
class _HudCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _HudCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: GameTopHud._cardHeight,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (borderColor ?? const Color(0xFF2E7D32))
              .withValues(alpha: 0.65),
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

// ===========================================================================
// Shared text style helper
// ===========================================================================

TextStyle _hudText({
  double size = GameTopHud._fontSize,
  FontWeight weight = FontWeight.w700,
  Color color = const Color(0xFFF0FDF4),
}) {
  return GoogleFonts.nunito(
    fontSize: size,
    fontWeight: weight,
    color: color,
  );
}

// ===========================================================================
// Individual widgets
// ===========================================================================

/// Circular back / home button (48 × 48, matches [AudioToggleButton]).
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onTap: onTap,
      child: Container(
        width: GameTopHud._cardHeight,
        height: GameTopHud._cardHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
          shape: BoxShape.circle,
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
          size: 22,
        ),
      ),
    );
  }
}

/// Biome / phase card — icon + phase name.
class _BiomeCard extends StatelessWidget {
  final Phase? phase;
  final bool compact;

  const _BiomeCard({required this.phase, this.compact = false});

  IconData _biomeIcon() {
    switch (phase?.biome.toLowerCase() ?? '') {
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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(_biomeIcon(), size: GameTopHud._iconSize,
              color: const Color(0xFFBBF7D0)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              phase?.name ?? '',
              overflow: TextOverflow.ellipsis,
              style: _hudText(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Score card — star icon + "Pontos: N".
class _ScoreCard extends StatelessWidget {
  final int score;
  final bool compact;

  const _ScoreCard({required this.score, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return _HudCard(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded, size: GameTopHud._iconSize,
              color: const Color(0xFFFFD43B)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              compact ? '$score' : 'Pontos: $score',
              overflow: TextOverflow.ellipsis,
              style: _hudText(
                weight: FontWeight.w800,
                color: const Color(0xFFFFD43B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Connection progress card — large "correct/total" number, "conexões" label,
/// and an animated green gradient progress bar with glow.
///
/// Taller than the standard [GameTopHud._cardHeight] (56 px vs 48 px) to
/// accommodate the larger number and progress bar while keeping the same
/// visual language (dark-green translucent background, rounded border, glow).
class _ConnectionCard extends StatelessWidget {
  final int correct;
  final int total;
  final bool compact;

  const _ConnectionCard({
    required this.correct,
    required this.total,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (correct / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Number row ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$correct',
                style: TextStyle(
                  fontSize: compact ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFF0FDF4),
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  '/$total',
                  style: TextStyle(
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFBBF7D0).withValues(alpha: 0.7),
                    height: 1.0,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    'conexões',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFBBF7D0).withValues(alpha: 0.6),
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // --- Animated progress bar ---
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: const Color(0xFFF0FDF4).withValues(alpha: 0.12),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF37B24D), Color(0xFF7ED957)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7ED957).withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Timer card — clock icon + MM:SS.
class _TimerCard extends StatelessWidget {
  final int seconds;

  const _TimerCard({required this.seconds});

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final low = seconds <= 30;
    return _HudCard(
      borderColor: low ? const Color(0xFFEF4444) : null,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            low ? Icons.timer_off_rounded : Icons.timer_outlined,
            size: GameTopHud._iconSize,
            color: low ? const Color(0xFFEF4444) : const Color(0xFFBBF7D0),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(seconds),
            style: _hudText(
              color: low ? const Color(0xFFEF4444) : const Color(0xFFF0FDF4),
            ),
          ),
        ],
      ),
    );
  }
}
