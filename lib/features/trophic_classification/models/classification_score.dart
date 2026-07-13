/// A saved score for a completed classification phase.
///
/// Mirrors the `classification_scores` table schema.
/// Uses the same `toMap` / `fromMap` pattern as [Score].
class ClassificationScore {
  final int? id;
  final String classificationPhaseKey;
  final int biomePhaseId;
  final String playerName;
  final int score;
  final int maxScore;
  final int stars;
  final int wrongPlacements;
  final int hintsUsed;
  final int attempts;
  final String completedAt;

  const ClassificationScore({
    this.id,
    required this.classificationPhaseKey,
    required this.biomePhaseId,
    required this.playerName,
    required this.score,
    required this.maxScore,
    required this.stars,
    required this.wrongPlacements,
    this.hintsUsed = 0,
    required this.attempts,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'classification_phase_key': classificationPhaseKey,
    'biome_phase_id': biomePhaseId,
    'player_name': playerName,
    'score': score,
    'max_score': maxScore,
    'stars': stars,
    'wrong_placements': wrongPlacements,
    'hints_used': hintsUsed,
    'attempts': attempts,
    'completed_at': completedAt,
  };

  factory ClassificationScore.fromMap(Map<String, dynamic> map) =>
      ClassificationScore(
        id: map['id'] as int?,
        classificationPhaseKey: map['classification_phase_key'] as String,
        biomePhaseId: map['biome_phase_id'] as int,
        playerName: map['player_name'] as String,
        score: map['score'] as int,
        maxScore: map['max_score'] as int,
        stars: map['stars'] as int,
        wrongPlacements: map['wrong_placements'] as int,
        hintsUsed: map['hints_used'] as int? ?? 0,
        attempts: map['attempts'] as int,
        completedAt: map['completed_at'] as String,
      );
}
