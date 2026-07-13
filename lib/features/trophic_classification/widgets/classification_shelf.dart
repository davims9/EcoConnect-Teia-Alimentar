import 'package:flutter/material.dart';
import '../models/classification_card_status.dart';
import '../models/organism_classification.dart';
import 'classification_organism_card.dart';

/// A horizontal shelf showing unplaced organism cards.
///
/// Also acts as a [DragTarget] so players can return placed cards
/// to the shelf by dragging them here.
///
/// [unplacedOrganisms] — organisms currently in the shelf.
/// [selectedOrganismId] — currently selected card (highlighted).
/// [onCardTap] — a card in the shelf was tapped.
/// [onReturnToShelf] — a card was dropped on the shelf to return it.
class ClassificationShelf extends StatelessWidget {
  final List<OrganismClassification> unplacedOrganisms;
  final int? selectedOrganismId;
  final ValueChanged<int>? onCardTap;
  final ValueChanged<OrganismClassification>? onReturnToShelf;

  const ClassificationShelf({
    super.key,
    required this.unplacedOrganisms,
    this.selectedOrganismId,
    this.onCardTap,
    this.onReturnToShelf,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<OrganismClassification>(
      onAcceptWithDetails: (details) => onReturnToShelf?.call(details.data),
      onWillAcceptWithDetails: (_) => true,
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        return Container(
          height: 84,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDragOver
                ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                : const Color(0xFF0B3D22).withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDragOver
                  ? const Color(0xFF7ED957).withValues(alpha: 0.60)
                  : const Color(0xFF2E7D32).withValues(alpha: 0.40),
              width: isDragOver ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4, right: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: const Color(0xFFA4F69E).withValues(alpha: 0.70),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Prateleira',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA4F69E).withValues(alpha: 0.70),
                      ),
                    ),
                    if (unplacedOrganisms.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${unplacedOrganisms.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(
                            0xFFA4F69E,
                          ).withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: unplacedOrganisms.isEmpty
                    ? Center(
                        child: Text(
                          'Arraste cards para cá para devolvê-los',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(
                              0xFFA4F69E,
                            ).withValues(alpha: 0.35),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: unplacedOrganisms.length,
                        itemBuilder: (context, index) {
                          final org = unplacedOrganisms[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClassificationOrganismCard(
                              organism: org,
                              status: ClassificationCardStatus.shelf,
                              isSelected: selectedOrganismId == org.organismId,
                              onTap: onCardTap != null
                                  ? () => onCardTap!(org.organismId)
                                  : null,
                              width: 72,
                              height: 74,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
