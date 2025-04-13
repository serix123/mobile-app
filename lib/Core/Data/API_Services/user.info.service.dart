

import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/user.info.model.dart';
import 'package:online_reservation/config/host.dart';

class UserInfoApiService extends TokenService
{
  static const String baseUrl = '${authURL}users-list/me/';

  UserInfoApiService({required super.storage, required super.client});


  Future<User> getUserInfo() async  {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to retrieve user information: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to retrieve user information: $e');
    }

  }


}