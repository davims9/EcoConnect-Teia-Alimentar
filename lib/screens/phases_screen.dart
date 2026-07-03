import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phase.dart';
import '../services/game_service.dart';
import '../widgets/phase_card.dart';
import 'biome_intro_screen.dart';

class PhasesScreen extends StatefulWidget {
  const PhasesScreen({super.key});

  @override
  State<PhasesScreen> createState() => _PhasesScreenState();
}

class _PhasesScreenState extends State<PhasesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameService>().loadPhases();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
                Expanded(child: _buildPhaseList()),
              ],
            ),
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
            'SELECIONAR FASE',
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

  Widget _buildPhaseList() {
    return Consumer<GameService>(
      builder: (context, service, _) {
        if (service.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          );
        }
        if (service.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: const Color(0xFFEF5350).withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    service.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFEF5350),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSecondaryButton(
                    label: 'TENTAR NOVAMENTE',
                    icon: Icons.refresh_rounded,
                    onTap: () => service.loadPhases(),
                  ),
                ],
              ),
            ),
          );
        }
        if (service.phases.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma fase disponível.',
              style: TextStyle(color: Color(0xFF81C784)),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: service.phases.length,
          itemBuilder: (context, index) {
            final phase = service.phases[index];
            return PhaseCard(
              phase: phase,
              onTap: () => _onPhaseTap(context, phase),
            );
          },
        );
      },
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A24),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF81C784)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Color(0xFFA5D6A7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPhaseTap(BuildContext context, Phase phase) async {
    final service = context.read<GameService>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final isUnlocked = await service.isPhaseUnlocked(phase.id!);
    if (!mounted) return;
    if (!isUnlocked && phase.id != 1) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Complete a fase anterior com pelo menos 1 estrela!',
          ),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    navigator
        .push(MaterialPageRoute(builder: (_) => BiomeIntroScreen(phase: phase)))
        .then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            service.refreshUnlockStatus();
          });
        });
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
