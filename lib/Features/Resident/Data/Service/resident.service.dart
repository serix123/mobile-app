import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/config/host.dart';

class ResidentApiService extends TokenService {
  static const String baseUrl = '${appURL}residences/';

  ResidentApiService({required super.storage, required super.client});

  Future<PaginatedResults<Resident>> getResidents(
      {int page = 1, String query = "", RoleType role = RoleType.RESIDENT}) async {
    final String roleQuery;

    switch (role) {
      case RoleType.GUARD:
        roleQuery = "Guard";
        break;
      case RoleType.OFFICER:
        roleQuery = "Officer";
        break;
      case RoleType.RESIDENT:
        roleQuery = "Resident";
        break;
      case RoleType.ALL:
        roleQuery = "";
        break;
    }

    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page&q=$query&role=$roleQuery'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Resident>.fromJson(
          jsonDecode(response.body),
          (json) => Resident.fromJson(json),
        );
      }
      throw Exception('Failed to get residents: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get residents: $e');
    }
  }

  Future<Resident> getResident(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Resident.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get resident: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get resident: $e');
    }
  }

  Future<Resident> updateResident({required Resident resident}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(resident.toJson());
      print(body);
      final response = await client.patch(
        Uri.parse('$baseUrl${resident.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Resident.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update resident: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update resident: $e');
    }
  }
}
