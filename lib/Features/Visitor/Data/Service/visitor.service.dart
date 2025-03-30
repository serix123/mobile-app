import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/config/host.dart';
import 'package:online_reservation/Features/Visitor/Data/Model/visitor.model.dart';

class VisitApiService extends TokenService {
  static const baseUrl = '${appURL}visitors/';

  // final http.Client client = http.Client();
  // final FlutterSecureStorage storage = const FlutterSecureStorage();

  // final http.Client client;
  // final FlutterSecureStorage storage;
  // VisitApiService({required this.storage, required this.client});

  VisitApiService({required super.storage, required super.client});

  Future<PaginatedResults<Visitor>> getVisitors({int page = 1}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Visitor>.fromJson(
          jsonDecode(response.body),
              (json) => Visitor.fromJson(json),
        );
      }
      throw Exception('Failed to load visits');
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<VisitorDTO> createVisitor(VisitorDTO visitor) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(visitor.toJson());
      final response = await client.post(
        Uri.parse(baseUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        // 201 Created
        return VisitorDTO.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create visit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create visit: $e');
    }
  }

  Future<VisitorDTO> updateVisitor(VisitorDTO visitor) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(visitor.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${visitor.id!}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        // 201 Created
        return VisitorDTO.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create visit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create visit: $e');
    }
  }

  Future<bool> deleteVisitor(int visitId) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$baseUrl$visitId/'),
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
}
