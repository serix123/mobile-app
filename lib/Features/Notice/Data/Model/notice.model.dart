import 'package:online_reservation/Utils/utils.dart';

class Notice {
  final int? id;
  final String title;
  final String? details;
  final String? imageUrl;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Notice({
    this.id,
    required this.title,
    this.details,
    this.imageUrl,
    this.createdDate,
    this.updatedDate,
  });

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
    id: json['id'],
    title: json['title'] ?? "",
    details: json['details'],
    imageUrl: json['image'],
    createdDate: Utils.parseAndRoundToQuarter(json['created_at']),
    updatedDate: Utils.parseAndRoundToQuarter(json['updated_at']),
  );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'details': details
    };
  }

  Notice copyWith({
    int? id,
    String? title,
    String? details,
    String? imageUrl,
    DateTime? createdDate,
    DateTime? updatedDate
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      imageUrl: imageUrl ?? this.imageUrl,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}
