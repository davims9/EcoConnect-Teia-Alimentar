import 'dart:ui';
import 'package:flame/components.dart';

class BackgroundComponent extends SpriteComponent {
  final String spritePath;

  BackgroundComponent({required this.spritePath, Vector2? size})
    : super(size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load(spritePath);
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) return;
    final imgW = sprite!.srcSize.x;
    final imgH = sprite!.srcSize.y;
    final scaleX = size.x / imgW;
    final scaleY = size.y / imgH;
    final scale = scaleX > scaleY ? scaleX : scaleY;
    final scaledW = imgW * scale;
    final scaledH = imgH * scale;
    final offsetX = (size.x - scaledW) / 2;
    final offsetY = (size.y - scaledH) / 2;
    for (double x = offsetX; x < size.x; x += scaledW) {
      for (double y = offsetY; y < size.y; y += scaledH) {
        sprite!.render(
          canvas,
          position: Vector2(x, y),
          size: Vector2(scaledW, scaledH),
        );
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF191C1B).withValues(alpha: 0.35),
    );
  }
}
