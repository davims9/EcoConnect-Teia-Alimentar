import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import '../core/app_colors.dart';
import '../core/asset_paths.dart';
import '../services/audio_service.dart';
import '../models/organism.dart';
import '../services/game_service.dart';
import 'components/organism_component.dart';
import 'components/connection_line.dart';
import 'components/drag_indicator.dart';
import 'components/background_component.dart';
import 'effects/connection_effect.dart';
import 'systems/connection_system.dart';

/// Vertical zones for organic positioning based on real-world habitat.
enum _VerticalZone { top, middle, bottom }

/// Assigns each organism (by id) to a vertical zone.
///
/// * top – birds / canopy dwellers
/// * middle – branches / shrubs / mid-level
/// * bottom – ground, grass, water, floor
const _zoneMap = <int, _VerticalZone>{
  // ── Campo ──
  7: _VerticalZone.top,     // Aguia
  1: _VerticalZone.bottom,  // Capim
  2: _VerticalZone.bottom,  // Gafanhoto
  3: _VerticalZone.bottom,  // Coelho
  4: _VerticalZone.bottom,  // Sapo
  5: _VerticalZone.bottom,  // Cobra
  6: _VerticalZone.bottom,  // Raposa
  // ── Floresta ──
  13: _VerticalZone.top,    // Gaviao
  8: _VerticalZone.middle,  // Arbusto
  10: _VerticalZone.middle, // Aranha
  9: _VerticalZone.bottom,  // Lagarta
  11: _VerticalZone.bottom, // Sapo
  12: _VerticalZone.bottom, // Cobra
  14: _VerticalZone.bottom, // Veado
  15: _VerticalZone.bottom, // Onça-pintada
  // ── Pantanal ──
  29: _VerticalZone.middle, // OnçaPintadaGalho
  24: _VerticalZone.middle, // Caramujo
  23: _VerticalZone.bottom, // PlantaAquatica
  25: _VerticalZone.bottom, // Peixe
  26: _VerticalZone.bottom, // Garça (stay on water / floor)
  27: _VerticalZone.bottom, // Jacare
  28: _VerticalZone.bottom, // CobraSucuri
};

class FoodWebGame extends FlameGame {
  final GameService gameService;
  final ConnectionSystem connectionSystem = ConnectionSystem();

  List<OrganismComponent> organismComponents = [];
  List<ConnectionLine> connectionLines = [];
  DragIndicator? dragIndicator;
  BackgroundComponent? _background;
  OrganismComponent? _lastHoveredTarget;

  /// Called when a connection is validated, with (isCorrect, message).
  void Function(bool correct, String message)? onConnectionResult;

  FoodWebGame({required this.gameService});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _background?.size = size;
  }

  void loadPhase() {
    organismComponents.clear();
    connectionLines.clear();
    dragIndicator = null;
    _background = null;
    _lastHoveredTarget = null;
    removeAll(children.whereType<OrganismComponent>().toList());
    removeAll(children.whereType<ConnectionLine>().toList());
    removeAll(children.whereType<DragIndicator>().toList());
    final phaseId = gameService.currentPhase?.id ?? 1;
    final bgPath = OrganismAssetPath.getBackgroundPath(phaseId);
    _background = BackgroundComponent(spritePath: bgPath, size: size);
    add(_background!);

    final organisms = gameService.organisms;
    final positions = _generateZonedPositions(organisms);

    for (int i = 0; i < organisms.length; i++) {
      final component = OrganismComponent(organism: organisms[i]);
      component.position = positions[i];
      component.scale = Vector2.zero();
      organismComponents.add(component);
      add(component);
    }
  }

  static _VerticalZone _zoneFor(int? organismId) =>
      _zoneMap[organismId] ?? _VerticalZone.bottom;

  List<Vector2> _generateZonedPositions(List<Organism> organisms) {
    if (organisms.isEmpty || size.x <= 0 || size.y <= 0) return [];

    final random = Random();

    // Safe-area margins (pixels) to avoid AppBar (64px), bottom HUD (~60px),
    // sprite half-size (55px), and name label (~20px).
    const topMargin = 120.0;
    const bottomMargin = 100.0;
    const sideMargin = 60.0;

    final safeWidth = (size.x - 2 * sideMargin).clamp(200.0, double.infinity);
    final safeHeight = (size.y - topMargin - bottomMargin).clamp(200.0, double.infinity);

    // Normalised Y ranges (0-1) inside the safe area for each zone
    final zoneRanges = <_VerticalZone, Vector2>{
      _VerticalZone.top: Vector2(0.00, 0.25),
      _VerticalZone.middle: Vector2(0.30, 0.60),
      _VerticalZone.bottom: Vector2(0.65, 0.95),
    };

    const minDist = 125.0;
    const maxAttempts = 2000;

    // Group indices by zone
    final grouped = <_VerticalZone, List<int>>{
      for (final z in _VerticalZone.values) z: <int>[],
    };
    for (int i = 0; i < organisms.length; i++) {
      grouped[_zoneFor(organisms[i].id)]!.add(i);
    }

    final result = List<Vector2>.filled(organisms.length, Vector2.zero());
    final placed = <Vector2>[];

    for (final zone in _VerticalZone.values) {
      final indices = grouped[zone]!;
      if (indices.isEmpty) continue;

      final yMin = topMargin + zoneRanges[zone]!.x * safeHeight;
      final yMax = topMargin + zoneRanges[zone]!.y * safeHeight;
      final rangeY = yMax - yMin;

      for (final idx in indices) {
        bool ok = false;
        for (int attempt = 0; attempt < maxAttempts && !ok; attempt++) {
          final pos = Vector2(
            sideMargin + random.nextDouble() * safeWidth,
            yMin + random.nextDouble() * rangeY,
          );
          bool tooClose = false;
          for (final p in placed) {
            if ((pos - p).length < minDist) {
              tooClose = true;
              break;
            }
          }
          if (!tooClose) {
            placed.add(pos);
            result[idx] = pos;
            ok = true;
          }
        }
        if (!ok) {
          result[idx] = Vector2(
            sideMargin + random.nextDouble() * safeWidth,
            yMin,
          );
          placed.add(result[idx]);
        }
      }
    }

    return result;
  }

  Offset getOrganismCenter(OrganismComponent comp) {
    return comp.position.toOffset();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (dragIndicator != null) {
      dragIndicator!.render(canvas);
    }
  }

  void onDragStartOrganism(OrganismComponent component) {
    connectionSystem.startDrag(component);
  }

  void onDragUpdate(Offset position) {
    if (!connectionSystem.isDragging) return;
    connectionSystem.updateDrag(position);
    final source = connectionSystem.dragSource;
    if (source != null) {
      dragIndicator = DragIndicator(
        start: getOrganismCenter(source),
        end: position,
      );
    }

    final hovered = _organismAtPoint(position);
    if (hovered != _lastHoveredTarget) {
      _lastHoveredTarget?.setHighlight(false);
      _lastHoveredTarget = hovered;
      _lastHoveredTarget?.setHighlight(true);
    }
  }

  /// Returns a child-friendly message for a correct connection.
  String _correctMessage(String predator, String prey) {
    final messages = [
      '✅ Muito bem!\n\n$predator se alimenta de $prey!',
      '🎉 Correto!\n\n$predator → $prey',
      '🌟 Parabéns!\n\n$predator come $prey!',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  /// Returns a child-friendly message for an incorrect connection.
  String _wrongMessage(String predator, String prey, bool isReversed) {
    if (isReversed) {
      const messages = [
        '🌿 Quase!\n\nArraste do predador para a presa.',
        '🔄 Atenção!\n\nQuem come vai para quem é comido.',
        '🤔 Ops!\n\nPense na direção da cadeia alimentar.',
      ];
      return messages[Random().nextInt(messages.length)];
    }
    final messages = [
      '❌ Quase!\n\n$predator não come $prey. Tente outro!',
      '🤔 Não é esse!\n\nQuem será que $predator realmente come?',
      '🔍 Observe!\n\n$predator precisa de outra presa.',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  void onDragEnd() {
    _lastHoveredTarget?.setHighlight(false);
    _lastHoveredTarget = null;
    final source = connectionSystem.dragSource;
    final target = connectionSystem.endDrag(organismComponents);
    dragIndicator = null;
    if (target != null && source != null) {
      final sourceId = target.organism.id!; // prey id
      final targetId = source.organism.id!; // predator id
      final key = '$sourceId-$targetId';

      if (!gameService.playerConnections.contains(key)) {
        gameService.addConnection(sourceId, targetId);
        final line = ConnectionLine(
          sourceId: sourceId,
          targetId: targetId,
          start: getOrganismCenter(source),
          end: getOrganismCenter(target),
        );
        connectionLines.add(line);
        add(line);

        // --- Immediate validation ---
        final predatorName = source.organism.name;
        final preyName = target.organism.name;
        final particleCenter = Offset(size.x / 2, size.y * 0.3);

        if (gameService.isConnectionCorrect(sourceId, targetId)) {
          AudioService.instance.playCorrect();
          line.flashThenColor(AppColors.connectionLine);
          _animatePredatorLunge(source, target);
          _scheduleParticles(particleCenter, true);
          onConnectionResult?.call(true, _correctMessage(predatorName, preyName));
        } else if (gameService.isConnectionReversed(sourceId, targetId)) {
          AudioService.instance.playWrong();
          line.animateColor(AppColors.connectionError);
          source.addShakeEffect();
          _scheduleParticles(particleCenter, false);
          onConnectionResult?.call(false, _wrongMessage(predatorName, preyName, true));
          _scheduleWrongLineRemoval(line, sourceId, targetId);
        } else {
          AudioService.instance.playWrong();
          line.animateColor(AppColors.connectionError);
          source.addShakeEffect();
          _scheduleParticles(particleCenter, false);
          onConnectionResult?.call(false, _wrongMessage(predatorName, preyName, false));
          _scheduleWrongLineRemoval(line, sourceId, targetId);
        }
      }
    }
  }

  /// Particles fire ~2.8 s later, just before the card starts fading (3 s).
  void _scheduleParticles(Offset center, bool isCorrect) {
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!isLoaded) return;
      add(ConnectionEffect(center: center, isCorrect: isCorrect));
    });
  }

  /// Wrong line starts fading at ~2.8 s so it disappears together with the card.
  void _scheduleWrongLineRemoval(ConnectionLine line, int sourceId, int targetId) {
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!line.isLoaded) return;
      line.fadeOut();
      connectionLines.remove(line);
      gameService.removeConnection(sourceId, targetId);
    });
  }

  void _animatePredatorLunge(OrganismComponent predator, OrganismComponent prey) {
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
      )..onComplete = () {
          predator.add(
            MoveToEffect(
              original,
              EffectController(duration: 1.0, curve: Curves.easeInOut),
            )..onComplete = () {
                predator.enableIdleAnimations();
              },
          );
        },
    );
  }

  OrganismComponent? _organismAtPoint(Offset point) {
    final pos = Vector2(point.dx, point.dy);
    for (final comp in organismComponents) {
      if (comp.containsPoint(pos)) return comp;
    }
    return null;
  }

  void submitPhase() {
    gameService.submitPhase();
    _animateConnectionColors();
  }

  void _animateConnectionColors() {
    final wrong = gameService.wrongConnections;
    final correct = gameService.correctConnections;
    for (final line in connectionLines) {
      final key = '${line.sourceId}-${line.targetId}';
      if (wrong.contains(key)) {
        line.animateColor(AppColors.connectionError);
      } else if (correct.contains(key)) {
        line.animateColor(AppColors.primary);
      }
    }
  }
}


