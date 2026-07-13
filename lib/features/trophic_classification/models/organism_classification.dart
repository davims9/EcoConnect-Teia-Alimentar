import 'trophic_level.dart';

/// Contextual classification data for one organism in a classification phase.
///
/// The [expectedLevel] is phase-specific and may differ from the global
/// `Organism.trophicLevel` stored in the seed.
///
/// [isTopPredator] is a contextual badge, not a fifth trophic level.
/// It is computed from the phase connections (absence in `source_id`)
/// but can be explicitly overridden for pedagogical reasons.
///
/// [emoji] and [displayName] carry presentation data for cards.
class OrganismClassification {
  final int organismId;
  final TrophicLevel expectedLevel;
  final bool isTopPredator;
  final String justification;
  final List<String> hintMessages;
  final String emoji;
  final String displayName;

  const OrganismClassification({
    required this.organismId,
    required this.expectedLevel,
    required this.isTopPredator,
    required this.justification,
    required this.hintMessages,
    this.emoji = '🦠',
    this.displayName = '',
  });
}
