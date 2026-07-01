import 'dart:ui';

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

  ConnectionLine({
    required this.sourceId,
    required this.targetId,
    required this.start,
    required this.end,
    this.color = AppColors.connectionLine,
  }) : _targetColor = color;

  void animateColor(Color newColor) {
    _targetColor = newColor;
    _colorProgress = 0;
  }

  /// Flashes white briefly then transitions to [finalColor].
  void flashThenColor(Color finalColor) {
    color = const Color(0xFFFFFFFF);
    _targetColor = finalColor;
    _colorProgress = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_progress < _targetProgress) {
      _progress += dt * 4;
      if (_progress > _targetProgress) _progress = _targetProgress;
    }
    if (_colorProgress < 1) {
      _colorProgress += dt * 3;
      if (_colorProgress > 1) _colorProgress = 1;
      color = Color.lerp(color, _targetColor, _colorProgress.clamp(0, 1) as double)!;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = AppConstants.lineStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final direction = end - start;
    final drawEnd = Offset.lerp(start, end, _progress)!;
    canvas.drawLine(start, drawEnd, paint);
    if (_progress >= 1) {
      _drawArrow(canvas, start, end, paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    final direction = end - start;
    final length = direction.distance;
    if (length == 0) return;
    final unit = direction / length;
    final arrowSize = 12.0;
    final arrowPoint = end - unit * (AppConstants.organismSize / 2);
    final perpendicular = Offset(-unit.dy, unit.dx);

    final path = Path()
      ..moveTo(arrowPoint.dx, arrowPoint.dy)
      ..lineTo(
        arrowPoint.dx - unit.dx * arrowSize + perpendicular.dx * arrowSize * 0.4,
        arrowPoint.dy - unit.dy * arrowSize + perpendicular.dy * arrowSize * 0.4,
      )
      ..lineTo(
        arrowPoint.dx - unit.dx * arrowSize - perpendicular.dx * arrowSize * 0.4,
        arrowPoint.dy - unit.dy * arrowSize - perpendicular.dy * arrowSize * 0.4,
      )
      ..close();

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
