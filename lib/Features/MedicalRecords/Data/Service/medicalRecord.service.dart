import 'dart:convert' show jsonDecode, json;
import 'package:online_reservation/config/host.dart';
import 'package:online_reservation/Core/Data/API_Services/token.service.dart' show TokenService;
import 'package:online_reservation/Core/Data/Models/paginated.model.dart' show PaginatedResults;
import 'package:online_reservation/Features/MedicalRecords/Data/Model/medicalRecord.model.dart' show MedicalRecord;

class MedicalRecordApiService extends TokenService{
  MedicalRecordApiService({required super.storage, required super.client});

  static const String baseUrl = '${appURL}medical-records/';

  Future<PaginatedResults<MedicalRecord>> getRecords(
      {int page = 1,
        String query = "",
        String category = ""}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse(
            '$baseUrl?page=$page&q=$query&diagnosis_category=$category'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<MedicalRecord>.fromJson(
          jsonDecode(response.body),
              (json) => MedicalRecord.fromJson(json),
        );
      }
      throw Exception('Failed to get records: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get records: $e');
    }
  }

  Future<MedicalRecord> getRecord(int id) async {
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
        return MedicalRecord.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get record: $e');
    }
  }

  Future<MedicalRecord> createRecord({required MedicalRecord record}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(record.toJson());
      final response = await client.post(
        Uri.parse(baseUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        return MedicalRecord.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create record: $e');
    }
  }

  Future<MedicalRecord> updateApplication(
      {required MedicalRecord record}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(record.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${record.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return MedicalRecord.fromJson(jsonDecode(response.body));
      }
      // final responseBody = response.body;
      // print('Response body: $responseBody');
      throw Exception('Failed to update record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update record: $e');
    }
  }

  Future<bool> deleteRecord(int recordId) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$baseUrl$recordId/'),
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
      throw Exception('Failed to delete record: $e');
    }
    return false;
  }
}