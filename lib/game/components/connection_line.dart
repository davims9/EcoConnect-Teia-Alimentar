import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

class ConnectionLine extends Component {
  final int sourceId;
  final int targetId;
  final Offset start;
  final Offset end;
  Color color;
  double _progress = 0;
  double _targetProgress = 1;
  Color _targetColor;
  double _colorProgress = 1;
  bool _isFading = false;
  bool isCorrect = false;
  double _time = 0;

  ConnectionLine({
    required this.sourceId,
    required this.targetId,
    required this.start,
    required this.end,
    this.color = AppColors.connectionLine,
  }) : _targetColor = color;

  void animateColor(Color newColor) {
    if (_isFading) return;
    _targetColor = newColor;
    _colorProgress = 0;
  }

  /// Flashes white briefly then transitions to [finalColor].
  void flashThenColor(Color finalColor) {
    if (_isFading) return;
    color = const Color(0xFFFFFFFF);
    _targetColor = finalColor;
    _colorProgress = 0;
  }

  /// Gradually fades the line to transparent, then removes it.
  void fadeOut() {
    _isFading = true;
    _targetColor = const Color(0x00000000);
    _colorProgress = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_progress < _targetProgress) {
      _progress += dt * 4;
      if (_progress > _targetProgress) _progress = _targetProgress;
    }
    if (_colorProgress < 1) {
      _colorProgress += dt * (_isFading ? 4 : 3);
      if (_colorProgress > 1) _colorProgress = 1;
      color = Color.lerp(
        color,
        _targetColor,
        _colorProgress.clamp(0, 1) as double,
      )!;
    }
    if (_isFading && _colorProgress >= 1) {
      removeFromParent();
    }
  }

  Path _getCurvePath() {
    final direction = end - start;
    final length = direction.distance;
    if (length == 0) {
      return Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);
    }
    final unit = direction / length;
    final perpendicular = Offset(-unit.dy, unit.dx);
    
    // Curva suave, alterna lado dependendo dos ids
    final sign = ((sourceId + targetId) % 2 == 0) ? 1.0 : -1.0;
    final curveOffset = length * 0.15 * sign; 
    
    final controlPoint = start + direction * 0.5 + perpendicular * curveOffset;
    
    return Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
  }

  void _drawLeaf(Canvas canvas, Offset pos, Offset direction, Paint basePaint) {
    final angle = atan2(direction.dy, direction.dx);
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    
    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(6, -6, 12, 0)
      ..quadraticBezierTo(6, 6, 0, 0)
      ..close();
      
    final leafPaint = Paint()
      ..color = basePaint.color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(leafPath, leafPaint);
    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    final baseStroke = AppConstants.lineStrokeWidth;
    final stroke = isCorrect ? baseStroke * 1.5 : baseStroke;

    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = _getCurvePath();
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    
    final metric = metrics.first;
    final drawLength = metric.length * _progress;
    final drawPath = metric.extractPath(0, drawLength);

    if (isCorrect && _progress > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4 + 0.2 * sin(_time * 4))
        ..strokeWidth = stroke * 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawPath(drawPath, glowPaint);
    }

    canvas.drawPath(drawPath, paint);

    if (_progress >= 1) {
      // Seta no último terço da linha (~68%), não mais no final perto do organismo
      final arrowOffset = (metric.length * 0.68).clamp(0.0, metric.length);
      final arrowTangent = metric.getTangentForOffset(arrowOffset);
      if (arrowTangent != null) {
        _drawArrow(canvas, arrowTangent.position, arrowTangent.vector, paint);
      }

      if (isCorrect) {
        final numLeaves = (metric.length / 60).floor();
        for(int i = 1; i <= numLeaves; i++) {
          final dist = (metric.length / (numLeaves + 1)) * i;
          final tangent = metric.getTangentForOffset(dist);
          if (tangent != null) {
            _drawLeaf(canvas, tangent.position, tangent.vector, paint);
          }
        }
        
        final particlePaint = Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
          
        for (int i = 0; i < 3; i++) {
          final p = (_time * 0.8 + i / 3.0) % 1.0;
          final safeP = 0.15 + p * 0.7;
          final dist = metric.length * safeP;
          final tangent = metric.getTangentForOffset(dist);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, stroke * 0.8, particlePaint);
          }
        }
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset position, Offset direction, Paint paint) {
    final length = direction.distance;
    if (length == 0) return;
    final unit = direction / length;
    
    // Tamanho mais visível: 22px para corretas, 14px para incorretas
    final arrowSize = isCorrect ? 22.0 : 14.0;
    // Seta no meio da linha — sem offset de organismo
    final arrowPoint = position;
    final perpendicular = Offset(-unit.dy, unit.dx);

    final path = Path()
      ..moveTo(arrowPoint.dx, arrowPoint.dy)
      ..lineTo(
        arrowPoint.dx -
            unit.dx * arrowSize +
            perpendicular.dx * arrowSize * 0.45,
        arrowPoint.dy -
            unit.dy * arrowSize +
            perpendicular.dy * arrowSize * 0.45,
      )
      ..lineTo(
        arrowPoint.dx -
            unit.dx * arrowSize -
            perpendicular.dx * arrowSize * 0.45,
        arrowPoint.dy -
            unit.dy * arrowSize -
            perpendicular.dy * arrowSize * 0.45,
      )
      ..close();

    if (isCorrect) {
      // Glow mais intenso para melhor visibilidade
      final glowPaint = Paint()
        ..color = paint.color.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawPath(path, glowPaint);
    }
    
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionLine &&
          sourceId == other.sourceId &&
          targetId == other.targetId;

  @override
  int get hashCode => Object.hash(sourceId, targetId);
}
