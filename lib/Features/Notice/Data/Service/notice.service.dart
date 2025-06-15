import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/config/host.dart';
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Notice/Data/Model/notice.model.dart';

class NoticeApiService extends TokenService{
  static const String baseUrl = '${appURL}notices/';
  NoticeApiService({required super.storage, required super.client});

  Future<Notice> createNotice({required Notice notice}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(notice.toJson());
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
        return Notice.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create notice: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create notice: $e');
    }
  }

  Future<Notice> updateNotice({required Notice notice}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(notice.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${notice.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Notice.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update notice: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update notice: $e');
    }
  }

  Future<PaginatedResults<Notice>> getNotices({int page = 1, String query = ""}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page&q=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Notice>.fromJson(
          jsonDecode(response.body),
              (json) => Notice.fromJson(json),
        );
      }
      throw Exception('Failed to get notices: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get notices: $e');
    }
  }

  Future<bool> deleteNotice(int noticeId) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$baseUrl$noticeId/'),
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
      throw Exception('Failed to delete notice: $e');
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