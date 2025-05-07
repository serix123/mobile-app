import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';
import 'package:online_reservation/config/host.dart';

class ApplicationApiService extends TokenService {
  ApplicationApiService({required super.storage, required super.client});
  static const String baseUrl = '${appURL}patients/';

  Future<PaginatedResults<PatientProfile>> getProfiles(
      {int page = 1,
      String query = "",
      String status = "",
      String gender = ""}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse(
            '$baseUrl?page=$page&q=$query&verification_status=$status&gender=$gender'),
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

  Future<PatientProfile> getProfile(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse(
            '$baseUrl$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PatientProfile.fromJson(jsonDecode(response.body));
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

  Future<void> verifyProfile(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.post(
        Uri.parse('$baseUrl$id/verify/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to verify application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to verify application: $e');
    }
  }

  Future<void> rejectProfile(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.post(
        Uri.parse('$baseUrl$id/reject/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to reject application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to reject application: $e');
    }
  }

  Future<void> resetProfile(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.post(
        Uri.parse('$baseUrl$id/reset_verification/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to reset application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to reset application: $e');
    }
  }

  Future<PatientProfile> updateApplication(
      {required PatientProfile profile}) async {
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
      // final responseBody = response.body;
      // print('Response body: $responseBody');
      throw Exception('Failed to update profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> uploadFile(int profileId, PlatformFile file) async {
    try {
      String? token = await getAccessToken(storage);
      if (token == null) throw Exception("Invalid Access not found.");
      // Create a multipart request
      var request = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl/$profileId/upload_id_document/'));

      // Attach file
      request.files.add(
        await http.MultipartFile.fromPath(
          'id_document', // field name for the file
          file.path!,
          filename: file.name, // optional, defaults to basename
        ),
      );

      // Add any other fields if needed
      // request.fields['description'] = 'File upload test';

      // Optionally set headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        // print('Upload successful');
        // Optionally read response body
        // final responseBody = await response.stream.bytesToString();
        // print('Response body: $responseBody');
      } else {
        // print('Upload failed with status: ${response.statusCode}');
        throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> uploadFileAdaptive(
      int profileId, PlatformFile file, bool isWeb) async {
    try {
      String? token = await getAccessToken(storage);
      if (token == null) throw Exception("Invalid Access not found.");
      // Create a multipart request
      var request = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl$profileId/upload_id_document/'));

      if (isWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'id_document', // field name for the file
            file.bytes!,
            filename: file.name, // optional, defaults to basename
          ),
        );
      } else {
        // Attach file
        request.files.add(
          await http.MultipartFile.fromPath(
            'id_document', // field name for the file
            file.path!,
            filename: file.name, // optional, defaults to basename
          ),
        );
      }

      // Add any other fields if needed
      // request.fields['description'] = 'File upload test';

      // Optionally set headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        // print('Upload successful');
        // Optionally read response body
        // final responseBody = await response.stream.bytesToString();
        // print('Response body: $responseBody');
      } else {
        // print('Upload failed with status: ${response.statusCode}');
        throw Exception(response.statusCode);
      }
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
