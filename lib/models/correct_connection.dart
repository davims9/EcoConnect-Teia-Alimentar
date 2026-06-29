class CorrectConnection {
  final int? id;
  final int phaseId;
  final int sourceId;
  final int targetId;

  const CorrectConnection({
    this.id,
    required this.phaseId,
    required this.sourceId,
    required this.targetId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'phase_id': phaseId,
        'source_id': sourceId,
        'target_id': targetId,
      };

  factory CorrectConnection.fromMap(Map<String, dynamic> map) =>
      CorrectConnection(
        id: map['id'] as int?,
        phaseId: map['phase_id'] as int,
        sourceId: map['source_id'] as int,
        targetId: map['target_id'] as int,
      );

  String get key => '$sourceId-$targetId';
}
