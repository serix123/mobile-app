// models/user.dart
class User {

  static const String RESIDENT = "Resident";
  static const String GUARD = "Guard";
  static const String OFFICER = "Officer";

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? group;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.group,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? firstGroup;
    if (json['groups'] is List && (json['groups'] as List).isNotEmpty) {
      firstGroup = (json['groups'] as List<dynamic>)[0].toString();
    }
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
        group: firstGroup ?? RESIDENT,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  String get fullName => '$firstName $lastName';
  // String get role {
  //   if (isSuperuser) return 'Super Admin';
  //   if (isStaff) return 'Staff';
  //   return 'Regular User';
  // }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? group,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      group: group ?? this.group,
    );
  }
}

