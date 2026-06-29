import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phase.dart';
import '../models/score.dart';
import '../repositories/score_repository.dart';
import '../services/game_service.dart';
import '../widgets/stars_display.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  final ScoreRepository _scoreRepository = ScoreRepository();
  int _selectedPhaseId = 0;
  List<Phase> _phases = [];
  bool _isLoading = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<GameService>();
      await service.loadPhases();
      _phases = service.phases;
      if (_phases.isNotEmpty) _selectedPhaseId = _phases.first.id!;
    } catch (_) {}
    setState(() => _isLoading = false);
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
                if (!_isLoading && _phases.isNotEmpty) _buildPhaseSelector(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                        )
                      : _phases.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.leaderboard_outlined,
                                        size: 56,
                                        color: const Color(0xFF81C784).withValues(alpha: 0.5)),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Nenhuma pontuação registrada.\nComplete uma fase para aparecer aqui.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF81C784),
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _RankingList(
                              phaseId: _selectedPhaseId,
                              scoreRepository: _scoreRepository,
                            ),
                ),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 8),
          Text(
            'RANKING',
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

  Widget _buildPhaseSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A24).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedPhaseId,
            isExpanded: true,
            dropdownColor: const Color(0xFF0D2B1A),
            icon: const Icon(Icons.expand_more, color: Color(0xFF81C784)),
            style: const TextStyle(
              color: Color(0xFFE8F5E9),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            items: _phases
                .map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPhaseId = value);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  final int phaseId;
  final ScoreRepository scoreRepository;

  const _RankingList({
    required this.phaseId,
    required this.scoreRepository,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Score>>(
      future: scoreRepository.getByPhaseId(phaseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          );
        }
        final scores = snapshot.data ?? [];
        if (scores.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Nenhuma pontuação para esta fase.',
                style: TextStyle(
                  color: const Color(0xFF81C784).withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: scores.length,
          itemBuilder: (context, index) {
            final score = scores[index];
            final isTop3 = index < 3;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A3A24).withValues(alpha: isTop3 ? 0.95 : 0.8),
                      const Color(0xFF0D2B1A).withValues(alpha: isTop3 ? 0.85 : 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTop3
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                        : const Color(0xFF2E7D32).withValues(alpha: 0.25),
                    width: isTop3 ? 1.5 : 1,
                  ),
                  boxShadow: isTop3
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    _buildPosition(index),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            score.playerName.isEmpty ? 'Anônimo' : score.playerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE8F5E9),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${score.score} pts',
                            style: TextStyle(
                              color: const Color(0xFF81C784).withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StarsDisplay(stars: score.stars, size: 18),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPosition(int index) {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final isTop3 = index < 3;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isTop3 ? colors[index].withValues(alpha: 0.2) : const Color(0xFF0D2B1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTop3 ? colors[index].withValues(alpha: 0.5) : const Color(0xFF2E7D32).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: isTop3 ? colors[index] : const Color(0xFF81C784),
          ),
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
