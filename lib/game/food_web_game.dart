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
/// * top    – aves / copa das árvores (1/3 superior da tela)
/// * middle – galhos / arbustos / nível médio
/// * bottom – solo, chão, água (1/3 inferior da tela)
const _zoneMap = <int, _VerticalZone>{
  // ══════ Campo ══════
  7: _VerticalZone.top, // Águia — ave ✅ topo
  1: _VerticalZone.bottom, // Capim — planta do solo ✅
  2: _VerticalZone.bottom, // Gafanhoto — solo ✅
  3: _VerticalZone.bottom, // Coelho — solo ✅
  4: _VerticalZone.bottom, // Sapo — solo ✅
  5: _VerticalZone.bottom, // Cobra — solo ✅
  6: _VerticalZone.bottom, // Raposa — solo ✅
  // ══════ Floresta ══════
  13: _VerticalZone.top, // Gavião — ave ✅ topo
  8: _VerticalZone.middle, // Arbusto — nível médio ✅
  10: _VerticalZone.middle, // Aranha — teia/galhos ✅
  9: _VerticalZone.bottom, // Lagarta — solo/plantas baixas ✅
  11: _VerticalZone.bottom, // Sapo — solo ✅
  12: _VerticalZone.bottom, // Cobra — solo ✅
  14: _VerticalZone.bottom, // Veado — solo ✅
  15: _VerticalZone.bottom, // Onça-pintada — solo ✅
  // ══════ Oceano ══════
  16: _VerticalZone.bottom, // Fitoplâncton — profundo ✅
  17: _VerticalZone.bottom, // Alga — profundo ✅
  18: _VerticalZone.bottom, // Camarão — fundo ✅
  19: _VerticalZone.middle, // Sardinha — meio ✅
  20: _VerticalZone.middle, // Polvo — meio ✅
  21: _VerticalZone.middle, // Atum — meio ✅
  22: _VerticalZone.top, // Tubarão — topo ✅
  // ══════ Pantanal ══════
  23: _VerticalZone.bottom, // Planta aquática — água/solo ✅
  24: _VerticalZone.bottom, // Caramujo — solo/água ✅
  25: _VerticalZone.bottom, // Peixe — água ✅
  26: _VerticalZone.bottom, // Garça — ave, mas vive no solo/água 🟢
  27: _VerticalZone.bottom, // Jacaré — água/solo ✅
  28: _VerticalZone.bottom, // Cobra sucuri — água/solo ✅
  29: _VerticalZone.middle, // Onça-pintada — galho/nível médio ✅
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
    AppColors.resetConnectionColorIndex();
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

    // Calcula o tamanho dinâmico do organismo baseado no espaço da tela
    final double maxOrganismSize = 110.0;
    final double minOrganismSize =
        35.0; // Diminuído para caber em telas muito pequenas
    final double dynamicSize = min(
      size.x / 6, // Ajustado para permitir mais animais por linha
      size.y / 6,
    ).clamp(minOrganismSize, maxOrganismSize);

    final positions = _generateQuadrantPositions(organisms, dynamicSize);

    for (int i = 0; i < organisms.length; i++) {
      final component = OrganismComponent(
        organism: organisms[i],
        baseSize: dynamicSize,
      );
      component.position = positions[i];
      component.scale = Vector2.zero();
      organismComponents.add(component);
      add(component);
    }
  }

  static _VerticalZone _zoneFor(int? organismId) =>
      _zoneMap[organismId] ?? _VerticalZone.bottom;

  List<Vector2> _generateQuadrantPositions(
    List<Organism> organisms,
    double organismSize,
  ) {
    if (organisms.isEmpty || size.x <= 0 || size.y <= 0) return [];

    final random = Random();

    final double sideMargin = (size.x * 0.05).clamp(15.0, 60.0);
    final double topMargin = (size.y * 0.15).clamp(60.0, 120.0);
    final double bottomMargin = (size.y * 0.1).clamp(50.0, 100.0);

    final safeWidth = (size.x - 2 * sideMargin).clamp(200.0, double.infinity);
    final safeHeight = (size.y - topMargin - bottomMargin).clamp(200.0, double.infinity);

    final cx = sideMargin + safeWidth / 2;
    final cy = topMargin + safeHeight * 0.30;

    // Definição dos limites dos 4 quadrantes
    // Quadrante 0: topLeft, 1: topRight, 2: bottomLeft, 3: bottomRight
    final quadrantsBounds = [
      Rect.fromLTRB(sideMargin, topMargin, cx, cy),
      Rect.fromLTRB(cx, topMargin, sideMargin + safeWidth, cy),
      Rect.fromLTRB(sideMargin, cy, cx, topMargin + safeHeight),
      Rect.fromLTRB(cx, cy, sideMargin + safeWidth, topMargin + safeHeight),
    ];

    // Para distribuir as cartas, rastreamos quantos organismos estão em cada quadrante
    final organismsPerQuadrant = <int, List<Vector2>>{
      0: [], 1: [], 2: [], 3: []
    };

    int topLeftCount = 0;
    int topRightCount = 0;
    int bottomLeftCount = 0;
    int bottomRightCount = 0;

    final result = List<Vector2>.filled(organisms.length, Vector2.zero());

    for (int i = 0; i < organisms.length; i++) {
      final orgId = organisms[i].id;
      final zone = _zoneFor(orgId);
      
      int assignedQuadrant;

      if (zone == _VerticalZone.top) {
        if (topLeftCount < topRightCount) {
          assignedQuadrant = 0;
        } else if (topRightCount < topLeftCount) {
          assignedQuadrant = 1;
        } else {
          assignedQuadrant = random.nextBool() ? 0 : 1;
        }
        if (assignedQuadrant == 0) topLeftCount++; else topRightCount++;
      } else {
        // _VerticalZone.bottom ou _VerticalZone.middle vão para a parte inferior (70% do espaço)
        if (bottomLeftCount < bottomRightCount) {
          assignedQuadrant = 2;
        } else if (bottomRightCount < bottomLeftCount) {
          assignedQuadrant = 3;
        } else {
          assignedQuadrant = random.nextBool() ? 2 : 3;
        }
        if (assignedQuadrant == 2) bottomLeftCount++; else bottomRightCount++;
      }

      final bounds = quadrantsBounds[assignedQuadrant];
      
      // Gera posição aleatória garantindo que não sobreponha outros no mesmo quadrante
      Vector2 pos = Vector2.zero();
      bool valid = false;
      int attempts = 0;

      while (!valid && attempts < 100) {
        // Padding para não encostar exatamente nas bordas do quadrante
        final rx = bounds.left + organismSize / 2 + random.nextDouble() * (bounds.width - organismSize);
        final ry = bounds.top + organismSize / 2 + random.nextDouble() * (bounds.height - organismSize);
        pos = Vector2(rx, ry);

        valid = true;
        for (final otherPos in organismsPerQuadrant[assignedQuadrant]!) {
          if (pos.distanceTo(otherPos) < organismSize * 1.2) {
            valid = false;
            break;
          }
        }
        attempts++;
      }

      organismsPerQuadrant[assignedQuadrant]!.add(pos);
      result[i] = pos;
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
          line.isCorrect = true;
          line.flashThenColor(AppColors.nextConnectionColor());
          _animatePredatorLunge(source, target);
          _scheduleParticles(particleCenter, true);
          onConnectionResult?.call(
            true,
            _correctMessage(predatorName, preyName),
          );
        } else if (gameService.isConnectionReversed(sourceId, targetId)) {
          gameService.registerError();
          AudioService.instance.playWrong();
          line.animateColor(AppColors.connectionError);
          source.addShakeEffect();
          _scheduleParticles(particleCenter, false);
          onConnectionResult?.call(
            false,
            _wrongMessage(predatorName, preyName, true),
          );
          _scheduleWrongLineRemoval(line, sourceId, targetId);
        } else {
          gameService.registerError();
          AudioService.instance.playWrong();
          line.animateColor(AppColors.connectionError);
          source.addShakeEffect();
          _scheduleParticles(particleCenter, false);
          onConnectionResult?.call(
            false,
            _wrongMessage(predatorName, preyName, false),
          );
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
  void _scheduleWrongLineRemoval(
    ConnectionLine line,
    int sourceId,
    int targetId,
  ) {
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!line.isLoaded) return;
      line.fadeOut();
      connectionLines.remove(line);
      gameService.removeConnection(sourceId, targetId);
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
        line.isCorrect = true;
        line.animateColor(AppColors.nextConnectionColor());
      }
    }
  }
}
