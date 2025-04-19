

import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/config/host.dart';

class ApplicationApiService extends TokenService {
  ApplicationApiService({required super.storage, required super.client});
  static const String baseUrl = '${appURL}patients/';



  Future<PaginatedResults<PatientProfile>> getProfiles({int page = 1,  String query = "", String status = "",String gender=""}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page&q=$query&verification_status=$status&gender=$gender'),
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
      throw Exception('Failed to get profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get profile: $e');
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
      throw Exception('Failed to get pending profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get pending profile: $e');
    }
  }

  Future<PaginatedResults<PatientProfile>> getUnverifiedApplications() async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('${baseUrl}unverified/'),
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
      throw Exception('Failed to get profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<void> verifyProfile({ required PatientProfile profile}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.post(
        Uri.parse('$baseUrl${profile.id}/verify/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to create visit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create visit: $e');
    }
  }

  Future<void> rejectProfile({ required PatientProfile profile}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.post(
        Uri.parse('$baseUrl${profile.id}/reject/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to create visit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create visit: $e');
    }
  }

  Future<void> resetProfile({ required PatientProfile profile}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.post(
        Uri.parse('$baseUrl${profile.id}/reset_verification/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to create visit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create visit: $e');
    }
  }

  Future<PatientProfile> updateApplication({required PatientProfile profile}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(profile.toJson());
      final response = await client.put(
        Uri.parse('$baseUrl${profile.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PatientProfile.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
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