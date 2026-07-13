import 'package:flutter/material.dart';
import '../models/classification_card_status.dart';
import '../models/organism_classification.dart';
import '../models/trophic_level.dart';
import 'classification_organism_card.dart';
import 'classification_zone_colors.dart';

/// A trophic-level zone — a [DragTarget] that accepts organism cards.
///
/// Height is determined by content (info block + card row). Each zone
/// has a translucent background in the level colour so the biome image
/// remains visible underneath.
///
/// Layout: [info block (fixed width)] [cards (expanding)].
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
        final highlight = isDragOver || isHighlighted;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: const BoxConstraints(minHeight: 86, maxHeight: 120),
          decoration: BoxDecoration(
            color: highlight
                ? _zoneColor.withValues(alpha: 0.20)
                : _zoneColor.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlight
                  ? _zoneColor
                  : _zoneColor.withValues(alpha: 0.85),
              width: highlight ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _zoneColor.withValues(alpha: highlight ? 0.25 : 0.18),
                blurRadius: highlight ? 14 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: onZoneTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // -- Level info (fixed width) --
                  SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Level number + icon
                        Row(
                          children: [
                            Icon(
                              ClassificationZoneColors.iconOf(level),
                              size: 14,
                              color: _zoneColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${ClassificationZoneColors.levelNumberOf(level)} N\u00EDvel Tr\u00F3fico',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _zoneColor.withValues(alpha: 0.90),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // Category name (never abbreviated)
                        Text(
                          ClassificationZoneColors.labelOf(level),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _zoneColor,
                            height: 1.15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        // Short description
                        Text(
                          ClassificationZoneColors.descriptionOf(level),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _zoneColor.withValues(alpha: 0.75),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // -- Cards area --
                  Expanded(
                    child: organisms.isEmpty
                        ? Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 14,
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
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: organisms.map((org) {
                                final status =
                                    statuses[org.organismId] ??
                                    ClassificationCardStatus.placed;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
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
                                    height: 76,
                                  ),
                                );
                              }).toList(),
                            ),
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
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${organisms.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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
