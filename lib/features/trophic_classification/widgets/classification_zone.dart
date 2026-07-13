import 'package:flutter/material.dart';
import '../models/classification_card_status.dart';
import '../models/organism_classification.dart';
import '../models/trophic_level.dart';
import 'classification_organism_card.dart';
import 'classification_zone_colors.dart';

/// A trophic-level zone — a [DragTarget] that accepts organism cards.
///
/// Compact horizontal layout: zone label on the left, organism cards on the
/// right in a scrollable row. The zone height matches the card height so
/// multiple zones stack compactly without wasted vertical space.
///
/// Supports tap-to-place: fires [onZoneTap] so the parent can move a
/// selected card into this zone.
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
          height: 82,
          decoration: BoxDecoration(
            color: isDragOver || isHighlighted
                ? _zoneColor.withValues(alpha: 0.08)
                : const Color(0xFF0B3D22).withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(10),
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // -- Zone label (compact, left side, vertical stack) --
                  SizedBox(
                    width: 54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ClassificationZoneColors.iconOf(level),
                          size: 16,
                          color: _zoneColor,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ClassificationZoneColors.shortLabelOf(level),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _zoneColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // -- Cards area (horizontal scrollable row) --
                  Expanded(
                    child: organisms.isEmpty
                        ? Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 16,
                                  color: _zoneColor.withValues(alpha: 0.40),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Arraste ou toque num card',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _zoneColor.withValues(alpha: 0.50),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: organisms.length,
                            itemBuilder: (context, index) {
                              final org = organisms[index];
                              final status =
                                  statuses[org.organismId] ??
                                  ClassificationCardStatus.placed;
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index < organisms.length - 1 ? 6 : 0,
                                ),
                                child: ClassificationOrganismCard(
                                  organism: org,
                                  status: status,
                                  isSelected:
                                      selectedOrganismId == org.organismId,
                                  draggable:
                                      status !=
                                      ClassificationCardStatus.lockedCorrect,
                                  onTap: onCardTap != null
                                      ? () => onCardTap!(org.organismId)
                                      : null,
                                  width: 76,
                                  height: 74,
                                ),
                              );
                            },
                          ),
                  ),
                  // -- Count badge --
                  if (organisms.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _zoneColor.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${organisms.length}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _zoneColor,
                          ),
                        ),
                      ),
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
