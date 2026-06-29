import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'phases_screen.dart';
import 'ranking_screen.dart';
import 'about_screen.dart';
import '../core/app_constants.dart';
import '../services/game_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
    ));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildContent(double height, double width) {
    final smallScreen = width < 360;
    final emblemSize = smallScreen ? 72.0 : 100.0;
    final titleSize = smallScreen ? 28.0 : 38.0;
    final subtitleSize = smallScreen ? 12.0 : 16.0;
    final playButtonHeight = smallScreen ? 54.0 : 64.0;
    final playButtonFontSize = smallScreen ? 18.0 : 22.0;
    final padding = smallScreen ? 24.0 : 40.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: height * 0.12),
        _buildEmblem(size: emblemSize),
        const SizedBox(height: 20),
        _buildTitle(fontSize: titleSize),
        const SizedBox(height: 8),
        _buildSubtitle(fontSize: subtitleSize),
        SizedBox(height: height * 0.08),
        _buildPlayButton(
          height: playButtonHeight,
          fontSize: playButtonFontSize,
          padding: padding,
        ),
        const SizedBox(height: 16),
        _buildSecondaryButtons(padding: padding),
        const SizedBox(height: 24),
        _buildPlayerName(),
        SizedBox(height: height * 0.08),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildParticles(),
          FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: h,
                    child: _buildContent(h, w),
                  ),
                ),
              ),
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

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            progress: _animController.value,
          ),
        );
      },
    );
  }

  Widget _buildEmblem({double size = 100}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
            blurRadius: 48,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Icon(
        Icons.eco,
        size: size * 0.48,
        color: const Color(0xFF81C784),
      ),
    );
  }

  Widget _buildTitle({double fontSize = 38}) {
    final small = fontSize < 32;
    return Column(
      children: [
        Text(
          'ECOCONNECT',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: small ? 4 : 6,
            color: const Color(0xFFE8F5E9),
            shadows: [
              Shadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                blurRadius: 20,
              ),
              const Shadow(
                color: Color(0xFF1B5E20),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'TEIA ALIMENTAR',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: small ? 12 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: small ? 5 : 8,
            color: const Color(0xFFA5D6A7),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle({double fontSize = 14}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize < 13 ? 24 : 48),
      child: Text(
        'Construa teias alimentares\ne descubra os ecossistemas!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: const Color(0xFF81C784).withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildPlayButton({
    double height = 64,
    double fontSize = 22,
    double padding = 40,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnim.value,
            child: GestureDetector(
              onTap: () => _navigateToPhases(context),
              child: Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF66BB6A).withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                      blurRadius: 32,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: height * 0.5,
                          color: const Color(0xFFE8F5E9),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'JOGAR',
                          style: TextStyle(
                            fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: const Color(0xFFE8F5E9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecondaryButtons({double padding = 40}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Expanded(
            child: _buildSecondaryButton(
              label: 'RANKING',
              icon: Icons.leaderboard_rounded,
              onTap: () => _navigateToRanking(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSecondaryButton(
              label: 'SOBRE',
              icon: Icons.info_outline_rounded,
              onTap: () => _navigateToAbout(context),
            ),
          ),
        ],
      ),
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
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A24),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
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
            Icon(icon, size: 18, color: const Color(0xFF81C784)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: const Color(0xFFA5D6A7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerName() {
    return Consumer<GameService>(
      builder: (context, service, _) => GestureDetector(
        onTap: () => _showNameDialog(context, service),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF1A3A24).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: const Color(0xFF81C784).withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                service.playerName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA5D6A7).withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.edit,
                size: 12,
                color: const Color(0xFF81C784).withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNameDialog(BuildContext context, GameService service) {
    final controller = TextEditingController(text: service.playerName);
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
        title: Text(
          'Seu nome',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE8F5E9),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: AppConstants.maxPlayerNameLength,
          style: const TextStyle(color: Color(0xFFE8F5E9)),
          decoration: InputDecoration(
            hintText: 'Digite seu nome',
            hintStyle: TextStyle(
              color: const Color(0xFF81C784).withValues(alpha: 0.5),
            ),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFF1A3A24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: const Color(0xFF81C784)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              service.setPlayerName(controller.text);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: const Color(0xFFE8F5E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _navigateToPhases(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PhasesScreen()),
    );
  }

  void _navigateToRanking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RankingScreen()),
    );
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const particleCount = 25;
    final rng = Random(42);
    final positions = List.generate(
      particleCount,
      (_) => Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      ),
    );
    final radii = List.generate(
      particleCount,
      (_) => 1.5 + rng.nextDouble() * 2.5,
    );

    for (int i = 0; i < particleCount; i++) {
      final floatOffset = sin(progress * 2 * pi + i * 1.3) * 15;
      final y = positions[i].dy + floatOffset;
      final alpha = (0.15 + rng.nextDouble() * 0.25) * progress;

      paint.color = const Color(0xFF81C784).withValues(alpha: alpha);
      canvas.drawCircle(Offset(positions[i].dx, y), radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
