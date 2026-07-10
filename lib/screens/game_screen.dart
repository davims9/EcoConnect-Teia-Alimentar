import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/game.dart' as flame;
import 'package:provider/provider.dart';
import '../game/food_web_game.dart';
import '../services/game_service.dart';
import '../services/audio_service.dart';
import '../widgets/stars_display.dart';
import '../widgets/hover_button.dart';
import '../widgets/game_top_hud.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late FoodWebGame _game;
  bool _completionShown = false;
  String? _connectionMessage;
  bool _connectionIsCorrect = false;
  int _connectionKey = 0;

  @override
  void initState() {
    super.initState();
    final service = context.read<GameService>();
    _game = FoodWebGame(gameService: service);
    _game.onConnectionResult = _onConnectionResult;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AudioService.instance.init();
      if (service.currentPhase != null) {
        _game.loadPhase();
        AudioService.instance.playAmbient(service.currentPhase!.biome);
      }
    });
  }

  @override
  void dispose() {
    AudioService.instance.stopAmbient();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        body: _buildBackground(
          child: Consumer<GameService>(
            builder: (context, service, _) {
              if (service.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
              }
              if (service.phaseComplete && !_completionShown) {
                _completionShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showCompletionModal(context, service);
                });
              }
              return Material(
                type: MaterialType.transparency,
                child: Stack(
                  children: [
                    // Game fills the entire available area.
                    flame.GameWidget(game: _game),
                    // Top HUD — unconditionally overlaid above the game.
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: GameTopHud(
                        onBackTap: _showExitConfirmation,
                      ),
                    ),
                    // Connection feedback overlay (mid-screen).
                    if (_connectionMessage != null)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.25,
                        left: 24,
                        right: 24,
                        child: _buildConnectionMessage(),
                      ),
                    // Bottom HUD — submit / status buttons.
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildHud(service),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackground({required Widget child}) {
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
      child: child,
    );
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Widget _buildHud(GameService service) {
    final made = service.playerConnections.length;
    final canSubmit = made > 0 && !service.submitted && !service.phaseComplete;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0A1F14).withValues(alpha: 0.6),
            const Color(0xFF0A1F14).withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (canSubmit)
            HoverButton(
              onTap: () => _onSubmit(service),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
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
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 16, color: const Color(0xFFE8F5E9)),
                    const SizedBox(width: 6),
                    Text(
                      'SUBMETER',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: const Color(0xFFE8F5E9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (service.submitted && !service.phaseComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A24).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: const Color(0xFF81C784).withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  const Text(
                    'Aguardando...',
                    style: TextStyle(fontSize: 13, color: Color(0xFF81C784)),
                  ),
                ],
              ),
            ),
          if (service.phaseComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: const Color(0xFFA5D6A7)),
                  const SizedBox(width: 6),
                  Text(
                    'Concluído',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA5D6A7),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _onSubmit(GameService service) {
    _game.submitPhase();
  }

  void _onConnectionResult(bool correct, String message) {
    if (!mounted) return;
    setState(() {
      _connectionMessage = message;
      _connectionIsCorrect = correct;
      _connectionKey++;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _connectionMessage = null);
    });
  }

  Widget _buildConnectionMessage() {
    final parts = (_connectionMessage ?? '').split('\n\n');
    final title = parts.isNotEmpty ? parts[0] : '';
    final body = parts.length > 1 ? parts[1] : '';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: child,
      ),
      child: Container(
        key: ValueKey(_connectionKey),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _connectionIsCorrect
              ? const Color(0xFF1B5E20).withValues(alpha: 0.55)
              : const Color(0xFFE6553A).withValues(alpha: 0.40),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (_connectionIsCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF8A65))
                  .withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 2),
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

  void _showCompletionModal(BuildContext context, GameService service) {
    AudioService.instance.playComplete();
    final totalCorrect = service.correctConnections.length;
    final correctCount = service.correctCount;
    final stars = totalCorrect == 0
        ? 0
        : service.errors == 0
            ? 3
            : service.errors <= (totalCorrect * 0.4).ceil()
                ? 2
                : 1;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: const Color(0xFF0A1F14).withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: anim1,
                curve: Curves.easeOut,
              )),
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                margin: const EdgeInsets.all(20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D2B1A), Color(0xFF164A2A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'FASE COMPLETA!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      color: const Color(0xFFE8F5E9),
                      shadows: [
                        Shadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  StarsDisplay(stars: stars, size: 36),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _resultStat(
                        Icons.check_circle_rounded,
                        '$correctCount',
                        'Acertos',
                        const Color(0xFF4CAF50),
                      ),
                      _resultStat(
                        Icons.cancel_rounded,
                        '${service.errors}',
                        'Erros',
                        const Color(0xFFEF5350),
                      ),
                      _resultStat(
                        Icons.timer_outlined,
                        _formatTime(service.totalPhaseTime -
                            service.remainingSeconds),
                        'Tempo',
                        const Color(0xFF81C784),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1B5E20).withValues(alpha: 0.5),
                          const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'PONTUAÇÃO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: Color(0xFF81C784),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service.score} pts',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE8F5E9),
                            shadows: [
                              Shadow(
                                color: Color(0xFF4CAF50),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  HoverButton(
                    onTap: () async {
                      await service.saveScore();
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).pop();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF66BB6A).withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_rounded,
                              size: 18, color: Color(0xFFE8F5E9)),
                          SizedBox(width: 10),
                          Text(
                            'VOLTAR ÀS FASES',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: Color(0xFFE8F5E9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        );
        },
    );
  }

  Widget _resultStat(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE8F5E9),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF81C784).withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
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
          'Sair da fase?',
          style: TextStyle(
            color: Color(0xFFE8F5E9),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Seu progresso será perdido.',
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
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

