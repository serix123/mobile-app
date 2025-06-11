// services/issue_api_service.dart
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.model.dart';
import 'package:online_reservation/config/host.dart';

class IssueApiService extends TokenService {
  static const String baseUrl = '${appURL}issues/';

  IssueApiService({
    required super.storage,
    required super.client,
  });

  Future<Issue> createIssue({required Issue issue}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(issue.toJson());
      final response = await client.post(
        Uri.parse(baseUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        print(response.body);
        return Issue.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create issue: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create issue: $e');
    }
  }

  Future<Issue> updateIssue({required Issue issue}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(issue.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${issue.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Issue.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update issue: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update issue: $e');
    }
  }

  Future<PaginatedResults<Issue>> getIssues({int page = 1, String query = "",String status = "",String priority = "",}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page&q=$query&status=$status&priority=$priority'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Issue>.fromJson(
          jsonDecode(response.body),
          (json) => Issue.fromJson(json),
        );
      }
      throw Exception('Failed to get issues: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get issues: $e');
    }
  }

  Future<bool> deleteIssue(int issueId) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$baseUrl$issueId/'),
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
      throw Exception('Failed to delete issue: $e');
    }
    return false;
  }

  Future<bool> resolveIssue(int issueId) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.post(
        Uri.parse('$baseUrl$issueId/resolve/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        // 201 Created
        return true;
      }
    } catch (e) {
      throw Exception('Failed to resolve issue: $e');
    }
    return false;
  }

  Future<void> uploadFileAdaptive(
      int issueId, PlatformFile file, bool isWeb) async {
    try {
      String? token = await getAccessToken(storage);
      if (token == null) throw Exception("Invalid Access not found.");
      // Create a multipart request
      var request = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl$issueId/upload/'));

      if (isWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image', // field name for the file
            file.bytes!,
            filename: file.name, // optional, defaults to basename
          ),
        );
      } else {
        // Attach file
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // field name for the file
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
      throw Exception('Failed to update issue image: $e');
    }
  }
}
