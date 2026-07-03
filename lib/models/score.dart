class Score {
  final int? id;
  final int phaseId;
  final String playerName;
  final int score;
  final int stars;
  final int errors;
  final String completedAt;

  const Score({
    this.id,
    required this.phaseId,
    required this.playerName,
    required this.score,
    required this.stars,
    required this.errors,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'phase_id': phaseId,
    'player_name': playerName,
    'score': score,
    'stars': stars,
    'errors': errors,
    'completed_at': completedAt,
  };

  factory Score.fromMap(Map<String, dynamic> map) => Score(
    id: map['id'] as int?,
    phaseId: map['phase_id'] as int,
    playerName: map['player_name'] as String,
    score: map['score'] as int,
    stars: map['stars'] as int,
    errors: map['errors'] as int,
    completedAt: map['completed_at'] as String,
  );
}
