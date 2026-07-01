import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Particle burst effect shown when a connection is made.
///
/// Correct: green + gold + white particles with explosive feel (~24 particles).
/// Wrong:   red + orange + gray particles with dissipating feel (~16 particles).
class ConnectionEffect extends Component {
  final Offset center;
  final bool isCorrect;

  double _timer = 0;
  final List<_Particle> _particles = [];

  static const double _duration = 1.0;

  ConnectionEffect({
    required this.center,
    required this.isCorrect,
  });

  @override
  void onLoad() {
    super.onLoad();
    final rng = Random();
    final count = isCorrect ? 70 : 50;

    for (int i = 0; i < count; i++) {
      final Color color;
      if (isCorrect) {
        final roll = rng.nextDouble();
        if (roll < 0.50) {
          color = const Color(0xFF4CAF50); // green
        } else if (roll < 0.80) {
          color = const Color(0xFFFFD700); // gold
        } else {
          color = const Color(0xFFFFFFFF); // white
        }
      } else {
        final roll = rng.nextDouble();
        if (roll < 0.55) {
          color = const Color(0xFFEF5350); // red
        } else if (roll < 0.85) {
          color = const Color(0xFFFF9800); // orange
        } else {
          color = const Color(0xFFBDBDBD); // gray
        }
      }

      final angle = rng.nextDouble() * 2 * pi;
      final speed = 100 + rng.nextDouble() * 200;
      final radius = isCorrect
          ? (1.5 + rng.nextDouble() * 4.0)
          : (1.5 + rng.nextDouble() * 3.0);
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        radius: radius,
        color: color,
        delay: i * 0.008,
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

      final double distance;
      final double alpha;
      final double radius;

      if (isCorrect) {
        // Explosive burst: fast start, slow end, expanding particles
        distance = p.speed * t * (1.0 - t * 0.25);
        alpha = (1.0 - t) * 0.9;
        radius = p.radius * (1.0 + t * 0.8);
      } else {
        // Dissipation: steady spread, shrink, fade fast
        distance = p.speed * t;
        alpha = (1.0 - t * t) * 0.8;
        radius = p.radius * (1.0 - t * 0.3);
      }

      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance;

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double radius;
  final Color color;
  final double delay;

  _Particle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
    required this.delay,
  });
}
