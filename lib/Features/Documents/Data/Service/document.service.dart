import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Documents/Data/Model/document.model.dart';
import 'package:online_reservation/config/host.dart';

class DocumentApiService extends TokenService{
  static const String baseUrl = '${appURL}documents/';
  DocumentApiService({required super.storage, required super.client});


  Future<PaginatedResults<Document>> getDocuments({int page = 1, String query = ""}) async {
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
        return PaginatedResults<Document>.fromJson(
          jsonDecode(response.body),
              (json) => Document.fromJson(json),
        );
      }
      throw Exception('Failed to get documents: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }

  Future<Document> createDocument({required Document document}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(document.toJson());
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
        return Document.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create document: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  Future<Document> updateDocument({required Document document}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(document.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${document.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Document.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update document: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<bool> deleteDocument(int documentId) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$baseUrl$documentId/'),
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
      throw Exception('Failed to delete event: $e');
    }
    return false;
  }

  Future<void> uploadFileAdaptive(
      int documentId, PlatformFile file, bool isWeb) async {
    try {
      String? token = await getAccessToken(storage);
      if (token == null) throw Exception("Invalid Access not found.");
      // Create a multipart request
      var request = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl$documentId/upload_id_document/'));

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
      throw Exception('Failed to update document image: $e');
    }
  }

}