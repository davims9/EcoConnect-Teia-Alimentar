import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class StarsDisplay extends StatelessWidget {
  final int stars;
  final double size;

  const StarsDisplay({
    super.key,
    required this.stars,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 2 ? 2 : 0),
          child: Icon(
            index < stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppColors.hint,
            size: size,
          ),
        );
      }),
    );
  }
}
