import 'package:flutter/material.dart';
import '../hover_button.dart';

/// Circular back / home button matching the ECOnnect design system.
///
/// Default size (48 × 48) matches [AudioToggleButton].
class EcoBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;

  /// Diameter when not compact. Default: 48.
  final double size;

  /// Diameter when compact. Default: 40.
  final double compactSize;

  /// Icon size when not compact. Default: 22.
  final double iconSize;

  /// Icon size when compact. Default: 22.
  final double compactIconSize;

  const EcoBackButton({
    super.key,
    required this.onTap,
    this.compact = false,
    this.size = 48,
    this.compactSize = 40,
    this.iconSize = 22,
    this.compactIconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final s = compact ? compactSize : size;
    final i = compact ? compactIconSize : iconSize;
    return HoverButton(
      onTap: onTap,
      child: Container(
        width: s,
        height: s,
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
          Icons.arrow_back_rounded,
          color: const Color(0xFFF0FDF4),
          size: i,
        ),
      ),
    );
  }
}
