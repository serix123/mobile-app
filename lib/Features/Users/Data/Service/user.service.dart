

import 'dart:convert';
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Users/Data/Model/user.model.dart';
import 'package:online_reservation/config/host.dart';

class UserApiService extends TokenService{

  static const String baseUrl = '${authURL}users/';

  UserApiService({
    required super.storage,
    required super.client,
  });

  Future<PaginatedResults<User>> getUsers({int page = 1}) async {
    // final pageURL =
    try{
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<User>.fromJson(
          jsonDecode(response.body),
              (json) => User.fromJson(json),
        );
      }
      throw Exception('Failed to get issues: ${response.statusCode}');
    }catch(e){
      throw Exception('Failed to get issues: $e');
    }
  }

  Future<User> updatePermission({required User user}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(user.permissionToJson());
      final response = await client.patch(
        Uri.parse('${authURL}admin/users/${user.id}/permissions/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update issue: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update issue: $e');
    }
  }
}