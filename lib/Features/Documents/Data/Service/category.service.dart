import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Documents/Data/Model/category.model.dart';
import 'package:online_reservation/config/host.dart';

class CategoryApiService extends TokenService{
  static const String baseUrl = '${appURL}categories/';
  CategoryApiService({required super.storage, required super.client});


  Future<PaginatedResults<Category>> getCategories({int page = 1, String query = ""}) async {
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
        return PaginatedResults<Category>.fromJson(
          jsonDecode(response.body),
              (json) => Category.fromJson(json),
        );
      }
      throw Exception('Failed to get categorys: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get categorys: $e');
    }
  }

  Future<Category> createCategory({required Category category}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(category.toJson());
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
        return Category.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create category: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Category> updateCategory({required Category category}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(category.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${category.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update category: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

}