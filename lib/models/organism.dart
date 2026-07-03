class Organism {
  final int? id;
  final int phaseId;
  final String name;
  final String emoji;
  final String trophicLevel;
  final double positionX;
  final double positionY;

  const Organism({
    this.id,
    required this.phaseId,
    required this.name,
    required this.emoji,
    required this.trophicLevel,
    required this.positionX,
    required this.positionY,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'phase_id': phaseId,
    'name': name,
    'emoji': emoji,
    'trophic_level': trophicLevel,
    'position_x': positionX,
    'position_y': positionY,
  };

  factory Organism.fromMap(Map<String, dynamic> map) => Organism(
    id: map['id'] as int?,
    phaseId: map['phase_id'] as int,
    name: map['name'] as String,
    emoji: map['emoji'] as String,
    trophicLevel: map['trophic_level'] as String,
    positionX: (map['position_x'] as num).toDouble(),
    positionY: (map['position_y'] as num).toDouble(),
  );
}
