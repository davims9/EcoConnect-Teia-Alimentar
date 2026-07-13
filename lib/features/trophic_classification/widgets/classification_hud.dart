import 'package:flutter/material.dart';
import '../../../widgets/shared/eco_back_button.dart';
import '../../../widgets/shared/hud_card.dart';
import '../services/classification_service.dart';

/// Top HUD for the Classification game screen.
///
/// Shows back button, biome name, score/stars, and an audio placeholder.
class ClassificationHud extends StatelessWidget {
  final ClassificationService service;
  final VoidCallback? onBack;

  const ClassificationHud({super.key, required this.service, this.onBack});

  @override
  Widget build(BuildContext context) {
    final config = service.config;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: HudCard(
        height: 48,
        child: Row(
          children: [
            // Back button
            EcoBackButton(
              onTap: onBack ?? () => Navigator.pop(context),
              compact: true,
              size: 36,
              compactSize: 36,
            ),
            const SizedBox(width: 10),
            // Biome + Score column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config?.biomeName ?? 'Classificação',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF0FDF4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Score
                      Icon(
                        Icons.star,
                        size: 14,
                        color: const Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.score}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(
                            0xFFFFC107,
                          ).withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Stars
                      ...List.generate(3, (i) {
                        final filled = i < service.stars;
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            filled ? Icons.star : Icons.star_border,
                            size: 14,
                            color: filled
                                ? const Color(0xFFFFC107)
                                : const Color(
                                    0xFFFFC107,
                                  ).withValues(alpha: 0.30),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            // Audio placeholder (matches the circular button shape)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF0B3D22).withValues(alpha: 0.88),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.65),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.volume_up_outlined,
                size: 18,
                color: Color(0xFFA4F69E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
