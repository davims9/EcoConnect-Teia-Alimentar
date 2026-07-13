import 'package:flutter/material.dart';
import '../models/classification_card_status.dart';
import '../models/organism_classification.dart';

/// Visual card for one organism in the classification mode.
///
/// Supports two interaction modes:
/// 1. **Tap** — fires [onTap] for selection / placement.
/// 2. **Long-press drag** — participates in drag-and-drop via
///    [LongPressDraggable] when [draggable] is true.
///
/// Visual adapts to the five [ClassificationCardStatus] values:
/// - [shelf] / [placed] → neutral green border.
/// - [verifiedIncorrect] → amber border + error badge.
/// - [lockedCorrect] → bright green border + check badge.
class ClassificationOrganismCard extends StatelessWidget {
  final OrganismClassification organism;
  final ClassificationCardStatus status;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool draggable;

  /// Preferred width. Default 88.
  final double width;

  /// Preferred height. Default 96.
  final double height;

  const ClassificationOrganismCard({
    super.key,
    required this.organism,
    required this.status,
    this.isSelected = false,
    this.onTap,
    this.draggable = true,
    this.width = 88,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    final card = _CardBody(
      organism: organism,
      status: status,
      isSelected: isSelected,
      onTap: onTap,
      width: width,
      height: height,
    );

    if (!draggable || status == ClassificationCardStatus.lockedCorrect) {
      return card;
    }

    return LongPressDraggable<OrganismClassification>(
      data: organism,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: _CardBody(
          organism: organism,
          status: status,
          isSelected: false,
          width: width,
          height: height,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _CardBody(
          organism: organism,
          status: status,
          isSelected: false,
          width: width,
          height: height,
        ),
      ),
      child: card,
    );
  }
}

/// Pure visual card body (no drag wrapper).
class _CardBody extends StatelessWidget {
  final OrganismClassification organism;
  final ClassificationCardStatus status;
  final bool isSelected;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const _CardBody({
    required this.organism,
    required this.status,
    required this.isSelected,
    this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : _borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _borderColor.withValues(alpha: 0.2),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Text(organism.emoji, style: const TextStyle(fontSize: 24)),
                if (status == ClassificationCardStatus.lockedCorrect)
                  const Positioned(
                    right: -4,
                    top: -4,
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(0xFF7ED957),
                    ),
                  ),
                if (status == ClassificationCardStatus.verifiedIncorrect)
                  const Positioned(
                    right: -4,
                    top: -4,
                    child: Icon(
                      Icons.error,
                      size: 16,
                      color: Color(0xFFFDBA74),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              organism.displayName.isNotEmpty
                  ? organism.displayName
                  : 'ID ${organism.organismId}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case ClassificationCardStatus.lockedCorrect:
        return const Color(0xFF14532D);
      case ClassificationCardStatus.verifiedIncorrect:
        return const Color(0xFF3D2020);
      case ClassificationCardStatus.shelf:
      case ClassificationCardStatus.placed:
      case ClassificationCardStatus.verifiedCorrect:
        return const Color(0xFF14532D);
    }
  }

  Color get _borderColor {
    switch (status) {
      case ClassificationCardStatus.lockedCorrect:
        return const Color(0xFF7ED957);
      case ClassificationCardStatus.verifiedIncorrect:
        return const Color(0xFFFDBA74);
      case ClassificationCardStatus.shelf:
      case ClassificationCardStatus.placed:
      case ClassificationCardStatus.verifiedCorrect:
        return const Color(0xFF2E7D32);
    }
  }

  Color get _textColor {
    return const Color(0xFFF0FDF4);
  }
}
