import 'package:flutter/material.dart';

/// Reusable HUD card shell matching the ECOnnect design system.
///
/// Default values match the GameTopHud design tokens:
/// - 48 px height (36 px compact)
/// - 14 px border-radius (10 px compact)
/// - 16 px horizontal padding (8 px compact)
/// - 88 % dark-green background
/// - green border (configurable via [borderColor])
/// - soft green glow
class HudCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final bool compact;

  /// Height when not compact. Default: 48.
  final double height;

  /// Height when compact. Default: 36.
  final double compactHeight;

  /// Horizontal padding when not compact. Default: 16.
  final double padding;

  /// Horizontal padding when compact. Default: 8.
  final double compactPadding;

  /// Border radius when not compact. Default: 14.
  final double radius;

  /// Border radius when compact. Default: 10.
  final double compactRadius;

  const HudCard({
    super.key,
    required this.child,
    this.borderColor,
    this.compact = false,
    this.height = 48,
    this.compactHeight = 36,
    this.padding = 16,
    this.compactPadding = 8,
    this.radius = 14,
    this.compactRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? compactHeight : height,
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? compactPadding : padding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(compact ? compactRadius : radius),
        border: Border.all(
          color: (borderColor ?? const Color(0xFF2E7D32)).withValues(
            alpha: 0.65,
          ),
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
