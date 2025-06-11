import 'dart:convert';
import 'package:online_reservation/config/host.dart';
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Features/Profile/Data/Model/profile.model.dart';

class ProfileApiService extends TokenService {
  static const String baseUrl = '${appURL}residences/profile/';

  ProfileApiService({
    required super.storage,
    required super.client,
  });

  Future<UserProfile?> getProfile() async  {
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
        return UserProfile.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
}