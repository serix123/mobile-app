// visit_model.dart
import 'package:flutter/material.dart';
import 'package:online_reservation/Utils/utils.dart';

enum Status { PENDING, CHECKED_IN, CHECKED_OUT,  }
extension StatusExtension on Status {
  String get displayName {
    switch (this) {
      case Status.PENDING:
        return 'Pending';
      case Status.CHECKED_IN:
        return 'Checked In';
      case Status.CHECKED_OUT:
        return 'Checked Out';
    }
  }

  Color get color {
    switch (this) {
      case Status.PENDING:
        return Colors.orange ;
      case Status.CHECKED_IN:
        return Colors.green;
      case Status.CHECKED_OUT:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case Status.PENDING:
        return Icons.timer_off;
      case Status.CHECKED_IN:
        return Icons.access_time_filled;
      case Status.CHECKED_OUT:
        return Icons.directions_walk;
    }
  }
}

class Visitor {
  final int id;
  final String name;
  final String residentName;
  final DateTime visitDate;
  final String visitPurpose;
  final Status status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int residence;
  final DateTime createdAt;
  final DateTime updatedAt;

  Visitor({
    required this.id,
    required this.name,
    required this.residentName,
    required this.visitDate,
    required this.visitPurpose,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.residence,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'],
      name: json['name'],
      residentName: json['resident_name'],
      visitDate: DateTime.parse(json['visit_date']),
      visitPurpose: json['visit_purpose'],
      status: _parseStatus(json['status']),
      checkInTime: json['check_in_time'] != null ? DateTime.parse(json['check_in_time']) : null,
      checkOutTime: json['check_out_time'] != null ? DateTime.parse(json['check_out_time']) : null,
      residence: json['residence'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Visitor copyWith(VisitorDTO visitor) {
    return Visitor(
      id: id,
      name: visitor.name,
      residentName: residentName,
      visitDate: visitor.visitDate,
      visitPurpose: visitor.visitPurpose,
      status: status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      residence: residence,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Status _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Status.PENDING;
      case 'checked_in':
        return Status.CHECKED_IN;
      case 'checked_out':
        return Status.CHECKED_OUT;
      default:
        return Status.PENDING;
    }
  }
}

class PaginatedVisitors {
  final int count;
  final String? next;
  final String? previous;
  final List<Visitor> results;

  PaginatedVisitors({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedVisitors.fromJson(Map<String, dynamic> json) {
    return PaginatedVisitors(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List).map((visitJson) => Visitor.fromJson(visitJson)).toList(),
    );
  }
}

class VisitorDTO {
  final int? id;
  final String name;
  final DateTime visitDate;
  final String visitPurpose;

  VisitorDTO({this.id, required this.name, required this.visitDate, required this.visitPurpose});

  factory VisitorDTO.fromJson(Map<String, dynamic> json) {
    return VisitorDTO(
      // id: json['id'],
      name: json['name'],
      visitDate: DateTime.parse(json['visit_date']),
      visitPurpose: json['visit_purpose'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'visit_date': Utils.formatDate(visitDate),
      'visit_purpose': visitPurpose,
    };
  }
}
