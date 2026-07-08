import 'package:flutter/material.dart';

/// A refined progress card for the game HUD that shows the player's
/// correct connection count vs total connections needed.
///
/// Displays a large number + "/total" (with optional "conexões" label on
/// wide screens) and an animated green gradient progress bar with glow.
///
/// Visual direction: dark green translucent card, rounded border,
/// large readable numbers, kid-friendly game HUD style.
class ProgressCard extends StatelessWidget {
  final int correct;
  final int total;

  const ProgressCard({
    super.key,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 480;
    final progress = total > 0 ? correct / total : 0.0;

    return Container(
      constraints: const BoxConstraints(minWidth: 130, maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top row: number / total [+ "conexões"] ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$correct',
                style: TextStyle(
                  fontSize: isWide ? 28 : 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFF0FDF4),
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: isWide ? 3 : 2),
                child: Text(
                  '/$total',
                  style: TextStyle(
                    fontSize: isWide ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFBBF7D0).withValues(alpha: 0.7),
                    height: 1.0,
                  ),
                ),
              ),
              if (isWide) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
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

          const SizedBox(height: 8),

          // --- Animated progress bar ---
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFF0A1F14).withValues(alpha: 0.5),
                ),
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF37B24D), Color(0xFF7ED957)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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
