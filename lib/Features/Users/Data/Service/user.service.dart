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

  Future<PaginatedResults<User>> getUsers({int page = 1, String query = ""}) async {
    // final pageURL =
    try{
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page&q=$query'),
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
      throw Exception('Failed to get users: ${response.statusCode}');
    }catch(e){
      throw Exception('Failed to get users: $e');
    }
  }

  Future<User> getUserInfo() async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('${authURL}info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get user info: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  Future<User> updatePermission({required User user}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(user.toJson());
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
      throw Exception('Failed to update user: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('${authURL}delete/$userId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 204) {
        // 201 Created
        return true;
      }
    } catch (e) {
      throw Exception('Failed to delete visit: $e');
    }
    return false;
  }

  Future<User> updateUser({required User user}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(user.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${user.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update user: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<User> updateUserRole({required User user}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.post(
        Uri.parse('$baseUrl${user.id}/set_group/'),
        body: {
          'group': '${user.group}'
        },
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update user role: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }
}