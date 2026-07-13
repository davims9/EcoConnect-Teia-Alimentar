import 'package:flutter/material.dart';
import '../models/classification_card_status.dart';
import '../models/organism_classification.dart';
import 'classification_organism_card.dart';

/// A horizontal shelf showing unplaced organism cards.
///
/// Also acts as a [DragTarget] so players can return placed cards
/// to the shelf by dragging them here.
///
/// Compact design: when empty, displays a thin message;
/// when populated, shows one horizontal row of cards.
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
    final isEmpty = unplacedOrganisms.isEmpty;

    return DragTarget<OrganismClassification>(
      onAcceptWithDetails: (details) => onReturnToShelf?.call(details.data),
      onWillAcceptWithDetails: (_) => true,
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty;
        final height = isEmpty ? 32.0 : 82.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDragOver
                ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                : const Color(0xFF0B3D22).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDragOver
                  ? const Color(0xFF7ED957).withValues(alpha: 0.60)
                  : const Color(0xFF2E7D32).withValues(alpha: 0.30),
              width: isDragOver ? 2 : 1,
            ),
          ),
          child: isEmpty
              ? Center(
                  child: Text(
                    'Todos os organismos foram posicionados',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFFA4F69E).withValues(alpha: 0.40),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 3,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 12,
                            color: const Color(
                              0xFFA4F69E,
                            ).withValues(alpha: 0.50),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Prateleira',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(
                                0xFFA4F69E,
                              ).withValues(alpha: 0.50),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${unplacedOrganisms.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(
                                0xFFA4F69E,
                              ).withValues(alpha: 0.40),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        itemCount: unplacedOrganisms.length,
                        itemBuilder: (context, index) {
                          final org = unplacedOrganisms[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ClassificationOrganismCard(
                              organism: org,
                              status: ClassificationCardStatus.shelf,
                              isSelected: selectedOrganismId == org.organismId,
                              onTap: onCardTap != null
                                  ? () => onCardTap!(org.organismId)
                                  : null,
                              width: 70,
                              height: 68,
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
