import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import '../../core/app_colors.dart';
import '../../core/asset_paths.dart';
import '../../models/organism.dart';
import '../food_web_game.dart';

class OrganismComponent extends PositionComponent with DragCallbacks, HasGameRef {
  final Organism organism;
  Sprite? sprite;
  double _bobPhase = 0;
  double _baseY = 0;
  double _targetGlow = 0;
  double _currentGlow = 0;
  bool _idleAnimationsEnabled = true;

  OrganismComponent({required this.organism}) {
    size = Vector2(110, 110);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final path = OrganismAssetPath.getPath(organism);
    sprite = await Sprite.load(path);

    _baseY = position.y;
    _bobPhase = Random().nextDouble() * 2 * pi;

    scale = Vector2.zero();
    add(ScaleEffect.to(
      Vector2.all(1),
      EffectController(
        duration: 0.5,
        curve: Curves.elasticOut,
      ),
    ));
  }

  void disableIdleAnimations() {
    _idleAnimationsEnabled = false;
  }

  void enableIdleAnimations() {
    _idleAnimationsEnabled = true;
    _bobPhase = Random().nextDouble() * 2 * pi;
    _baseY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_idleAnimationsEnabled) {
      _bobPhase += dt * 0.8;
      position.y = _baseY + sin(_bobPhase) * 4;
    }
    _currentGlow += (_targetGlow - _currentGlow) * dt * 6;
  }

  void setHighlight(bool highlighted) {
    _targetGlow = highlighted ? 1.0 : 0.0;
  }

  /// Shakes the organism left and right to indicate a wrong connection.
  void addShakeEffect() {
    disableIdleAnimations();
    final original = position.clone();
    const amplitude = 6.0;

    void shakeStep(int remaining, double amp) {
      if (remaining <= 0) {
        add(MoveToEffect(
          original,
          EffectController(duration: 0.05, curve: Curves.easeInOut),
        )..onComplete = () {
            enableIdleAnimations();
            _baseY = position.y;
          });
        return;
      }

      // Move left
      add(MoveToEffect(
        Vector2(original.x - amp, original.y),
        EffectController(duration: 0.04, curve: Curves.easeInOut),
      )..onComplete = () {
          // Move right
          add(MoveToEffect(
            Vector2(original.x + amp, original.y),
            EffectController(duration: 0.04, curve: Curves.easeInOut),
          )..onComplete = () {
              shakeStep(remaining - 1, amp * 0.65);
            });
        });
    }

    shakeStep(3, amplitude);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final center = size / 2;
    return (point - center).length <= size.x / 2;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    scale = Vector2(0.95, 0.95);
    final game = findGame() as FoodWebGame?;
    game?.onDragStartOrganism(this);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    final game = findGame() as FoodWebGame?;
    if (game != null) {
      game.onDragUpdate(event.canvasEndPosition.toOffset());
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    add(ScaleEffect.to(
      Vector2.all(1),
      EffectController(duration: 0.3, curve: Curves.elasticOut),
    ));
    final game = findGame() as FoodWebGame?;
    game?.onDragEnd();
  }

  @override
  void render(Canvas canvas) {
    if (_currentGlow > 0.01) {
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: _currentGlow * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 6, glowPaint);
    }

    if (sprite != null) {
      sprite!.render(canvas, size: size);
    }

    final namePainter = TextPainter(
      text: TextSpan(
        text: organism.name,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 3,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout(maxWidth: size.x + 20);
    namePainter.paint(
      canvas,
      Offset(
        (size.x - namePainter.width) / 2,
        size.y + 5,
      ),
    );

    // Small trophic level indicator dot
    final indicatorColor = _colorForTrophicLevel(organism.trophicLevel);
    final dotPaint = Paint()
      ..color = indicatorColor.withValues(alpha: 0.85);
    final nameBottom = size.y + 5 + namePainter.height;
    canvas.drawCircle(
      Offset(size.x / 2, nameBottom + 5),
      3.5,
      dotPaint,
    );
  }

  Color _colorForTrophicLevel(String level) {
    switch (level) {
      case 'produtor':
        return AppColors.correct;
      case 'consumidor_primario':
        return const Color(0xFFFFC107);
      case 'consumidor_secundario':
        return const Color(0xFFFF9800);
      case 'consumidor_terciario':
        return const Color(0xFFF57C00);
      case 'predador_topo':
        return AppColors.connectionError;
      default:
        return Colors.white70;
    }
  }
}
