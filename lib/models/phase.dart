class Phase {
  final int? id;
  final String name;
  final String description;
  final String biome;
  final int sortOrder;

  const Phase({
    this.id,
    required this.name,
    required this.description,
    required this.biome,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'biome': biome,
    'sort_order': sortOrder,
  };

  factory Phase.fromMap(Map<String, dynamic> map) => Phase(
    id: map['id'] as int?,
    name: map['name'] as String,
    description: map['description'] as String,
    biome: map['biome'] as String,
    sortOrder: map['sort_order'] as int,
  );
}
