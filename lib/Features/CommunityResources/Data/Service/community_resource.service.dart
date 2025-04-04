import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/CommunityResources/Data/Model/community_resources.model.dart';
import 'package:online_reservation/config/host.dart';

class ResourceApiService extends TokenService {
  ResourceApiService({required super.storage, required super.client});

  static const String baseUrl = '${appURL}resources/';

  Future<PaginatedResults<Resource>> getResources({int page = 1,  String query = "",}) async {
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
        return PaginatedResults<Resource>.fromJson(
          jsonDecode(response.body),
              (json) => Resource.fromJson(json),
        );
      }
      throw Exception('Failed to get resources: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get resources: $e');
    }
  }

  Future<Resource> getResource(int id) async {
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
        return Resource.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get resources: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get resources: $e');
    }
  }

  Future<Resource> createResource({required Resource resource}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(resource.toJson());
      final response = await client.post(
        Uri.parse(baseUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        return Resource.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create resource: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create resource: $e');
    }
  }

  Future<Resource> updateResource({required Resource resource}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(resource.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${resource.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Resource.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update resource: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update resource: $e');
    }
  }

  Future<bool> deleteResource(int id) async {
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
      throw Exception('Failed to delete resource: $e');
    }
    return false;
  }
  
  
}
