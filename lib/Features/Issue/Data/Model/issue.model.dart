// models/issue.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:online_reservation/Utils/utils.dart';

enum IssueStatus { DRAFT, OPEN, RESOLVED, IN_PROGRESS}
extension IssueStatusExtension on IssueStatus {
  String get displayName {
    switch (this) {
      case IssueStatus.DRAFT:
        return 'Draft';
      case IssueStatus.OPEN:
        return 'Open';
      case IssueStatus.RESOLVED:
        return 'Resolved';
      case IssueStatus.IN_PROGRESS:
        return 'In Progress';
    }
  }

  Color get color => Colors.blue;

  IconData get icon {
    switch (this) {
      case IssueStatus.DRAFT:
        return Icons.drafts;
      case IssueStatus.OPEN:
        return Icons.circle_outlined;
      case IssueStatus.IN_PROGRESS:
        return Icons.pending;
      case IssueStatus.RESOLVED:
        return Icons.check_circle;
    }
  }

  String get jsonName{
    switch (this) {
      case IssueStatus.DRAFT:
        return 'draft';
      case IssueStatus.OPEN:
        return 'open';
      case IssueStatus.RESOLVED:
        return 'resolved';
      case IssueStatus.IN_PROGRESS:
        return 'in_progress';
    }
  }

  // Moved _parseStatus into the extension
  static IssueStatus fromJson(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'draft':
        return IssueStatus.DRAFT;
      case 'open':
        return IssueStatus.OPEN;
      case 'resolved':
        return IssueStatus.RESOLVED;
      case 'in_progress':
        return IssueStatus.IN_PROGRESS;
      default:
        if (kDebugMode) {
          print('Warning: Unknown issue status "$statusString". Defaulting to OPEN.');
        }
        return IssueStatus.OPEN;
    }
  }
}

enum IssueType { MAINTENANCE, SECURITY, CLEANLINESS, NEIGHBOR, ADMINISTRATIVE}
extension IssueTypeExtension on IssueType {
  String get displayName {
    switch (this) {
      case IssueType.MAINTENANCE:
        return "Maintenance and Infrastructure Issue";
      case IssueType.SECURITY:
        return "Security and Safety Concern";
      case IssueType.CLEANLINESS:
        return "Cleanliness and Sanitation";
      case IssueType.NEIGHBOR:
        return "Neighbor-Related Complaint";
      case IssueType.ADMINISTRATIVE:
        return "Administrative or Community Concern";
    }
  }

  Color get color {
    switch (this) {
      case IssueType.MAINTENANCE:
        return Colors.orange; // Maintenance: attention/warning
      case IssueType.SECURITY:
        return Colors.red; // Security: danger/alert
      case IssueType.CLEANLINESS:
        return Colors.green; // Cleanliness: fresh/clean
      case IssueType.NEIGHBOR:
        return Colors.blue; // Neighbor: communication/relationship
      case IssueType.ADMINISTRATIVE:
        return Colors.purple; // Administrative: authority/management
    }
  }

  IconData get icon {
    switch (this) {
      case IssueType.MAINTENANCE:
        return Icons.build; // 🛠 Better represents maintenance/repairs
      case IssueType.SECURITY:
        return Icons.security; // 🛡 Security-related issues
      case IssueType.CLEANLINESS:
        return Icons.cleaning_services; // 🧹 Perfect for cleanliness/sanitation
      case IssueType.NEIGHBOR:
        return Icons.people; // 👥 Indicates neighbor-related concerns
      case IssueType.ADMINISTRATIVE:
        return Icons.admin_panel_settings; // 🗂 Administrative or community issues
    }
  }

  String get jsonName{
    switch (this) {
      case IssueType.MAINTENANCE:
        return 'maintenance';
      case IssueType.SECURITY:
        return 'security';
      case IssueType.CLEANLINESS:
        return 'cleanliness';
      case IssueType.NEIGHBOR:
        return 'neighbor';
      case IssueType.ADMINISTRATIVE:
        return 'administrative';
    }
  }

  // Moved _parseStatus into the extension
  static IssueType fromJson(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'maintenance':
        return IssueType.MAINTENANCE;
      case 'security':
        return IssueType.SECURITY;
      case 'cleanliness':
        return IssueType.CLEANLINESS;
      case 'neighbor':
        return IssueType.NEIGHBOR;
      case 'administrative':
        return IssueType.ADMINISTRATIVE;
      default:
        if (kDebugMode) {
          print('Warning: Unknown issue status "$statusString". Defaulting to OPEN.');
        }
        return IssueType.MAINTENANCE;
    }
  }
}


enum IssuePriority { LOW, MEDIUM, HIGH, CRITICAL }
extension IssuePriorityExtension on IssuePriority {
  String get displayName {
    switch (this) {
      case IssuePriority.LOW:
        return 'Low';
      case IssuePriority.MEDIUM:
        return 'Medium';
      case IssuePriority.HIGH:
        return 'High';
      case IssuePriority.CRITICAL:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case IssuePriority.LOW:
        return Colors.blue;
      case IssuePriority.MEDIUM:
        return Colors.yellow;
      case IssuePriority.HIGH:
        return Colors.orange;
      case IssuePriority.CRITICAL:
        return Colors.red;
    }
  }

  String get jsonName{
    switch (this) {
      case IssuePriority.LOW:
        return 'low';
      case IssuePriority.MEDIUM:
        return 'medium';
      case IssuePriority.HIGH:
        return 'high';
      case IssuePriority.CRITICAL:
        return 'critical';
    }
  }

  // Moved _parsePriority into the extension
  static IssuePriority fromJson(String priorityString) {
    switch (priorityString.toLowerCase()) {
      case 'low':
        return IssuePriority.LOW;
      case 'medium':
        return IssuePriority.MEDIUM;
      case 'high':
        return IssuePriority.HIGH;
      case 'critical':
        return IssuePriority.CRITICAL;
      default:
        if (kDebugMode) {
          print('Warning: Unknown issue priority "$priorityString". Defaulting to MEDIUM.');
        }
        return IssuePriority.MEDIUM;
    }
  }
}



class Issue {
  final int? id;
  final String title;
  // final String description;
  final IssueType issueType;
  final IssueStatus status;
  final IssuePriority priority;
  final String? imageUrl;
  final DateTime? reportedDate;
  final DateTime? resolvedDate;
  final String? userFullName;
  final int? userId;
  final String? assigneeFullName;
  final int? assigneeId;

  Issue({
    this.id,
    required this.title,
    // required this.description,
    required this.issueType, // ✅ Include the issueType field
    required this.status,
    required this.priority,
    this.imageUrl,
    this.reportedDate,
    this.resolvedDate,
    this.userFullName,
    this.userId,
    this.assigneeFullName,
    this.assigneeId,
  });


  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
    id: json['id'],
    title: json['title'],
    // description: json['description'],
    issueType: IssueTypeExtension.fromJson(json['issue_type'] as String), // ✅ map to IssueType
    status: IssueStatusExtension.fromJson(json['status'] as String),
    priority: IssuePriorityExtension.fromJson(json['priority'] as String),
    imageUrl: json['image'] as String?,
    reportedDate: json['reported_date'] != null ? Utils.parseAndRoundToQuarter(json['reported_date']) : null,
    resolvedDate: json['resolved_date'] != null ? Utils.parseAndRoundToQuarter(json['resolved_date']) : null,
    userFullName: json['user_full_name'],
    userId: json['user'],
    assigneeFullName: json['assigned_to_full_name'],
    assigneeId: json['assigned_to'],
  );


  Map<String, dynamic> toJson() {
    return {
      'title': title,
      // 'description': description,
      'issue_type': issueType.jsonName, // ✅ include issueType in JSON
      'status': status.jsonName,
      'priority': priority.jsonName,
      'assigned_residence_id': assigneeId,
    };
  }

  Issue copyWith({
    int? id,
    String? title,
    // String? description,
    IssueStatus? status,
    IssueType? issueType,
    IssuePriority? priority,
    String? imageUrl,
    String? userFullName,
    int? userId,
    String? assigneeFullName,
    int? assigneeId,
    DateTime? reportedDate,
    DateTime? resolvedDate,
  }) {
    return Issue(
      id: id ?? this.id,
      title: title ?? this.title,
      // description: description ?? this.description,
      status: status ?? this.status,
      issueType: issueType ?? this.issueType,
      priority: priority ?? this.priority,
      imageUrl: imageUrl ?? this.imageUrl,
      userFullName: userFullName ?? this.userFullName,
      userId: userId ?? this.userId,
      assigneeFullName: assigneeFullName ?? this.assigneeFullName,
      assigneeId: assigneeId ?? this.assigneeId,
      reportedDate: reportedDate ?? this.reportedDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
    );
  }

  bool isOwner(int user) => user == userId;

  @override
  String toString() {
    return 'Issue('
        'id: $id, '
        'title: $title, '
        // 'description: $description, '

        'issueType: ${issueType.displayName}, '
        'status: ${status.name}, '
        'priority: ${priority.name}, '
        'imageUrl: $imageUrl, '
        'reportedDate: $reportedDate, '
        'resolvedDate: $resolvedDate, '
        'userFullName: $userFullName, '
        'userId: $userId, '
        'assigneeFullName: $assigneeFullName, '
        'assigneeId: $assigneeId'
        ')';
  }
}
