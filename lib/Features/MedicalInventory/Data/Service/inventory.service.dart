import 'dart:convert';
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/category.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/inventory.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/supplier.model.dart';
import 'package:online_reservation/config/host.dart';

class InventoryApiService extends TokenService {
  InventoryApiService({required super.storage, required super.client});
  static const String baseUrl = '${appURL}inventory/';
  static const String categoryUrl = '${baseUrl}category/';
  static const String supplierUrl = '${baseUrl}supplier/';

  // Inventory Service
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
      throw Exception('Failed to get items: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get items: $e');
    }
  }

  Future<Medicine> getMedicine(int id) async {
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
        return Medicine.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get record: $e');
    }
  }

  Future<Medicine> createMedicine({required Medicine medicine}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(medicine.toJson());
      final response = await client.post(
        Uri.parse(baseUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        return Medicine.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create medicine: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create medicine: ${e.toString()}');
    }
  }

  Future<Medicine> updateMedicine(
      {required Medicine medicine}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(medicine.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${medicine.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Medicine.fromJson(jsonDecode(response.body));
      }
      // final responseBody = response.body;
      // print('Response body: $responseBody');
      throw Exception('Failed to update record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update record: $e');
    }
  }

  Future<bool> deleteMedicine(int id) async {
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
        // 201 Created
        return true;
      }
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
    return false;
  }


  // Supplier Service
  Future<PaginatedResults<Supplier>> getSuppliers(
      {int page = 1, String query = ""}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('${supplierUrl}?page=$page&q=$query'),
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

  Future<Supplier> getSupplier(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse(
            '$categoryUrl$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Supplier.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get record: $e');
    }
  }

  Future<Supplier> createSupplier({required Supplier supplier}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(supplier.toJson());
      final response = await client.post(
        Uri.parse(supplierUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        return Supplier.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create supplier: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create supplier: ${e.toString()}');
    }
  }

  Future<Supplier> updateSupplier(
      {required Supplier supplier}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(supplier.toJson());
      final response = await client.patch(
        Uri.parse('$supplierUrl${supplier.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Supplier.fromJson(jsonDecode(response.body));
      }
      // final responseBody = response.body;
      // print('Response body: $responseBody');
      throw Exception('Failed to update record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update record: $e');
    }
  }

  Future<bool> deleteSupplier(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$supplierUrl$id/'),
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
      throw Exception('Failed to delete supplier: $e');
    }
    return false;
  }


  // Category Service
  Future<PaginatedResults<Category>> getCategories(
      {int page = 1, String query = ""}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('${categoryUrl}?page=$page&q=$query'),
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

  Future<Category> getCategory(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse(
            '$supplierUrl$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get record: $e');
    }
  }

  Future<Category> createCategory({required Category category}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(category.toJson());
      final response = await client.post(
        Uri.parse(categoryUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        return Category.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create category: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }

  Future<Category> updateCategory(
      {required Category category}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(category.toJson());
      final response = await client.patch(
        Uri.parse('$categoryUrl${category.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      }
      // final responseBody = response.body;
      // print('Response body: $responseBody');
      throw Exception('Failed to update record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update record: $e');
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$categoryUrl$id/'),
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
      throw Exception('Failed to delete category: $e');
    }
    return false;
  }

}
