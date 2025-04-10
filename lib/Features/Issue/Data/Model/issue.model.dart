// models/issue.dart

import 'package:flutter/material.dart';

enum IssueStatus { OPEN, RESOLVED, }
extension IssueStatusExtension on IssueStatus {
  String get displayName {
    switch (this) {
      case IssueStatus.OPEN:
        return 'Open';
      case IssueStatus.RESOLVED:
        return 'Resolved';
    }
  }

  Color get color {
    switch (this) {
      case IssueStatus.OPEN:
        return Colors.red;
      case IssueStatus.RESOLVED:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case IssueStatus.OPEN:
        return Icons.access_time_filled;
      case IssueStatus.RESOLVED:
        return Icons.check_circle;
    }
  }
}

class Issue {
  final int? id;
  final String title;
  final String description;
  final IssueStatus? status;
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
        status: _parseStatus(json['status']),
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

  static IssueStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return IssueStatus.OPEN;
      case 'resolved':
        return IssueStatus.RESOLVED;
      default:
        return IssueStatus.OPEN;
    }
  }
}
