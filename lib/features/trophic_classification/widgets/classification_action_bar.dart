import 'package:flutter/material.dart';
import '../services/classification_service.dart';

/// Floating "Verificar" (verify) CTA button.
///
/// Replaces the deprecated footer action bar.  The Dica (hint) button has
/// moved into [ClassificationHud].
class ClassificationActionBar extends StatelessWidget {
  final ClassificationService service;
  final VoidCallback? onVerify;

  const ClassificationActionBar({
    super.key,
    required this.service,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final canVerify = service.canVerify;
    final enabled = canVerify && onVerify != null;

    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: enabled ? onVerify : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFF7ED957)
                : const Color(0xFF0B3D22).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF7ED957)
                  : const Color(0xFF2E7D32).withValues(alpha: 0.40),
              width: 1.5,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF7ED957).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 18,
                color: enabled
                    ? const Color(0xFF14532D)
                    : const Color(0xFFF0FDF4).withValues(alpha: 0.30),
              ),
              const SizedBox(width: 8),
              Text(
                'Verificar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: enabled
                      ? const Color(0xFF14532D)
                      : const Color(0xFFF0FDF4).withValues(alpha: 0.30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
