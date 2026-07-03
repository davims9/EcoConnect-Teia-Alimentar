import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/game.dart' as flame;

import '../game/tutorial_game.dart';
import 'phases_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TutorialGame _game = TutorialGame();
  String? _message;
  bool _isCorrect = false;
  bool _tutorialComplete = false;
  int _messageKey = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
    _game.onConnectionResult = _onConnectionResult;
  }

  @override
  void dispose() {
    _animController.dispose();
    _game.onConnectionResult = null;
    super.dispose();
  }

  void _onConnectionResult(bool correct, String message) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _isCorrect = correct;
      _messageKey++;
      if (correct) {
        _tutorialComplete = true;
      }
    });
    // Auto-clear error messages after 3 seconds
    if (!correct) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _message = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _ParticleOverlay(progress: _animController.value),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildInstruction(),
                Expanded(child: _buildGameArea()),
                if (_tutorialComplete) _buildBottomButtons(),
                if (!_tutorialComplete) const SizedBox(height: 24),
              ],
            ),
          ),
          // Feedback message overlay
          if (_message != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.38,
              left: 24,
              right: 24,
              child: _buildMessage(),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1F14),
            Color(0xFF0D2B1A),
            Color(0xFF123B22),
            Color(0xFF164A2A),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 8),
          Text(
            'COMO JOGAR',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              color: const Color(0xFFE8F5E9),
              shadows: [
                Shadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
                const Shadow(
                  color: Color(0xFF1B5E20),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A24),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF81C784),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildInstruction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 16),
      child: Text(
        'Experimente ligar a águia ao coelho.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: const Color(0xFFA5D6A7).withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildGameArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: flame.GameWidget(
          key: const ValueKey('tutorial_game'),
          game: _game,
        ),
      ),
    );
  }

  Widget _buildMessage() {
    final parts = (_message ?? '').split('\n\n');
    final title = parts.isNotEmpty ? parts[0] : '';
    final body = parts.length > 1 ? parts[1] : '';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Container(
        key: ValueKey(_messageKey),
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isCorrect
              ? const Color(0xFF1B5E20).withValues(alpha: 0.55)
              : const Color(0xFFB71C1C).withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  (_isCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350))
                      .withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'VOLTAR',
              icon: Icons.home_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              label: 'COMEÇAR',
              icon: Icons.play_arrow_rounded,
              gradient: true,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PhasesScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool gradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: gradient
              ? const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: gradient ? null : const Color(0xFF1A3A24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: gradient
                ? const Color(0xFF66BB6A).withValues(alpha: 0.5)
                : const Color(0xFF2E7D32).withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: gradient
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFE8F5E9)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: const Color(0xFFE8F5E9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticleOverlay extends StatelessWidget {
  final double progress;
  const _ParticleOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ParticlePainter(progress: progress),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const particleCount = 20;
    final rng = Random(42);
    for (int i = 0; i < particleCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = 1.5 + rng.nextDouble() * 2.5;
      final floatOffset = sin(progress * 2 * pi + i * 1.3) * 12;
      final alpha = (0.12 + rng.nextDouble() * 0.2) * progress;
      paint.color = const Color(0xFF81C784).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y + floatOffset), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
