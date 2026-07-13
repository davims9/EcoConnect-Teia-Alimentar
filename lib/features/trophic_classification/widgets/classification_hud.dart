import 'package:flutter/material.dart';
import '../../../widgets/shared/eco_back_button.dart';
import '../services/classification_service.dart';

/// Top HUD for the Classification game screen.
///
/// Visually equivalent to [GameTopHud] from the Teia Alimentar mode:
/// same card shapes, colours, typography, glow, spacing.
///
/// Layout (compact / narrow):
///   Row 1: [Back] [Biome name] [Dica] [Audio]
///   Row 2: [Score card] [Progress card]
///
/// Progress and Dica are inside the HUD — there is no separate line
/// below for either of them.
class ClassificationHud extends StatelessWidget {
  final ClassificationService service;
  final VoidCallback? onBack;
  final VoidCallback? onHint;

  const ClassificationHud({
    super.key,
    required this.service,
    this.onBack,
    this.onHint,
  });

  // -- Tokens matching GameTopHud compact tokens ----------------------------
  static const double _cardHeight = 48;
  static const double _compactCardHeight = 36;
  static const double _compactButtonSize = 38;
  static const double _iconSize = 22;
  static const double _compactIconSize = 18;
  static const double _compactIconSmall = 14;
  static const double _fontSize = 16;
  static const double _compactFontSize = 12;
  static const double _compactBiomeFont = 14;
  static const double _gap = 14;
  static const double _compactGap = 6;

  @override
  Widget build(BuildContext context) {
    final config = service.config;
    final total = config?.totalOrganisms ?? 0;
    final placed = service.placedCount;
    final correct = service.correctCount;
    final isComplete = service.isComplete;
    final hasHint = onHint != null && !isComplete;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        left: 8,
        right: 8,
        bottom: 6,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B3D22), Color(0xFF0B3D22), Colors.transparent],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          if (compact) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1 — back, biome, dica, audio
                Row(
                  children: [
                    EcoBackButton(
                      onTap: onBack ?? () => Navigator.pop(context),
                      compact: true,
                      size: _compactButtonSize,
                      compactSize: _compactButtonSize,
                    ),
                    SizedBox(width: _compactGap),
                    Expanded(child: _BiomeCard(name: config?.biomeName)),
                    if (hasHint) SizedBox(width: _compactGap),
                    if (hasHint) _DicaButton(onTap: onHint),
                    if (hasHint) SizedBox(width: _compactGap),
                    _AudioPlaceholder(),
                  ],
                ),
                SizedBox(height: _compactGap),
                // Row 2 — score, progress
                Row(
                  children: [
                    Expanded(child: _ScoreCard(score: service.score)),
                    SizedBox(width: _compactGap),
                    Expanded(
                      flex: 2,
                      child: _ProgressCard(
                        placed: placed,
                        total: total,
                        correct: correct,
                        isComplete: isComplete,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          // --- Wide layout ---
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Row(
                children: [
                  EcoBackButton(
                    onTap: onBack ?? () => Navigator.pop(context),
                    size: _cardHeight,
                    compactSize: _cardHeight,
                  ),
                  SizedBox(width: _gap),
                  Expanded(
                    flex: 3,
                    child: _BiomeCard(name: config?.biomeName, compact: false),
                  ),
                  SizedBox(width: _gap),
                  Expanded(
                    flex: 3,
                    child: _ScoreCard(score: service.score, compact: false),
                  ),
                  SizedBox(width: _gap),
                  Expanded(
                    flex: 5,
                    child: _ProgressCard(
                      placed: placed,
                      total: total,
                      correct: correct,
                      isComplete: isComplete,
                      compact: false,
                    ),
                  ),
                  SizedBox(width: _gap),
                  if (hasHint) _DicaButton(onTap: onHint, compact: false),
                  if (hasHint) SizedBox(width: _gap),
                  _AudioPlaceholder(compact: false),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================================
// Sub-widgets — visually identical to GameTopHud counterparts
// ===========================================================================

/// Shared card shell matching GameTopHud's _HudCard exactly.
class _HudCard extends StatelessWidget {
  final Widget child;
  final double height;

  const _HudCard({
    required this.child,
    this.height = ClassificationHud._compactCardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
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
      child: child,
    );
  }
}

/// Biome / phase card — shows the biome name with an icon.
class _BiomeCard extends StatelessWidget {
  final String? name;
  final bool compact;

  const _BiomeCard({this.name, this.compact = true});

  IconData _biomeIcon() {
    switch (name?.toLowerCase() ?? '') {
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
      height: compact
          ? ClassificationHud._compactCardHeight
          : ClassificationHud._cardHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _biomeIcon(),
            size: compact
                ? ClassificationHud._compactIconSize
                : ClassificationHud._iconSize,
            color: const Color(0xFFBBF7D0),
          ),
          SizedBox(width: compact ? 4 : 8),
          Flexible(
            child: Text(
              name ?? 'Classifica\u00E7\u00E3o',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: compact
                    ? ClassificationHud._compactBiomeFont
                    : ClassificationHud._fontSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF0FDF4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Score card — star icon + current score.
class _ScoreCard extends StatelessWidget {
  final int score;
  final bool compact;

  const _ScoreCard({required this.score, this.compact = true});

  @override
  Widget build(BuildContext context) {
    return _HudCard(
      height: compact
          ? ClassificationHud._compactCardHeight
          : ClassificationHud._cardHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact
                ? ClassificationHud._compactIconSmall
                : ClassificationHud._iconSize,
            color: const Color(0xFFFFD43B),
          ),
          SizedBox(width: compact ? 4 : 8),
          Flexible(
            child: Text(
              compact ? '$score' : 'Pontos: $score',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: compact
                    ? ClassificationHud._compactFontSize
                    : ClassificationHud._fontSize,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFFD43B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress card — shows "X/Y posicionados" with an animated green bar.
///
/// Mirrors GameTopHud._ConnectionCard exactly in appearance.
class _ProgressCard extends StatelessWidget {
  final int placed;
  final int total;
  final int correct;
  final bool isComplete;
  final bool compact;

  const _ProgressCard({
    required this.placed,
    required this.total,
    required this.correct,
    required this.isComplete,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayTotal = total > 0 ? total : 1;
    final displayValue = isComplete ? correct : placed;
    final progress = (displayValue / displayTotal).clamp(0.0, 1.0);

    return _HudCard(
      height: compact
          ? ClassificationHud._compactCardHeight
          : ClassificationHud._cardHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 4 : 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Number + label row ---
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$displayValue',
                    style: TextStyle(
                      fontSize: compact ? 16 : 22,
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
                        fontSize: compact ? 12 : 13,
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
                        'posicionados',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFBBF7D0).withValues(alpha: 0.6),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: compact ? 2 : 3),
            // --- Animated progress bar ---
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Container(
                  height: 5,
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
                            color: const Color(
                              0xFF7ED957,
                            ).withValues(alpha: 0.4),
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
      ),
    );
  }
}

/// Dica (hint) button — small pill/button with a lightbulb icon.
class _DicaButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool compact;

  const _DicaButton({this.onTap, this.compact = true});

  @override
  Widget build(BuildContext context) {
    final size = compact
        ? ClassificationHud._compactButtonSize
        : ClassificationHud._cardHeight;
    final iconSize = compact
        ? ClassificationHud._compactIconSize
        : ClassificationHud._iconSize;
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: 'Dica',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled
                  ? const Color(0xFFFFC107).withValues(alpha: 0.65)
                  : const Color(0xFF2E7D32).withValues(alpha: 0.40),
              width: 2,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: Offset.zero,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            Icons.lightbulb_outline,
            color: enabled
                ? const Color(0xFFFFC107)
                : const Color(0xFFF0FDF4).withValues(alpha: 0.30),
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

/// Audio placeholder — matches the circular AudioToggleButton shape.
class _AudioPlaceholder extends StatelessWidget {
  final bool compact;

  const _AudioPlaceholder({this.compact = true});

  @override
  Widget build(BuildContext context) {
    final size = compact
        ? ClassificationHud._compactButtonSize
        : ClassificationHud._cardHeight;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.65),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFF7ED957).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Icon(
        Icons.volume_up_rounded,
        color: const Color(0xFFBBF7D0),
        size: compact
            ? ClassificationHud._compactIconSize
            : ClassificationHud._iconSize,
      ),
    );
  }
}
