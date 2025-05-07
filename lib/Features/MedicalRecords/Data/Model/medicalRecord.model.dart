
import 'package:flutter/material.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart' show PatientProfile;

enum DiagnosisStatus {
  GEN,
  CHR,
  ACS,
  INJ,
  PRV,
  OTH,
}

extension DiagnosisStatusExtension on DiagnosisStatus {
  String get displayName {
    switch (this) {
      case DiagnosisStatus.GEN:
        return 'General Checkup';
      case DiagnosisStatus.CHR:
        return 'Chronic Condition';
      case DiagnosisStatus.ACS:
        return 'Acute Syndrome';
      case DiagnosisStatus.INJ:
        return 'Injury';
      case DiagnosisStatus.PRV:
        return 'Preventive Care';
      case DiagnosisStatus.OTH:
        return 'Other';
    }
  }

  String get jsonName{
    switch (this) {
      case DiagnosisStatus.GEN:
        return 'GEN';
      case DiagnosisStatus.CHR:
        return 'CHR';
      case DiagnosisStatus.ACS:
        return 'ACS';
      case DiagnosisStatus.INJ:
        return 'INJ';
      case DiagnosisStatus.PRV:
        return 'PRV';
      case DiagnosisStatus.OTH:
        return 'OTH';
    }
  }

  Color get color {
    switch (this) {
      case DiagnosisStatus.GEN:
        return Colors.lightBlueAccent;
      case DiagnosisStatus.CHR:
        return Colors.green;
      case DiagnosisStatus.ACS:
        return Colors.red;
      case DiagnosisStatus.INJ:
        return Colors.orangeAccent;
      case DiagnosisStatus.PRV:
        return Colors.lightGreen;
      case DiagnosisStatus.OTH:
        return Colors.grey;
    }
  }
}

class MedicalRecord {
  final int id;
  final int patient;
  final PatientProfile patientDetails;
  final DateTime visitDate;
  final DiagnosisStatus diagnosisCategory;
  final String? diagnosisDetails;
  final String? treatment;
  final int? attendingDoctor;
  final String? doctorName;
  final String? notes;
  final DateTime? followUpDate;

  MedicalRecord({
    required this.id,
    required this.patient,
    required this.patientDetails,
    required this.visitDate,
    required this.diagnosisCategory,
    this.diagnosisDetails,
    this.treatment,
    this.attendingDoctor,
    this.doctorName,
    this.notes,
    this.followUpDate,
  });

  MedicalRecord copyWith({
    int? id,
    int? patient,
    PatientProfile? patientDetails,
    DateTime? visitDate,
    DiagnosisStatus? diagnosisCategory,
    String? diagnosisDetails,
    String? treatment,
    int? attendingDoctor,
    String? doctorName,
    String? notes,
    DateTime? followUpDate,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      patientDetails: patientDetails ?? this.patientDetails,
      visitDate: visitDate ?? this.visitDate,
      diagnosisCategory: diagnosisCategory ?? this.diagnosisCategory,
      diagnosisDetails: diagnosisDetails ?? this.diagnosisDetails,
      treatment: treatment ?? this.treatment,
      attendingDoctor: attendingDoctor ?? this.attendingDoctor,
      doctorName: doctorName ?? this.doctorName,
      notes: notes ?? this.notes,
      followUpDate: followUpDate ?? this.followUpDate,
    );
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      patient: json['patient'],
      patientDetails: PatientProfile.fromJson(json['patient_details']),
      visitDate: DateTime.parse(json['visit_date']),
      diagnosisCategory: _parseDiagnosis(json['diagnosis_category']),
      diagnosisDetails: json['diagnosis_details'],
      treatment: json['treatment'],
      attendingDoctor: json['attending_doctor'],
      doctorName: json['doctor_name'],
      notes: json['notes'],
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'patient': patient,
      // 'patient_details': patientDetails.toJson(),
      // 'visit_date': visitDate.toIso8601String(),
      'diagnosis_category': diagnosisCategory.jsonName,
      'diagnosis_details': diagnosisDetails,
      'treatment': treatment,
      'attending_doctor': attendingDoctor,
      // 'doctor_name': doctorName,
      'notes': notes,
      'follow_up_date': followUpDate?.toIso8601String(),
    };
  }

  static DiagnosisStatus _parseDiagnosis(String status) {
    switch (status) {
      case 'GEN':
        return DiagnosisStatus.GEN;
      case 'CHR':
        return DiagnosisStatus.CHR;
      case 'ACS':
        return DiagnosisStatus.ACS;
      case 'INJ':
        return DiagnosisStatus.INJ;
      case 'PRV':
        return DiagnosisStatus.PRV;
      case 'OTH':
        return DiagnosisStatus.OTH;
      default:
        return DiagnosisStatus.OTH;
    }
  }
}
