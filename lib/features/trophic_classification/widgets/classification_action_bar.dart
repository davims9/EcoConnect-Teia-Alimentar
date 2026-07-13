import 'package:flutter/material.dart';
import '../../../widgets/shared/hud_card.dart';
import '../services/classification_service.dart';

/// Bottom action bar with Hint and Verify buttons.
///
/// [onHint] — called when the Dica button is tapped (only fires
/// when the button is enabled). The parent is responsible for
/// showing the hint dialog.
///
/// [onVerify] — called when the Verificar button is tapped.
/// The parent runs the verification and shows the result.
class ClassificationActionBar extends StatelessWidget {
  final ClassificationService service;
  final VoidCallback? onHint;
  final VoidCallback? onVerify;

  const ClassificationActionBar({
    super.key,
    required this.service,
    this.onHint,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final canVerify = service.canVerify;
    final hasSelection = onHint != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: HudCard(
        height: 52,
        radius: 14,
        borderColor: const Color(0xFF2E7D32),
        child: Row(
          children: [
            const Spacer(flex: 1),
            // Dica button
            _ActionButton(
              icon: Icons.lightbulb_outline,
              label: 'Dica',
              isEnabled: hasSelection,
              onTap: onHint,
            ),
            const Spacer(flex: 1),
            Container(
              width: 1,
              height: 24,
              color: const Color(0xFF2E7D32).withValues(alpha: 0.30),
            ),
            const Spacer(flex: 1),
            // Verificar button
            _ActionButton(
              icon: Icons.check_circle_outline,
              label: 'Verificar',
              isEnabled: canVerify,
              onTap: canVerify ? onVerify : null,
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

/// A single action button in the bar.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isEnabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effective = isEnabled && onTap != null;
    final color = effective
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFF0FDF4).withValues(alpha: 0.30);

    return GestureDetector(
      onTap: effective ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: effective ? 1.0 : 0.45,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
