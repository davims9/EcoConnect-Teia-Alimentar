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
/// **Layout strategy (wide ≥ 600 dp):**
/// A centered row capped at 1000 dp max-width with proportional flexes
/// — connection card gets flex 5, biome and score get flex 3 each.
///
/// **Layout strategy (compact < 600 dp):**
/// A two‑row column: top row has back‑button + biome name + audio‑toggle;
/// bottom row has score, connection‑with‑bar and timer cards spread evenly.
class GameTopHud extends StatelessWidget {
  final VoidCallback onBackTap;

  const GameTopHud({super.key, required this.onBackTap});

  // -- Breakpoints ----------------------------------------------------------
  static const double _compactBreakpoint = 600;
  static const double _maxContainerWidth = 1000;

  // -- Wide layout tokens ---------------------------------------------------
  static const double _cardHeight = 48;
  static const double _iconSize = 22;
  static const double _fontSize = 16;
  static const double _gap = 14;

  // -- Compact layout tokens (portrait / narrow) ----------------------------
  static const double _compactCardHeight = 36;
  static const double _compactButtonSize = 36;
  static const double _compactIconSize = 20;   // biome icon
  static const double _compactIconSmall = 16;  // stats icons
  static const double _compactFontSize = 12;   // stats font
  static const double _compactBiomeFont = 16;  // biome name font
  static const double _compactGap = 6;
  static const double _compactPadding = 8;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, service, _) {
        final phase = service.currentPhase;
        final made = service.playerConnections.length;
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
            made: made,
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
    required int made,
    required int total,
    required int seconds,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < _compactBreakpoint;
        final gap = compact ? _compactGap : _gap;

        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1 — header: back, biome name, audio toggle
              Row(
                children: [
                  _BackButton(onTap: onBackTap, compact: true),
                  SizedBox(width: _compactGap),
                  if (phase != null)
                    Expanded(
                      child: _BiomeCard(phase: phase, compact: true),
                    ),
                  if (phase != null) SizedBox(width: _compactGap),
                  // Shrink the 48 px AudioToggleButton to compact size
                  SizedBox(
                    width: _compactButtonSize,
                    height: _compactButtonSize,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: const AudioToggleButton(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: _compactGap),
              // Row 2 — stats: score, connections, timer
              Row(
                children: [
                  Expanded(
                    child: _ScoreCard(score: score, compact: true),
                  ),
                  SizedBox(width: _compactGap),
                  Expanded(
                    child:
                        _ConnectionCard(made: made, total: total, compact: true),
                  ),
                  SizedBox(width: _compactGap),
                  Expanded(
                    child: _TimerCard(seconds: seconds, compact: true),
                  ),
                ],
              ),
            ],
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
                  child: _ConnectionCard(made: made, total: total),
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
  final bool compact;

  const _HudCard({
    required this.child,
    this.borderColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? GameTopHud._compactCardHeight : GameTopHud._cardHeight,
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? GameTopHud._compactPadding : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
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
  final bool compact;

  const _BackButton({required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size =
        compact ? GameTopHud._compactButtonSize : GameTopHud._cardHeight;
    final iconSize =
        compact ? GameTopHud._compactIconSize : GameTopHud._iconSize;
    return HoverButton(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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
        child: Icon(
          Icons.arrow_back_rounded,
          color: const Color(0xFFF0FDF4),
          size: iconSize,
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
      compact: compact,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(_biomeIcon(),
              size: compact ? GameTopHud._compactIconSize : GameTopHud._iconSize,
              color: const Color(0xFFBBF7D0)),
          SizedBox(width: compact ? 6 : 8),
          Text(
            phase?.name ?? '',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: _hudText(
              size: compact ? GameTopHud._compactBiomeFont : GameTopHud._fontSize,
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
      compact: compact,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded,
              size: compact ? GameTopHud._compactIconSmall : GameTopHud._iconSize,
              color: const Color(0xFFFFD43B)),
          SizedBox(width: compact ? 4 : 8),
          Text(
            compact ? '$score' : 'Pontos: $score',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: _hudText(
              size: compact ? GameTopHud._compactFontSize : GameTopHud._fontSize,
              weight: FontWeight.w800,
              color: const Color(0xFFFFD43B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Connection progress card — icon + "N/M conexões" + progress bar (wide).
class _ConnectionCard extends StatelessWidget {
  final int made;
  final int total;
  final bool compact;

  const _ConnectionCard({
    required this.made,
    required this.total,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (made / total).clamp(0.0, 1.0) : 0.0;

    return _HudCard(
      compact: compact,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Label ---
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.link_rounded,
                  size: compact ? GameTopHud._compactIconSmall : 20,
                  color: const Color(0xFF7ED957)),
              SizedBox(width: compact ? 4 : 6),
              Text(
                compact ? '$made/$total' : '$made/$total conexões',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: _hudText(
                  size: compact ? GameTopHud._compactFontSize : GameTopHud._fontSize,
                ),
              ),
            ],
          ),
          // --- Progress bar ---
          const SizedBox(height: 3),
          Container(
            height: compact ? 3 : 4,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(compact ? 2 : 3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF7ED957),
                  borderRadius: BorderRadius.circular(compact ? 2 : 3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Timer card — clock icon + MM:SS.
class _TimerCard extends StatelessWidget {
  final int seconds;
  final bool compact;

  const _TimerCard({required this.seconds, this.compact = false});

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final low = seconds <= 30;
    return _HudCard(
      compact: compact,
      borderColor: low ? const Color(0xFFEF4444) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            low ? Icons.timer_off_rounded : Icons.timer_outlined,
            size: compact ? GameTopHud._compactIconSmall : GameTopHud._iconSize,
            color: low ? const Color(0xFFEF4444) : const Color(0xFFBBF7D0),
          ),
          SizedBox(width: compact ? 4 : 8),
          Text(
            _formatTime(seconds),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: _hudText(
              size: compact ? GameTopHud._compactFontSize : GameTopHud._fontSize,
              color: low ? const Color(0xFFEF4444) : const Color(0xFFF0FDF4),
            ),
          ),
        ],
      ),
    );
  }
}
