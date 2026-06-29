import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import '../core/app_colors.dart';
import '../core/asset_paths.dart';
import '../services/game_service.dart';
import 'components/organism_component.dart';
import 'components/connection_line.dart';
import 'components/drag_indicator.dart';
import 'components/background_component.dart';
import 'systems/connection_system.dart';

class FoodWebGame extends FlameGame {
  final GameService gameService;
  final ConnectionSystem connectionSystem = ConnectionSystem();

  List<OrganismComponent> organismComponents = [];
  List<ConnectionLine> connectionLines = [];
  DragIndicator? dragIndicator;
  BackgroundComponent? _background;
  OrganismComponent? _lastHoveredTarget;

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
    final positions = _generateRandomPositions(organisms.length);

    for (int i = 0; i < organisms.length; i++) {
      final component = OrganismComponent(organism: organisms[i]);
      component.position = positions[i];
      component.scale = Vector2.zero();
      organismComponents.add(component);
      add(component);
    }
  }

  List<Vector2> _generateRandomPositions(int count) {
    if (count <= 0) return [];
    final random = Random();

    final padding = 65.0;
    final xMin = padding;
    final xMax = size.x - padding;
    final yMin = size.y * 0.12 + 10;
    final yMax = size.y * 0.88 - 10;
    final rangeX = xMax - xMin;
    final rangeY = yMax - yMin;

    if (rangeX <= 0 || rangeY <= 0) {
      return List.generate(count, (_) => Vector2(size.x / 2, size.y / 2));
    }

    const minDist = 125.0;
    const maxAttempts = 2000;
    final positions = <Vector2>[];

    for (int attempt = 0; attempt < maxAttempts && positions.length < count; attempt++) {
      final pos = Vector2(
        xMin + random.nextDouble() * rangeX,
        yMin + random.nextDouble() * rangeY,
      );
      bool tooClose = false;
      for (final existing in positions) {
        if ((pos - existing).length < minDist) {
          tooClose = true;
          break;
        }
      }
      if (!tooClose) {
        positions.add(pos);
      }
    }

    while (positions.length < count) {
      positions.add(Vector2(
        xMin + random.nextDouble() * rangeX,
        yMin + random.nextDouble() * rangeY,
      ));
    }

    return positions;
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

  void onDragEnd() {
    _lastHoveredTarget?.setHighlight(false);
    _lastHoveredTarget = null;
    final source = connectionSystem.dragSource;
    final target = connectionSystem.endDrag(organismComponents);
    dragIndicator = null;
    if (target != null && source != null) {
      final sourceId = target.organism.id!;
      final targetId = source.organism.id!;
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

        if (gameService.correctConnections.contains(key)) {
          _animatePredatorLunge(source, target);
        }
      }
    }
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
