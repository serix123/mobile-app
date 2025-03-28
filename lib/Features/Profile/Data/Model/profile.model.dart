// models/user.dart
class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isSuperuser;
  final Residence? residence;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isSuperuser,
    this.residence,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      isStaff: json['is_staff'] as bool,
      isSuperuser: json['is_superuser'] as bool,
      residence: Residence.fromJson(json['residence'] as Map<String, dynamic>),
    );
  }

  String get fullName => '$firstName $lastName';
  String get role => residence?.role ?? "Resident";
}

class Residence {
  final int id;
  final String userEmail;
  final String firstName;
  final String lastName;
  final String role;
  final String? contactNumber;
  final String? address;
  final DateTime registrationDate;

  Residence({
    required this.id,
    required this.userEmail,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.contactNumber,
    this.address,
    required this.registrationDate,
  });

  factory Residence.fromJson(Map<String, dynamic> json) {
    return Residence(
      id: json['id'] as int,
      userEmail: json['user_email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      contactNumber: json['contact_number']?.toString(),
      address: json['address']?.toString(),
      registrationDate: DateTime.parse(json['registration_date'] as String),
    );
  }

  String get fullAddress => address ?? '';
  String get formattedContact => contactNumber ?? '';
}