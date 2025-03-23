// models/issue.dart
class Issue {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime reportedDate;
  final DateTime? resolvedDate;
  final String residentName;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.reportedDate,
    this.resolvedDate,
    required this.residentName,
  });

  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    status: json['status'],
    reportedDate: DateTime.parse(json['reported_date']),
    resolvedDate: json['resolved_date'] != null
        ? DateTime.parse(json['resolved_date'])
        : null,
    residentName: json['resident_name'],
  );
}