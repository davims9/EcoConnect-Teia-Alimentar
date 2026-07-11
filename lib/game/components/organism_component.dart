import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import '../../core/app_colors.dart';
import '../../core/asset_paths.dart';
import '../../models/organism.dart';
import '../food_web_game.dart';

class OrganismComponent extends SpriteAnimationComponent
    with DragCallbacks, HasGameRef {
  final Organism organism;
  final double baseSize;
  double _bobPhase = 0;
  double _baseY = 0;
  double _targetGlow = 0;
  double _currentGlow = 0;
  bool _idleAnimationsEnabled = true;
  bool _isHighlighted = false;
  double _pulsePhase = 0;

  OrganismComponent({required this.organism, this.baseSize = 110.0}) {
    size = Vector2(baseSize, baseSize);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final path = OrganismAssetPath.getPath(organism);
    final image = await Flame.images.load(path);

    final frameWidth = (image.width / 6).floorToDouble();
    final frameHeight = image.height.toDouble();
    final textureSize = Vector2(frameWidth, frameHeight);

    final sprites = [
      for (int i = 0; i < 6; i++)
        Sprite(
          image,
          srcPosition: Vector2(i * frameWidth, 0),
          srcSize: textureSize,
        ),
    ];

    final pingPongSprites = [
      ...sprites,
      for (int i = 4; i > 0; i--) sprites[i],
    ];

    animation = SpriteAnimation.spriteList(
      pingPongSprites,
      stepTime: 0.1,
      loop: true,
    );

    _baseY = position.y;
    _bobPhase = Random().nextDouble() * 2 * pi;

    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.5, curve: Curves.elasticOut),
      ),
    );
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

    // Smooth scale transition for highlight
    final targetScale = _isHighlighted ? 1.08 : 1.0;
    final currentScale = scale.x;
    final newScale = currentScale + (targetScale - currentScale) * dt * 8;
    if ((newScale - targetScale).abs() > 0.001) {
      scale = Vector2.all(newScale);
    } else if (scale.x != targetScale) {
      scale = Vector2.all(targetScale);
    }

    _pulsePhase += dt * 2.5;
  }

  void setHighlight(bool highlighted) {
    _isHighlighted = highlighted;
    _targetGlow = highlighted ? 1.0 : 0.0;
    if (!highlighted) {
      _pulsePhase = 0;
    }
  }

  /// Shakes the organism left and right to indicate a wrong connection.
  void addShakeEffect() {
    disableIdleAnimations();
    final original = position.clone();
    const amplitude = 6.0;

    void shakeStep(int remaining, double amp) {
      if (remaining <= 0) {
        add(
          MoveToEffect(
              original,
              EffectController(duration: 0.05, curve: Curves.easeInOut),
            )
            ..onComplete = () {
              enableIdleAnimations();
              _baseY = position.y;
            },
        );
        return;
      }

      // Move left
      add(
        MoveToEffect(
            Vector2(original.x - amp, original.y),
            EffectController(duration: 0.04, curve: Curves.easeInOut),
          )
          ..onComplete = () {
            // Move right
            add(
              MoveToEffect(
                  Vector2(original.x + amp, original.y),
                  EffectController(duration: 0.04, curve: Curves.easeInOut),
                )
                ..onComplete = () {
                  shakeStep(remaining - 1, amp * 0.65);
                },
            );
          },
      );
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
    setHighlight(true);
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
    setHighlight(false);
    final game = findGame() as FoodWebGame?;
    game?.onDragEnd();
  }

  @override
  void render(Canvas canvas) {
    if (_currentGlow > 0.01) {
      final center = Offset(size.x / 2, size.y / 2);
      final radius = size.x / 2;
      final intensity = _currentGlow;
      final pulse = sin(_pulsePhase);

      // ── Multi-layer soft glow ──
      // Layer 1: Outer wide glow (very subtle)
      final outerGlow = Paint()
        ..color = Colors.white.withValues(alpha: intensity * (0.12 + 0.04 * pulse))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(center, radius + 14, outerGlow);

      // Layer 2: Mid glow
      final midGlow = Paint()
        ..color = Colors.white.withValues(alpha: intensity * (0.18 + 0.06 * pulse))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(center, radius + 8, midGlow);

      // Layer 3: Inner glow with soft green tint
      final innerGlow = Paint()
        ..color = const Color(0xFFA4F69E).withValues(alpha: intensity * (0.12 + 0.06 * pulse))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius + 3, innerGlow);

      // ── Luminous border ──
      // Glowing border halo
      final glowBorder = Paint()
        ..color = Colors.white.withValues(alpha: intensity * (0.45 + 0.15 * pulse))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, radius + 1, glowBorder);

      // Thin bright core border
      final coreBorder = Paint()
        ..color = Colors.white.withValues(alpha: intensity * (0.65 + 0.2 * pulse))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, radius + 1, coreBorder);
    }

    super.render(canvas);

    // ── Name label ──
    final name = organism.name;
    final isHighlighted = _currentGlow > 0.01;

    final namePainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: isHighlighted ? 4 : 3,
              offset: const Offset(1, 1),
            ),
            if (isHighlighted)
              Shadow(
                color: Colors.white.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: Offset.zero,
              ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout(maxWidth: size.x + (isHighlighted ? 30 : 20));

    if (isHighlighted) {
      // Subtle background pill for highlighted name
      final textWidth = namePainter.width + 12;
      final textHeight = namePainter.height + 6;
      final textX = (size.x - textWidth) / 2;
      final textY = size.y + 3;

      final bgPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(textX, textY, textWidth, textHeight),
          const Radius.circular(8),
        ),
        bgPaint,
      );

      // Name border glow
      final nameBorderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(textX, textY, textWidth, textHeight),
          const Radius.circular(8),
        ),
        nameBorderPaint,
      );

      namePainter.paint(
        canvas,
        Offset((size.x - namePainter.width) / 2, textY + 3),
      );
    } else {
      namePainter.paint(
        canvas,
        Offset((size.x - namePainter.width) / 2, size.y + 5),
      );
    }
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
