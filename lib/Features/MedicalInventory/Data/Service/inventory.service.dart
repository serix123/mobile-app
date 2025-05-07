import 'dart:convert';
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/inventory.model.dart';
import 'package:online_reservation/config/host.dart';

class InventoryApiService extends TokenService {
  InventoryApiService({required super.storage, required super.client});
  static const String baseUrl = '${appURL}inventory/';

  Future<PaginatedResults<Medicine>> getMedicines(
      {int page = 1, String query = ""}) async {
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
        return PaginatedResults<Medicine>.fromJson(
          jsonDecode(response.body),
          (json) => Medicine.fromJson(json),
        );
      }
      throw Exception('Failed to get records: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get records: $e');
    }
  }

  Future<PaginatedResults<Supplier>> getSuppliers(
      {int page = 1, String query = ""}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('${baseUrl}supplier/?page=$page&q=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Supplier>.fromJson(
          jsonDecode(response.body),
          (json) => Supplier.fromJson(json),
        );
      }
      throw Exception('Failed to get supplier: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get supplier: $e');
    }
  }

  Future<PaginatedResults<Category>> getCategories(
      {int page = 1, String query = ""}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('${baseUrl}category/?page=$page&q=$query'),
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
      throw Exception('Failed to get category: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }
}
