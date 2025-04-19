import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Features/Authentication/Data/Model/auth.model.dart';
import 'package:online_reservation/config/host.dart';

class AuthService extends TokenService {

  // final http.Client client = http.Client();
  // final FlutterSecureStorage storage = const FlutterSecureStorage();

  // final http.Client client;
  // final FlutterSecureStorage storage;
  // AuthService({
  //   required this.storage,
  //   required this.client});
  AuthService({
    required super.storage,
    required super.client});

  Future<bool> login(UserUpdateDetails credentials) async {
    try {
      final response = await client.post(
        Uri.parse('${authURL}token/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(credentials.toJson()),
      );
      if (response.statusCode == 200) {
        var token = TokenResponse.fromJson(jsonDecode(response.body));
        await storage.write(key: "access", value: token.accessToken);
        await storage.write(key: "refresh", value: token.refreshToken);
        return true;
        // return TokenResponse.fromJson(response.body);
      } else {
        print('Failed to authenticate: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception when calling authenticate: $e');
      return false;
    }
  }

  Future<bool> update(UserUpdateDetails updateDetails) async {
    try {
      String? token = await storage.read(key: "access");
      final response = await client.patch(
        Uri.parse('${authURL}update/${updateDetails.id}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateDetails.toJson()),
      );
      if (response.statusCode == 200) {
        return true;
        // return TokenResponse.fromJson(response.body);
      } else {
        print('Failed to authenticate: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception when calling authenticate: $e');
      return false;
    }
  }

  Future<bool> register(RegistrationCredentials credentials) async {
    try {
      final response = await client.post(
        Uri.parse('${authURL}register/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'first_name': credentials.first_name,
          'last_name': credentials.last_name,
          'email': credentials.email,
          'password': credentials.password,
          'password2': credentials.password2,
        }),
      );

      if (response.statusCode == 201) {
        // Assuming the API returns a token upon successful registration
        // final data = jsonDecode(response.body);
        // await storage.write(key: 'token', value: data['token']);
        print("registration success!");
        return true;
      } else {
        // Handle different status codes appropriately
        print('Failed to register: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception when calling API: $e');
      return false;
    }
  }

  // Future<String?> getAccessToken() async {
  //   return await storage.read(key: "access");
  // }
  //
  // Future<String?> getRefreshToken() async {
  //   return await storage.read(key: "refresh");
  // }
  //
  Future<bool> refreshToken() async {
    return await super.refreshAccessToken(storage, client);
  }

  Future<bool> getAccToken() async {
    var token = await super.getAccessToken(storage);
    // Assume a simple validation check or prepare for a token validation API call
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");
  }
}
