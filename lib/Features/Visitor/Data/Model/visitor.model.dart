// visit_model.dart
import 'package:online_reservation/Utils/utils.dart';

class Visitor {
  final int id;
  final String name;
  final String residentName;
  final DateTime visitDate;
  final String visitPurpose;
  final String status;
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
      status: json['status'],
      checkInTime: json['check_in_time'] != null ? DateTime.parse(json['check_in_time']) : null,
      checkOutTime: json['check_out_time'] != null ? DateTime.parse(json['check_out_time']) : null,
      residence: json['residence'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Visitor copyWith({String? status}) {
    return Visitor(
      id: id,
      name: name,
      residentName: residentName,
      visitDate: visitDate,
      visitPurpose: visitPurpose,
      status: status ?? this.status,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      residence: residence,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
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
  // final int id;
  final String name;
  final DateTime visitDate;
  final String visitPurpose;

  VisitorDTO(
      {
      // required this.id,
      required this.name,
      required this.visitDate,
      required this.visitPurpose});

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
