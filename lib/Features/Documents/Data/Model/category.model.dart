class Category {
  final int id;
  final String name;
  final int? parent;
  final List<Category> subcategories;

  Category({
    required this.id,
    required this.name,
    this.parent,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['category_name'],
      parent: json['parent'],
      subcategories: (json['subcategories'] as List)
          .map((s) => Category.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parent': parent,
      'category_name': name
    };
  }

  Category copyWith({
    int? id,
    String? name,
    int? parent,
    List<Category>? subcategories,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parent: parent ?? this.parent,
      subcategories: subcategories ?? this.subcategories,
    );
  }
}