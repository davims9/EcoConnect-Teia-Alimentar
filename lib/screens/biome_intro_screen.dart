import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/asset_paths.dart';
import '../models/organism.dart';
import '../models/phase.dart';
import '../services/game_service.dart';
import '../widgets/hover_button.dart';
import 'game_screen.dart';

class BiomeIntroScreen extends StatefulWidget {
  final Phase phase;

  const BiomeIntroScreen({super.key, required this.phase});

  @override
  State<BiomeIntroScreen> createState() => _BiomeIntroScreenState();
}

class _BiomeIntroScreenState extends State<BiomeIntroScreen> {
  List<Organism>? _organisms;
  bool _isLoading = true;
  String? _error;

  static const Map<String, _BiomeInfo> _biomeInfo = {
    'campo': _BiomeInfo(
      name: 'Campo',
      description:
          'O campo \u00e9 um ambiente aberto e ensolarado, com muita vegeta\u00e7\u00e3o rasteira. Aqui, diferentes animais e plantas dependem uns dos outros para se alimentar.',
    ),
    'floresta': _BiomeInfo(
      name: 'Floresta',
      description:
          'A floresta \u00e9 cheia de \u00e1rvores altas e sombra, abrigando uma grande variedade de seres vivos. Cada organismo tem seu papel na teia alimentar.',
    ),
    'oceano': _BiomeInfo(
      name: 'Oceano',
      description:
          'O oceano \u00e9 um mundo azul e profundo, cheio de vida. Das algas aos grandes tubar\u00f5es, todos est\u00e3o conectados na cadeia alimentar.',
    ),
    'pantanal': _BiomeInfo(
      name: 'Pantanal',
      description:
          'O pantanal \u00e9 uma grande plan\u00edcie alagada, com uma das maiores biodiversidades do planeta. Plantas, peixes e jacar\u00e9s convivem em equil\u00edbrio.',
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadOrganisms();
  }

  Future<void> _loadOrganisms() async {
    try {
      final service = context.read<GameService>();
      final organisms = await service.getOrganismsForPhase(widget.phase.id!);
      if (!mounted) return;
      setState(() {
        _organisms = organisms;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Nao foi possivel carregar os organismos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.phase;
    final bgPath = OrganismAssetPath.getBackgroundPath(phase.id!);
    final info = _biomeInfo[phase.biome] ??
        _BiomeInfo(name: phase.name, description: '');

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen biome background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/$bgPath',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay for readability
          Positioned.fill(
            child: Container(
              color: const Color(0xFF191C1B).withValues(alpha: 0.45),
            ),
          ),
          // Content layer
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4CAF50),
                          ),
                        )
                      : _buildContent(info),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          HoverButton(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A24).withValues(alpha: 0.8),
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
          ),
        ],
      ),
    );
  }

  Widget _buildContent(_BiomeInfo info) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Biome name / title
          Text(
            info.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
              color: const Color(0xFFE8F5E9),
              height: 1.2,
              shadows: [
                Shadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
                  blurRadius: 16,
                ),
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              info.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE8F5E9).withValues(alpha: 0.92),
                height: 1.55,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Organisms section label
          Text(
            'ORGANISMOS ENCONTRADOS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: const Color(0xFF81C784).withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          // Organism sprites
          _buildOrganismsGrid(),
          const SizedBox(height: 36),
          // Explore button
          _buildExploreButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOrganismsGrid() {
    if (_organisms == null || _organisms!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          _error ?? 'Nenhum organismo encontrado.',
          style: TextStyle(
            color: const Color(0xFF81C784).withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
      );
    }

    return Center(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: _organisms!.map((organism) {
          return _buildOrganismCard(organism);
        }).toList(),
      ),
    );
  }

  Widget _buildOrganismCard(Organism organism) {
    final spritePath = 'assets/images/${OrganismAssetPath.getPath(organism)}';

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sprite image
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A24).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedSpriteThumbnail(
                imagePath: spritePath,
                size: 52,
                organismName: organism.name,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Name below sprite
          Text(
            organism.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE8F5E9).withValues(alpha: 0.9),
              height: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreButton() {
    return _GradientButton(
      onTap: _onExplore,
      label: 'EXPLORAR',
    );
  }

  void _onExplore() async {
    final service = context.read<GameService>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final success = await service.loadPhase(widget.phase);
    if (!mounted) return;

    if (!success) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Erro ao carregar a fase.'),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}

/// Internal data holder for biome presentation info.
class _BiomeInfo {
  final String name;
  final String description;

  const _BiomeInfo({required this.name, required this.description});
}

/// Reusable green gradient button with press animation.
class _GradientButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const _GradientButton({required this.onTap, required this.label});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isPressed
                  ? [const Color(0xFF1B5E20), const Color(0xFF0D3B12)]
                  : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50)
                    .withValues(alpha: _isPressed ? 0.15 : 0.3),
                blurRadius: _isPressed ? 8 : 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: const Color(0xFFE8F5E9),
              shadows: [
                Shadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class AnimatedSpriteThumbnail extends StatefulWidget {
  final String imagePath;
  final double size;
  final String organismName;

  const AnimatedSpriteThumbnail({
    super.key,
    required this.imagePath,
    required this.size,
    required this.organismName,
  });

  @override
  State<AnimatedSpriteThumbnail> createState() => _AnimatedSpriteThumbnailState();
}

class _AnimatedSpriteThumbnailState extends State<AnimatedSpriteThumbnail> {
  int _currentIndex = 0;
  Timer? _timer;
  final List<int> _pingPongSequence = [0, 1, 2, 3, 4, 5, 4, 3, 2, 1];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _pingPongSequence.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _pingPongSequence[_currentIndex];

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: -(frame * widget.size),
              top: 0,
              bottom: 0,
              child: Image.asset(
                widget.imagePath,
                height: widget.size,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: widget.size * 6,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: widget.size,
                      child: Center(
                        child: Text(
                          widget.organismName.isNotEmpty
                              ? widget.organismName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Color(0xFF81C784),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

