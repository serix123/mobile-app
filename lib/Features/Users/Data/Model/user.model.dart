// models/user.dart
class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isSuperuser;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isSuperuser,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      isStaff: json['is_staff'] as bool,
      isSuperuser: json['is_superuser'] as bool,
    );
  }

  Map<String, dynamic> permissionToJson() {
    return {
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
    };
  }

  String get fullName => '$firstName $lastName';
  String get role {
    if (isSuperuser) return 'Super Admin';
    if (isStaff) return 'Staff';
    return 'Regular User';
  }
}

