import 'package:flutter/material.dart';
import '../models/classification_card_status.dart';
import '../models/organism_classification.dart';
import '../models/trophic_level.dart';
import 'classification_organism_card.dart';
import 'classification_zone_colors.dart';

/// A trophic-level zone — a [DragTarget] that accepts organism cards.
///
/// Displays a coloured zone label, the list of placed organisms, and a
/// placeholder when empty. Supports tap-to-place: fires [onZoneTap] so
/// the parent can move a selected card into this zone.
///
/// [level] — the trophic level this zone represents.
/// [organisms] — list of organisms currently placed in this zone.
/// [statuses] — status map so each card renders correctly.
/// [isHighlighted] — visual highlight (hint directional level).
/// [selectedOrganismId] — if non-null, the card with this ID shows selected state.
/// [onCardTap] — a card was tapped (selection or hint target).
/// [onAccept] — a card was dropped into this zone.
/// [onZoneTap] — the zone area (not a card) was tapped.
class ClassificationZone extends StatelessWidget {
  final TrophicLevel level;
  final List<OrganismClassification> organisms;
  final Map<int, ClassificationCardStatus> statuses;
  final bool isHighlighted;
  final int? selectedOrganismId;
  final ValueChanged<int>? onCardTap;
  final ValueChanged<OrganismClassification>? onAccept;
  final VoidCallback? onZoneTap;

  const ClassificationZone({
    super.key,
    required this.level,
    required this.organisms,
    required this.statuses,
    this.isHighlighted = false,
    this.selectedOrganismId,
    this.onCardTap,
    this.onAccept,
    this.onZoneTap,
  });

  Color get _zoneColor => ClassificationZoneColors.colorOf(level);

  @override
  Widget build(BuildContext context) {
    return DragTarget<OrganismClassification>(
      onAcceptWithDetails: (details) => onAccept?.call(details.data),
      onWillAcceptWithDetails: (_) => true,
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDragOver || isHighlighted
                ? _zoneColor.withValues(alpha: 0.08)
                : const Color(0xFF0B3D22).withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: isDragOver || isHighlighted
                    ? _zoneColor
                    : _zoneColor.withValues(alpha: 0.60),
                width: isDragOver ? 4 : (isHighlighted ? 4 : 3),
              ),
            ),
          ),
          child: GestureDetector(
            onTap: onZoneTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -- Zone label row -------------------------------------------
                  Row(
                    children: [
                      Icon(
                        ClassificationZoneColors.iconOf(level),
                        size: 18,
                        color: _zoneColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ClassificationZoneColors.labelOf(level),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _zoneColor,
                          ),
                        ),
                      ),
                      if (organisms.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _zoneColor.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${organisms.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _zoneColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // -- Cards ----------------------------------------------------
                  if (organisms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: _zoneColor.withValues(alpha: 0.40),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arraste ou toque num card e toque aqui',
                            style: TextStyle(
                              fontSize: 12,
                              color: _zoneColor.withValues(alpha: 0.50),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: organisms.map((org) {
                        final status =
                            statuses[org.organismId] ??
                            ClassificationCardStatus.placed;
                        return ClassificationOrganismCard(
                          organism: org,
                          status: status,
                          isSelected: selectedOrganismId == org.organismId,
                          draggable:
                              status != ClassificationCardStatus.lockedCorrect,
                          onTap: onCardTap != null
                              ? () => onCardTap!(org.organismId)
                              : null,
                          width: 82,
                          height: 88,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
