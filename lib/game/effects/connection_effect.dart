import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class ConnectionEffect extends Component {
  final Offset center;
  final Color color;
  final bool isCorrect;

  double _timer = 0;
  final List<_Particle> _particles = [];

  static const double _duration = 1.0;

  ConnectionEffect({
    required this.center,
    required this.color,
    this.isCorrect = true,
  });

  @override
  void onLoad() {
    super.onLoad();
    final rng = Random();
    final count = isCorrect ? 14 : 10;
    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 60 + rng.nextDouble() * 100;
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        radius: 2.0 + rng.nextDouble() * 3.5,
        delay: i * 0.015,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer > _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      final t = (_timer - p.delay).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final distance = p.speed * t;
      final alpha = (1.0 - t) * (isCorrect ? 0.9 : 0.7);
      final radius = p.radius * (isCorrect ? (1.0 + t * 0.6) : (1.0 - t * 0.2));

      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance;

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double radius;
  final double delay;

  _Particle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.delay,
  });
}
