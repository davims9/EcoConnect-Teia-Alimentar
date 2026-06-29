import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int errors;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.errors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: AppColors.hint, size: 20),
        const SizedBox(width: 4),
        Text(
          '$score pts',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.close, color: AppColors.error, size: 20),
        const SizedBox(width: 4),
        Text(
          '$errors erros',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
