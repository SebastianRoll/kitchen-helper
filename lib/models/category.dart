class Category {
  final int id;
  final String name;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
    );
  }
}
