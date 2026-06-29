import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEmblemSection(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('O QUE É?'),
                        const SizedBox(height: 8),
                        _buildText(
                          'Food Web Builder é um jogo educacional que ensina '
                          'conceitos de ecologia e cadeias alimentares de forma '
                          'interativa. O jogador constrói teias alimentares '
                          'conectando organismos de diferentes biomas brasileiros.',
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle('BIOMAS'),
                        const SizedBox(height: 12),
                        _buildBiomeCard(Icons.grass, 'Campo', 'Ecossistema de gramíneas', const Color(0xFFA5D6A7)),
                        const SizedBox(height: 8),
                        _buildBiomeCard(Icons.forest, 'Floresta', 'Mata Atlântica e Floresta Tropical', const Color(0xFF80CBC4)),
                        const SizedBox(height: 8),
                        _buildBiomeCard(Icons.water, 'Oceano', 'Ecossistema marinho', const Color(0xFF90CAF9)),
                        const SizedBox(height: 8),
                        _buildBiomeCard(Icons.landscape, 'Pantanal', 'Maior planície alagável do mundo', const Color(0xFFFFCC80)),
                        const SizedBox(height: 32),
                        _buildSectionTitle('TECNOLOGIAS'),
                        const SizedBox(height: 8),
                        _buildTechCard(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('OBJETIVO ACADÊMICO'),
                        const SizedBox(height: 8),
                        _buildText(
                          'Projeto desenvolvido para demonstrar a utilização '
                          'conjunta de Flutter, Flame Engine, SQLite e estruturas '
                          'de grafos para persistência local em jogos educacionais.',
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: _buildResetButton(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 8),
          Text(
            'SOBRE',
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

  Widget _buildEmblemSection() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.eco, size: 40, color: Color(0xFF81C784)),
          ),
          const SizedBox(height: 12),
          Text(
            'FOOD WEB BUILDER',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: const Color(0xFFA5D6A7),
              shadows: [
                Shadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
        color: const Color(0xFF4CAF50),
        shadows: [
          Shadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: const Color(0xFFA5D6A7).withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildBiomeCard(IconData icon, String name, String description, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          color: iconColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0D2B1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE8F5E9),
                  fontSize: 15,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: const Color(0xFF81C784).withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _techItem('Flutter & Dart'),
          const SizedBox(height: 10),
          _techItem('Flame Engine'),
          const SizedBox(height: 10),
          _techItem('SQLite'),
          const SizedBox(height: 10),
          _techItem('Material Design 3'),
        ],
      ),
    );
  }

  Widget _techItem(String name) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFFA5D6A7).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: () => _confirmReset(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF3E2723).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFC62828).withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 16, color: const Color(0xFFEF5350).withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            Text(
              'REDEFINIR PROGRESSO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFFEF5350).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D2B1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        title: const Text(
          'Redefinir progresso?',
          style: TextStyle(color: Color(0xFFE8F5E9), fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Todo o progresso do jogo será perdido.',
          style: TextStyle(color: Color(0xFFA5D6A7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF81C784)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GameService>().resetAllScores();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Progresso redefinido!'),
                  backgroundColor: const Color(0xFF1B5E20),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Redefinir'),
          ),
        ],
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
