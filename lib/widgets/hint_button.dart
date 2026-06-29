import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class HintButton extends StatelessWidget {
  final bool isAvailable;
  final int hintsUsed;
  final int maxHints;
  final VoidCallback? onPressed;

  const HintButton({
    super.key,
    required this.isAvailable,
    required this.hintsUsed,
    required this.maxHints,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isAvailable ? onPressed : null,
      icon: Icon(
        Icons.auto_fix_high,
        color: isAvailable ? AppColors.hint : AppColors.textSecondary,
        size: 20,
      ),
      label: Text(
        'Dica ($hintsUsed/$maxHints)',
        style: TextStyle(
          color: isAvailable ? AppColors.hint : AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}
