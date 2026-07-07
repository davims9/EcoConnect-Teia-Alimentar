import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../core/app_colors.dart';
import '../models/organism.dart';
import '../services/audio_service.dart';
import '../services/game_service.dart';
import 'components/background_component.dart';
import 'components/organism_component.dart';
import 'components/connection_line.dart';
import 'effects/connection_effect.dart';
import 'food_web_game.dart';

/// A simplified game for the "Como Jogar" tutorial.
///
/// Shows only Águia (predator) and Coelho (prey) and validates the single
/// correct connection: Águia → Coelho.
class TutorialGame extends FoodWebGame {
  /// Whether the player has completed the tutorial correctly.
  bool tutorialCompleted = false;

  TutorialGame() : super(gameService: _createDummyService());

  /// Creates a minimal game service that satisfies FoodWebGame's constructor
  /// but is never used for tutorial logic.
  static _DummyGameService _createDummyService() => _DummyGameService();

  @override
  Color backgroundColor() => const Color(0xFF0D2B1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ── Campo biome background with dark overlay ──
    add(BackgroundComponent(spritePath: 'cenarios/campo.png', size: size));

    // ── Águia (predator, id: 7, phaseId: 1 ─ Campo) ──
    const eagle = Organism(
      id: 7,
      phaseId: 1,
      name: 'Águia',
      emoji: '🦅',
      trophicLevel: 'predador_topo',
      positionX: 0,
      positionY: 0,
    );
    final eagleComponent = OrganismComponent(organism: eagle);
    organismComponents.add(eagleComponent);

    // ── Coelho (prey, id: 3, phaseId: 1 ─ Campo) ──
    const rabbit = Organism(
      id: 3,
      phaseId: 1,
      name: 'Coelho',
      emoji: '🐰',
      trophicLevel: 'consumidor_primario',
      positionX: 0,
      positionY: 0,
    );
    final rabbitComponent = OrganismComponent(organism: rabbit);
    organismComponents.add(rabbitComponent);

    add(eagleComponent);
    add(rabbitComponent);

    // Position after all components are added
    _reposition();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _reposition();
  }

  void _reposition() {
    if (organismComponents.length < 2) return;
    organismComponents[0].position = Vector2(size.x * 0.28, size.y * 0.48);
    organismComponents[1].position = Vector2(size.x * 0.72, size.y * 0.48);
  }

  @override
  void loadPhase() {
    // No-op: tutorial does not load real phases.
  }

  @override
  void onDragEnd() {
    // Clear highlights on all organisms (can't access _lastHoveredTarget
    // directly since it's private to FoodWebGame)
    for (final comp in organismComponents) {
      comp.setHighlight(false);
    }

    if (tutorialCompleted) return;

    final source = connectionSystem.dragSource;
    final target = connectionSystem.endDrag(organismComponents);
    dragIndicator = null;

    if (target != null && source != null) {
      // Following the same naming convention as FoodWebGame.onDragEnd:
      //   sourceId = target (dropped-on organism, the prey)
      //   targetId = source (dragged-from organism, the predator)
      final preyId = target.organism.id!;
      final predatorId = source.organism.id!;

      // Draw the line first (visual feedback)
      final line = ConnectionLine(
        sourceId: preyId,
        targetId: predatorId,
        start: getOrganismCenter(source),
        end: getOrganismCenter(target),
      );
      connectionLines.add(line);
      add(line);

      final particleCenter = Offset(size.x / 2, size.y * 0.3);

      // Correct: Águia (id:7) → Coelho (id:3)  → key "3-7"
      if (preyId == 3 && predatorId == 7) {
        AudioService.instance.playCorrect();
        line.flashThenColor(AppColors.nextConnectionColor());
        _animatePredatorLunge(source, target);
        _scheduleParticles(particleCenter, true);
        tutorialCompleted = true;
        onConnectionResult?.call(
          true,
          '🎉 Muito bem!\n\nAgora você já sabe jogar.',
        );
      }
      // Reversed: Coelho → Águia → key "7-3"
      else if (preyId == 7 && predatorId == 3) {
        AudioService.instance.playWrong();
        line.animateColor(AppColors.connectionError);
        source.addShakeEffect();
        _scheduleParticles(particleCenter, false);
        onConnectionResult?.call(
          false,
          '🌿 Quase!\n\nA águia é o predador. '
          'Tente ligar Águia → Coelho.',
        );
        _scheduleWrongLineRemoval(line, preyId, predatorId);
      }
      // Wrong connection (e.g. Coelho → itself, etc.)
      else {
        AudioService.instance.playWrong();
        line.animateColor(AppColors.connectionError);
        source.addShakeEffect();
        _scheduleParticles(particleCenter, false);
        onConnectionResult?.call(
          false,
          '❌ Não é essa conexão!\n\n'
          'Ligue a Águia até o Coelho.',
        );
        _scheduleWrongLineRemoval(line, preyId, predatorId);
      }
    }
  }

  void _scheduleParticles(Offset center, bool isCorrect) {
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!isLoaded) return;
      add(ConnectionEffect(center: center, isCorrect: isCorrect));
    });
  }

  void _scheduleWrongLineRemoval(
    ConnectionLine line,
    int sourceId,
    int targetId,
  ) {
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!line.isLoaded) return;
      line.fadeOut();
      connectionLines.remove(line);
    });
  }

  void _animatePredatorLunge(
    OrganismComponent predator,
    OrganismComponent prey,
  ) {
    predator.disableIdleAnimations();
    final original = predator.position.clone();
    final targetPos = prey.position.clone();
    final direction = (targetPos - original).normalized();
    final dist = (targetPos - original).length;
    final lungeTarget = original + direction * (dist * 0.85);

    predator.add(
      MoveToEffect(
          lungeTarget,
          EffectController(duration: 0.45, curve: Curves.easeOut),
        )
        ..onComplete = () {
          predator.add(
            MoveToEffect(
                original,
                EffectController(duration: 1.0, curve: Curves.easeInOut),
              )
              ..onComplete = () {
                predator.enableIdleAnimations();
              },
          );
        },
    );
  }
}

/// Minimal GameService stub used only to satisfy FoodWebGame's constructor.
///
/// All game-logic methods are overridden in TutorialGame so the parent
/// [GameService] repositories are never actually invoked.
class _DummyGameService extends GameService {
  @override
  Set<String> get playerConnections => {};
  @override
  Set<String> get correctConnections => {};
  @override
  Set<String> get wrongConnections => {};
  @override
  int get score => 0;
  @override
  int get errors => 0;
  @override
  bool get phaseComplete => false;
  @override
  bool get submitted => false;
  @override
  bool get isLoading => false;
  @override
  int get remainingSeconds => 0;
  @override
  int get totalPhaseTime => 0;

  @override
  void addConnection(int source, int target) {}
  @override
  void removeConnection(int source, int target) {}
  @override
  bool isConnectionCorrect(int source, int target) => false;
  @override
  bool isConnectionReversed(int source, int target) => false;
  @override
  void submitPhase() {}
}
