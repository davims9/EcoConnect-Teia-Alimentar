import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/trophic_classification/repositories/classification_score_repository.dart';
import '../features/trophic_classification/services/classification_phase_builder.dart';
import '../features/trophic_classification/widgets/classification_game_screen.dart';
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

  static const _biomeKeys = [
    'classification_field_01',
    'classification_forest_01',
    'classification_ocean_01',
    'classification_pantanal_01',
  ];

  final Map<String, int> _classificationStars = {
    for (final k in _biomeKeys) k: 0,
  };

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
      _loadClassificationStars();
    });
  }

  Future<void> _loadClassificationStars() async {
    try {
      final repo = ClassificationScoreRepository();
      for (final key in _biomeKeys) {
        final best = await repo.getBestByClassificationPhaseKey(key);
        if (!mounted) return;
        _classificationStars[key] = best?.stars ?? 0;
      }
      if (mounted) setState(() {});
    } catch (_) {
      // Database may not be available (tests, first launch).
    }
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
          Flexible(
            child: Text(
              'SELECIONAR FASE',
              overflow: TextOverflow.ellipsis,
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
          itemCount: service.phases.length + 5,
          itemBuilder: (context, index) {
            if (index < service.phases.length) {
              final phase = service.phases[index];
              return PhaseCard(
                phase: phase,
                onTap: () => _onPhaseTap(context, phase),
              );
            }
            if (index == service.phases.length) {
              return _buildClassificationHeader(context);
            }
            return _buildClassificationBiomeCard(
              context,
              biomeIndex: index - service.phases.length - 1,
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

  Widget _buildClassificationHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32).withValues(alpha: 0.0),
                  const Color(0xFF2E7D32).withValues(alpha: 0.40),
                  const Color(0xFF2E7D32).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_tree_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classificação Trófica',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE8F5E9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Arraste os organismos para seus níveis corretos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFC4B5FD).withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationBiomeCard(
    BuildContext context, {
    required int biomeIndex,
  }) {
    final biomeNames = ['Campo', 'Floresta', 'Oceano', 'Pantanal'];
    final biomeEmojis = ['🌾', '🌲', '🌊', '🌴'];
    final biomeKeys = _biomeKeys;
    final colorAccents = [
      const Color(0xFF7ED957), // Campo — green
      const Color(0xFF4CAF50), // Floresta — forest
      const Color(0xFF42A5F5), // Oceano — blue
      const Color(0xFFFFCA28), // Pantanal — amber
    ];

    final name = biomeNames[biomeIndex];
    final emoji = biomeEmojis[biomeIndex];
    final key = biomeKeys[biomeIndex];
    final accent = colorAccents[biomeIndex];
    final stars = _classificationStars[key] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _onClassificationBiomeTap(context, biomeIndex: biomeIndex),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A3A24).withValues(alpha: 0.9),
                const Color(0xFF0D2B1A).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Emoji
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2B1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              // Name and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE8F5E9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Classificar organismos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA4F69E).withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final filled = i < stars;
                  return Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: 14,
                      color: filled
                          ? const Color(0xFFFFC107)
                          : const Color(0xFFFFC107).withValues(alpha: 0.15),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 6),
              // Arrow
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2B1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: accent,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onClassificationBiomeTap(
    BuildContext context, {
    required int biomeIndex,
  }) async {
    final builders = [
      const ClassificationPhaseBuilder().buildCampo,
      const ClassificationPhaseBuilder().buildFloresta,
      const ClassificationPhaseBuilder().buildOceano,
      const ClassificationPhaseBuilder().buildPantanal,
    ];
    final config = builders[biomeIndex]();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassificationGameScreen(config: config),
      ),
    );
    // Refresh stars after returning.
    await _loadClassificationStars();
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
