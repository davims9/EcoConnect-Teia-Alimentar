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
  7: _VerticalZone.top,    // Águia — ave ✅ topo
  1: _VerticalZone.bottom, // Capim — planta do solo ✅
  2: _VerticalZone.bottom, // Gafanhoto — solo ✅
  3: _VerticalZone.bottom, // Coelho — solo ✅
  4: _VerticalZone.bottom, // Sapo — solo ✅
  5: _VerticalZone.bottom, // Cobra — solo ✅
  6: _VerticalZone.bottom, // Raposa — solo ✅
  // ══════ Floresta ══════
  13: _VerticalZone.top,   // Gavião — ave ✅ topo
  8: _VerticalZone.middle, // Arbusto — nível médio ✅
  10: _VerticalZone.middle,// Aranha — teia/galhos ✅
  9: _VerticalZone.bottom, // Lagarta — solo/plantas baixas ✅
  11: _VerticalZone.bottom,// Sapo — solo ✅
  12: _VerticalZone.bottom,// Cobra — solo ✅
  14: _VerticalZone.bottom,// Veado — solo ✅
  15: _VerticalZone.bottom,// Onça-pintada — solo ✅
  // ══════ Oceano ══════
  16: _VerticalZone.bottom,// Fitoplâncton — profundo ✅
  17: _VerticalZone.bottom,// Alga — profundo ✅
  18: _VerticalZone.bottom,// Camarão — fundo ✅
  19: _VerticalZone.middle, // Sardinha — meio ✅
  20: _VerticalZone.middle, // Polvo — meio ✅
  21: _VerticalZone.middle, // Atum — meio ✅
  22: _VerticalZone.top,   // Tubarão — topo ✅
  // ══════ Pantanal ══════
  23: _VerticalZone.bottom,// Planta aquática — água/solo ✅
  24: _VerticalZone.bottom,// Caramujo — solo/água ✅
  25: _VerticalZone.bottom,// Peixe — água ✅
  26: _VerticalZone.bottom,// Garça — ave, mas vive no solo/água 🟢
  27: _VerticalZone.bottom,// Jacaré — água/solo ✅
  28: _VerticalZone.bottom,// Cobra sucuri — água/solo ✅
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

    const topMargin = 120.0;
    const bottomMargin = 100.0;
    const sideMargin = 60.0;

    final safeWidth = (size.x - 2 * sideMargin).clamp(200.0, double.infinity);
    final safeHeight = (size.y - topMargin - bottomMargin).clamp(200.0, double.infinity);

    final zoneRanges = <_VerticalZone, Vector2>{
      _VerticalZone.top: Vector2(0.00, 0.30),
      _VerticalZone.middle: Vector2(0.33, 0.63),
      _VerticalZone.bottom: Vector2(0.66, 1.00),
    };

    const organismSize = 110.0;
    const edgeGap = 15.0;
    final idealDist = organismSize + edgeGap; // 125.0

    final grouped = <_VerticalZone, List<int>>{
      for (final z in _VerticalZone.values) z: <int>[],
    };
    for (int i = 0; i < organisms.length; i++) {
      grouped[_zoneFor(organisms[i].id)]!.add(i);
    }

    final result = List<Vector2>.filled(organisms.length, Vector2.zero());

    for (final zone in _VerticalZone.values) {
      final indices = grouped[zone]!;
      if (indices.isEmpty) continue;

      final yMin = topMargin + zoneRanges[zone]!.x * safeHeight;
      final yMax = topMargin + zoneRanges[zone]!.y * safeHeight;
      final zoneHeight = yMax - yMin;

      final count = indices.length;

      // --- Calculate grid dimensions ---
      // Maximum columns that fit horizontally with ideal spacing
      final maxCols = ((safeWidth - organismSize) / idealDist).floor() + 1;

      int cols;
      int rows;
      double spacingX;
      double spacingY;

      if (count <= 1) {
        cols = 1;
        rows = 1;
        spacingX = 0;
        spacingY = 0;
      } else if (count <= maxCols) {
        // Single row with ideal spacing
        cols = count;
        rows = 1;
        spacingX = (safeWidth - organismSize) / (count - 1);
        spacingY = 0;
      } else {
        // Check how many rows the zone can actually accommodate
        // Minimum vertical center-to-center for 2 rows: organismSize (touching)
        final maxRowsThatFit = (zoneHeight / organismSize).floor();
        final idealRows = (count + maxCols - 1) ~/ maxCols;

        if (idealRows <= maxRowsThatFit) {
          // Zone is tall enough for the ideal number of rows
          cols = maxCols;
          rows = idealRows;
          spacingX = (safeWidth - organismSize) / (maxCols - 1);
          final neededVertical = organismSize + idealDist * (rows - 1);
          spacingY = neededVertical <= zoneHeight ? idealDist : (zoneHeight - organismSize) / (rows - 1);
        } else if (maxRowsThatFit >= 2) {
          // Zone can fit some rows, but not the ideal amount
          rows = maxRowsThatFit;
          cols = (count + rows - 1) ~/ rows;
          spacingX = (safeWidth - organismSize) / (cols - 1);
          spacingY = (zoneHeight - organismSize) / (rows - 1);
        } else {
          // Zone too shallow for 2 rows → single row with tighter spacing
          rows = 1;
          cols = count;
          // Reduce horizontal spacing so all fit in one row (never below organismSize)
          spacingX = (safeWidth - organismSize) / (count - 1);
          spacingY = 0;
        }
      }

      // Final safety: spacing never below organismSize (guarantees no visual overlap)
      if (spacingX < organismSize && cols > 1) {
        spacingX = organismSize;
      }
      if (spacingY < organismSize && rows > 1) {
        if ((rows - 1) * organismSize + organismSize <= zoneHeight) {
          // Keep as-is, organisms at least edge-to-edge
        } else {
          // Even minimum vertical spacing doesn't fit → force single row
          rows = 1;
          cols = count;
          spacingX = (safeWidth - organismSize) / (count - 1);
          spacingY = 0;
          if (spacingX < organismSize && cols > 1) spacingX = organismSize;
        }
      }

      // --- Distribute row items equally (last row may have fewer items) ---
      final itemsPerRow = <int>[];
      for (int r = 0; r < rows; r++) {
        final items = (r < rows - 1)
            ? cols
            : count - r * cols;
        itemsPerRow.add(items);
      }

      // Build a shuffled list of (row, col) for random-but-spread placement
      final assignments = <(int row, int col)>[];
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < itemsPerRow[r]; c++) {
          assignments.add((r, c));
        }
      }
      assignments.shuffle(random);

      // --- Place organisms ---
      for (int s = 0; s < count; s++) {
        final idx = indices[s];
        final (int row, int col) = assignments[s];

        final itemsInThisRow = itemsPerRow[row];
        final double thisRowSpacingX;
        if (itemsInThisRow <= 1) {
          thisRowSpacingX = 0;
        } else {
          thisRowSpacingX = (safeWidth - organismSize) / (itemsInThisRow - 1);
        }

        // Center X of this item in its row
        double posX = sideMargin + organismSize / 2 + col * thisRowSpacingX;

        // Center Y
        double posY;
        if (rows <= 1) {
          posY = yMin + zoneHeight / 2;
        } else {
          posY = yMin + organismSize / 2 + row * spacingY;
        }

        // Apply tiny jitter for visual variety (never enough to cause overlap)
        if (thisRowSpacingX > organismSize + 5) {
          final jitterX = (thisRowSpacingX - organismSize) * 0.3;
          posX += (random.nextDouble() - 0.5) * jitterX;
        }
        if (spacingY > organismSize + 5) {
          final jitterY = (spacingY - organismSize) * 0.3;
          posY += (random.nextDouble() - 0.5) * jitterY;
        }

        // Clamp inside safe-area zone
        posX = posX.clamp(
          sideMargin + organismSize / 2,
          sideMargin + safeWidth - organismSize / 2,
        );
        posY = posY.clamp(
          yMin + organismSize / 2,
          yMax - organismSize / 2,
        );

        result[idx] = Vector2(posX, posY);
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
          // CORRECT
          line.flashThenColor(AppColors.connectionLine);
          _animatePredatorLunge(source, target);
          _scheduleParticles(particleCenter, true);
          onConnectionResult?.call(true, _correctMessage(predatorName, preyName));
        } else if (gameService.isConnectionReversed(sourceId, targetId)) {
          // WRONG DIRECTION
          line.animateColor(AppColors.connectionError);
          source.addShakeEffect();
          _scheduleParticles(particleCenter, false);
          onConnectionResult?.call(false, _wrongMessage(predatorName, preyName, true));
          _scheduleWrongLineRemoval(line, sourceId, targetId);
        } else {
          // WRONG COMBINATION
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


