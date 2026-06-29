import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/organism.dart';

class OrganismWidget extends StatelessWidget {
  final Organism organism;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const OrganismWidget({
    super.key,
    required this.organism,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted ? AppColors.primary : AppColors.outlineVariant,
            width: isHighlighted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(organism.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              organism.name,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


}
