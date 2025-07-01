import 'package:online_reservation/Features/Documents/Data/Model/category.model.dart';
import 'package:online_reservation/Utils/utils.dart';

class Document {
  final int id;
  final String title;
  final Category category;
  final String? documentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.title,
    required this.category,
    this.documentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      category: Category.fromJson(json['category']),
      documentUrl: json['id_document'] as String?,
      createdAt: Utils.parseAndRoundToQuarter(json['created_at']),
      updatedAt: Utils.parseAndRoundToQuarter(json['updated_at']),
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      documentUrl: documentUrl ?? this.documentUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
