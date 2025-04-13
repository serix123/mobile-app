import 'package:flutter/material.dart';

enum ApplicationStatus { PENDING, APPROVED, REJECTED }

extension ResourceTypeExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.PENDING:
        return 'pending';
      case ApplicationStatus.APPROVED:
        return 'approved';
      case ApplicationStatus.REJECTED:
        return 'rejected';
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationStatus.PENDING:
        return Icons.access_time_filled;
      case ApplicationStatus.APPROVED:
        return Icons.check_circle;
      case ApplicationStatus.REJECTED:
        return Icons.not_interested;
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.PENDING:
        return Colors.orange;
      case ApplicationStatus.APPROVED:
        return Colors.green;
      case ApplicationStatus.REJECTED:
        return Colors.red;
    }
  }
}

class PatientProfile {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final DateTime dateOfBirth;
  final String address;
  final String village;
  final IdProof idProof;
  final String medicalHistory;
  final ApplicationStatus? status;

  PatientProfile({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    required this.dateOfBirth,
    required this.address,
    required this.village,
    required this.idProof,
    required this.medicalHistory,
    this.status,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      address: json['address'] as String,
      village: json['village'] as String,
      idProof: IdProof.fromJson(json['id_proof']),
      medicalHistory: json['medical_history'] as String,
      status: json['status'] != null ? _parseApplicationStatus(json['status']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'address': address,
      'village': village,
      'id_proof': idProof.toJson(),
      'medical_history': medicalHistory,
    };
  }

  PatientProfile copyWith(PatientProfile application) {
    return application;
  }

  static ApplicationStatus _parseApplicationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.PENDING;
      case 'approved':
        return ApplicationStatus.APPROVED;
      case 'rejected':
        return ApplicationStatus.REJECTED;
      default:
        return ApplicationStatus.PENDING;
    }
  }
}

class IdProof {
  final String filename;
  final String base64Data;

  IdProof({
    required this.filename,
    required this.base64Data,
  });

  factory IdProof.fromJson(Map<String, dynamic> json) {
    return IdProof(
      filename: json['filename'] as String,
      base64Data: json['data'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'data': base64Data,
    };
  }
}
