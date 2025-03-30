
import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Resident/Data/Model/resident.model.dart';
import 'package:online_reservation/config/host.dart';

class ResidentApiService extends TokenService{
  static const String baseUrl = '${appURL}residences/';

  ResidentApiService({required super.storage, required super.client});

  Future<PaginatedResults<Resident>> getResidents({int page = 1}) async {

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
        return PaginatedResults<Resident>.fromJson(
          jsonDecode(response.body),
              (json) => Resident.fromJson(json),
        );
      }
      throw Exception('Failed to get issues: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get issues: $e');
    }
  }

  Future<Resident> getResident(int id) async {
    try{
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
      throw Exception('Failed to get issues: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get issues: $e');
    }
  }

}