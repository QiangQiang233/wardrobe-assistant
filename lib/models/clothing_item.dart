class ClothingItem {
  final int? id;
  final String name;
  final String category;
  final String color;
  final String style;
  final String season;
  final String imagePath;
  final DateTime createdAt;

  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.style,
    required this.season,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'style': style,
      'season': season,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      color: map['color'] as String,
      style: map['style'] as String,
      season: map['season'] as String,
      imagePath: map['imagePath'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  ClothingItem copyWith({
    int? id,
    String? name,
    String? category,
    String? color,
    String? style,
    String? season,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      style: style ?? this.style,
      season: season ?? this.season,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}