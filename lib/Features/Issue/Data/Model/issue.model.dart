// models/issue.dart
// models/issue.dart
class Issue {
  final int? id;
  final String title;
  final String description;
  final String? status;
  final DateTime? reportedDate;
  final DateTime? resolvedDate;
  final String? residentName;

  Issue({
    this.id,
    required this.title,
    required this.description,
    this.status,
    this.reportedDate,
    this.resolvedDate,
    this.residentName,
  });

  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        status: json['status'],
        reportedDate: json['reported_date'] != null ? DateTime.parse(json['reported_date']) : null,
        resolvedDate: json['resolved_date'] != null ? DateTime.parse(json['resolved_date']) : null,
        residentName: json['resident_name'],
      );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }

  Issue copyWith(Issue issue) {
    return Issue(
      id: id,
      title: issue.title,
      description: issue.description,
      status: issue.status,
      reportedDate: issue.reportedDate,
      resolvedDate: issue.resolvedDate,
      residentName: residentName,
    );
  }
}
