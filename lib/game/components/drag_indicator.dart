import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import '../../core/app_colors.dart';

class DragIndicator extends Component {
  final Offset start;
  final Offset end;
  double _time = 0;

  DragIndicator({required this.start, required this.end});

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.connectionLineHover
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashLen = 10.0;
    final gap = 6.0;
    final total = dashLen + gap;
    final direction = end - start;
    final length = direction.distance;
    if (length == 0) return;
    final unit = direction / length;
    final offset = (_time * 60 % total);

    double distance = -offset;
    while (distance < length) {
      final segStart = start + unit * max(distance, 0);
      final segEnd = start + unit * min(distance + dashLen, length);
      canvas.drawLine(segStart, segEnd, paint);
      distance += total;
    }
  }
}
