

import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/config/host.dart';

class ApplicationApiService extends TokenService {
  ApplicationApiService({required super.storage, required super.client});
  static const String baseUrl = '${appURL}applications/';


  Future<PatientProfile> createApplication({required PatientProfile application}) async {
    try{
      String? token = await getAccessToken(storage);

      final body = json.encode(application.toJson());
      final response = await client.post(
        Uri.parse(baseUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        return PatientProfile.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create application: ${response.statusCode}');
    }catch(e){
    throw Exception('Failed to create application: $e');
    }
  }

  Future<PaginatedResults<PatientProfile>> getApplications({int page = 1,  String query = "", String status = "",}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page&q=$query&status=$status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<PatientProfile>.fromJson(
          jsonDecode(response.body),
              (json) => PatientProfile.fromJson(json),
        );
      }
      throw Exception('Failed to get applications: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get applications: $e');
    }
  }

  Future<PaginatedResults<PatientProfile>> getPendingApplications() async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('${baseUrl}pending/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<PatientProfile>.fromJson(
          jsonDecode(response.body),
              (json) => PatientProfile.fromJson(json),
        );
      }
      throw Exception('Failed to get applications: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get applications: $e');
    }
  }

  Future<PatientProfile> getApplication(int id) async {
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
        return PatientProfile.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get applications: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get applications: $e');
    }
  }

  Future<PatientProfile> updateApplication({required PatientProfile application}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(application.toJson());
      final response = await client.put(
        Uri.parse('$baseUrl${application.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PatientProfile.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update application: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update application: $e');
    }
  }

  Future<bool> deleteApplication(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$baseUrl$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 204) {
        return true;
      }
    } catch (e) {
      throw Exception('Failed to delete application: $e');
    }
    return false;
  }



}