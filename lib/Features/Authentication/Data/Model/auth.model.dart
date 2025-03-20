
class UserCredentials {

  String email;
  String password;
  UserCredentials({required this.email, required this.password});

  Map<String, String> toJson() => {
    'email': email,
    'password': password,
  };
}
class UserUpdateDetails {

  int? id;
  String? email;
  String? password;
  String? first_name;
  String? last_name;
  UserUpdateDetails({this.id,this.email, this.password, this.first_name, this.last_name});

  Map<String, String> toJson() {
    final Map<String, String> data = {};

    if (email != null) {
      data['email'] = email!;
    }
    if (password != null) {
      data['password'] = password!;
    }
    if (first_name != null) {
      data['first_name'] = first_name!;
    }
    if (last_name != null) {
      data['last_name'] = last_name!;
    }

    return data;
  }
}
class RegistrationCredentials {

  String first_name;
  String last_name;
  String email;
  String? password;
  String? password2;
  RegistrationCredentials({
    required this.first_name,
    required this.last_name,
    required this.email,
    this.password,
    this.password2,
  });

  Map<String, dynamic> toJson() => {
    'first_name': first_name,
    'last_name': last_name,
    'email': email,
    'password': password,
    'password2': password2,
  };
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access'],
      refreshToken: json['refresh'],
    );
  }
}