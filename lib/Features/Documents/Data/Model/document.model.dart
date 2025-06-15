import 'package:online_reservation/Features/Documents/Data/Model/category.model.dart';

class Document {
  final int id;
  final String title;
  final Category category;
  final String? documentUrl;

  Document({
    required this.id,
    required this.title,
    required this.category,
    this.documentUrl,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      category: Category.fromJson(json['category']),
      documentUrl: json['id_document'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category_id': category.id
    };
  }

  Document copyWith({
    int? id,
    String? title,
    String? documentUrl,
    Category? category,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      documentUrl: documentUrl ?? this.documentUrl,
      category: category ?? this.category,
    );
  }
}
