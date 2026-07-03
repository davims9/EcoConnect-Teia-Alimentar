import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phase.dart';
import '../services/game_service.dart';

class PhaseCard extends StatelessWidget {
  final Phase phase;
  final VoidCallback onTap;

  const PhaseCard({super.key, required this.phase, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unlockStatus = context.watch<GameService>().phaseUnlockStatus;
    final isUnlocked = unlockStatus[phase.id] ?? (phase.id == 1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isUnlocked ? onTap : null,
        child: Opacity(
          opacity: isUnlocked ? 1.0 : 0.45,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(
                    0xFF1A3A24,
                  ).withValues(alpha: isUnlocked ? 0.9 : 0.6),
                  const Color(
                    0xFF0D2B1A,
                  ).withValues(alpha: isUnlocked ? 0.8 : 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                    : const Color(0xFF2E7D32).withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                if (isUnlocked)
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _biomeIcon(phase.biome, isUnlocked),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE8F5E9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phase.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF81C784).withValues(alpha: 0.7),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isUnlocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A24),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF81C784),
                      size: 20,
                    ),
                  ),
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A24),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF81C784),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _biomeIcon(String biome, bool isUnlocked) {
    IconData icon;
    Color iconColor;

    switch (biome) {
      case 'campo':
        icon = Icons.grass;
        iconColor = const Color(0xFFA5D6A7);
      case 'floresta':
        icon = Icons.forest;
        iconColor = const Color(0xFF80CBC4);
      case 'oceano':
        icon = Icons.water;
        iconColor = const Color(0xFF90CAF9);
      case 'pantanal':
        icon = Icons.landscape;
        iconColor = const Color(0xFFFFCC80);
      default:
        icon = Icons.public;
        iconColor = const Color(0xFF81C784);
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0D2B1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iconColor.withValues(alpha: isUnlocked ? 0.5 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          if (isUnlocked)
            BoxShadow(color: iconColor.withValues(alpha: 0.2), blurRadius: 8),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor.withValues(alpha: isUnlocked ? 1 : 0.5),
        size: 28,
      ),
    );
  }
}
