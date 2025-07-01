// models/resident.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Utils/utils.dart';

enum RoleType { GUARD, OFFICER, RESIDENT, ALL }
extension RoleTypeExtension on RoleType {
  String get displayName {
    switch (this) {
      case RoleType.GUARD:
        return 'Guard';
      case RoleType.OFFICER:
        return 'Officer';
      case RoleType.RESIDENT:
        return 'Resident';
      case RoleType.ALL:
        return 'All';
    }
  }

  IconData get icon {
    switch (this) {
      case RoleType.GUARD:
        return Icons.security;
      case RoleType.OFFICER:
        return Icons.badge;
      case RoleType.RESIDENT:
        return Icons.person;
      case RoleType.ALL:
        return Icons.people;
    }
  }
}

class Resident {
  final int id;
  final String userEmail;
  final String firstName;
  final String lastName;
  final String role;
  final String? contactNumber;
  final String? address;
  final DateTime registrationDate;

  Resident({
    required this.id,
    required this.userEmail,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.contactNumber,
    this.address,
    required this.registrationDate,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['id'] as int,
      userEmail: json['user_email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      contactNumber: json['contact_number'] as String?,
      address: json['address'] as String?,
      registrationDate: Utils.parseAndRoundToQuarter(json['registration_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'user_email': userEmail,
      // 'first_name': firstName,
      // 'last_name': lastName,
      'role': role,
      'contact_number': contactNumber,
      'address': address,
      // 'registration_date': registrationDate,
    };
  }

  Resident copyWith(Resident resident) {
    return Resident(
      id: id,
      userEmail: resident.userEmail,
      firstName: resident.firstName,
      lastName: resident.lastName,
      role: resident.role,
      contactNumber:  resident.contactNumber,
      address: resident.address,
      registrationDate: resident.registrationDate,
    );
  }

  String get fullName => '$firstName $lastName';
  String get formattedContact => contactNumber?.isEmpty ?? true
      ? 'N/A'
      : contactNumber!;
  String get formattedAddress => address?.isEmpty ?? true
      ? 'No address provided'
      : address!;
  String get formattedRegistrationDate =>
      DateFormat.yMMMd().format(registrationDate);


}