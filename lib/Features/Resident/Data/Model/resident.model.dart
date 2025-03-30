// models/resident.dart
import 'package:intl/intl.dart';

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
      registrationDate: DateTime.parse(json['registration_date'] as String),
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