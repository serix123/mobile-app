import 'package:flutter/material.dart';

enum ApplicationStatus { PENDING, VERIFIED, UNVERIFIED, REJECTED }

extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.PENDING:
        return 'pending';
      case ApplicationStatus.VERIFIED:
        return 'verified';
      case ApplicationStatus.UNVERIFIED:
        return 'unverified';
      case ApplicationStatus.REJECTED:
        return 'rejected';
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationStatus.PENDING:
        return Icons.access_time_filled;
      case ApplicationStatus.VERIFIED:
        return Icons.check_circle;
      case ApplicationStatus.REJECTED:
        return Icons.not_interested;
      case ApplicationStatus.UNVERIFIED:
        return Icons.do_not_disturb_on_total_silence;
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.PENDING:
        return Colors.orange;
      case ApplicationStatus.VERIFIED:
        return Colors.green;
      case ApplicationStatus.REJECTED:
        return Colors.red;
      case ApplicationStatus.UNVERIFIED:
        return Colors.grey;
    }
  }
}

enum Gender {MALE, FEMALE, OTHER}

extension GenderExtension on Gender{
  String get displayName {
    switch (this) {
      case Gender.MALE:
        return 'male';
      case Gender.FEMALE:
        return 'female';
      case Gender.OTHER:
        return 'other';
    }
  }

  IconData get icon {
    switch (this) {
      case Gender.MALE:
        return Icons.male;
      case Gender.FEMALE:
        return Icons.female;
      case Gender.OTHER:
        return Icons.circle;
    }
  }

  Color get color {
    switch (this) {
      case Gender.MALE:
        return Colors.blueAccent;
      case Gender.FEMALE:
        return Colors.pinkAccent;
      case Gender.OTHER:
        return Colors.grey;
    }
  }
}

class PatientProfile {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final DateTime? dob;
  final Gender? gender;
  final String? contactNumber;
  final String? address;
  final ApplicationStatus? verificationStatus;
  final String? idDocument;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PatientProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.dob,
    this.gender,
    this.contactNumber,
    this.address,
    this.verificationStatus,
    this.idDocument,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) => PatientProfile(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      email: json["email"],
      dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
      gender: _parseGender(json["gender"]),
      contactNumber: json["contact_number"],
      address: json["address"],
      verificationStatus: _parseVerificationStatus(json["verification_status"]),
      idDocument: json["id_document"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );

  Map<String, dynamic> toJson() => {
    // "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "dob": dob?.toIso8601String(),
    "gender": gender,
    "contact_number": contactNumber,
    "address": address,
    // "verification_status": verificationStatus,
    // "id_document": idDocument,
    // "created_at": createdAt.toIso8601String(),
    // "updated_at": updatedAt.toIso8601String(),
  };

  PatientProfile copyWith(PatientProfile application) {
    return application;
  }

  static ApplicationStatus _parseVerificationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.PENDING;
      case 'verified':
        return ApplicationStatus.VERIFIED;
      case 'rejected':
        return ApplicationStatus.REJECTED;
      case 'unverified':
        return ApplicationStatus.UNVERIFIED;
      default:
        return ApplicationStatus.UNVERIFIED;
    }
  }

  static Gender _parseGender(String status) {
    switch (status.toLowerCase()) {
      case 'male':
        return Gender.MALE;
      case 'female':
        return Gender.FEMALE;
      case 'other':
        return Gender.OTHER;
      default:
        return Gender.OTHER;
    }
  }

  String get fullName => "${this.firstName} ${this.lastName}";
}


