import 'organism_classification.dart';

/// Configuration for a single classification phase.
///
/// Has its own identity ([key]) independent of the Teia mode phase id.
/// The [biomePhaseId] links back to the shared biome/phase data.
class ClassificationPhaseConfig {
  final String key;
  final int biomePhaseId;
  final String biomeName;
  final List<OrganismClassification> organisms;
  final List<String> learningMessages;

  const ClassificationPhaseConfig({
    required this.key,
    required this.biomePhaseId,
    required this.biomeName,
    required this.organisms,
    required this.learningMessages,
  });

  int get totalOrganisms => organisms.length;
}
