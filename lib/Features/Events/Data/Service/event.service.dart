import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/config/host.dart';

class EventApiService extends TokenService {
  static const String baseUrl = '${appURL}events/';
  EventApiService({required super.storage, required super.client});

  Future<Event> createEvent({required Event event}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(event.toCreateJson());
      final response = await client.post(
        Uri.parse(baseUrl),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        return Event.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<Event> updateEvent({required Event event}) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(event.toJson());
      final response = await client.patch(
        Uri.parse('$baseUrl${event.id}/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Event.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<PaginatedResults<Event>> getEvents({
    int page = 1,
    String query = "",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String? token = await getAccessToken(storage);

      // Build the query parameters dynamically
      final params = {
        'page': '$page',
        if (query.isNotEmpty) 'q': query,
        if (startDate != null) 'date__gte': startDate.toIso8601String(),
        if (endDate != null) 'date__lt': endDate.toIso8601String(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);

      final response = await client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return PaginatedResults<Event>.fromJson(
          jsonDecode(response.body),
              (json) => Event.fromJson(json),
        );
      }

      throw Exception('Failed to get events: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  Future<PaginatedResults<Event>> getPastEvents({
    int page = 1,
    String query = "",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String? token = await getAccessToken(storage);
      final uri = Uri.parse('${baseUrl}past/').replace(queryParameters: {
        'page': page.toString(),
        if (query.isNotEmpty) 'q': query,
        if (startDate != null) 'date__gte': startDate.toIso8601String(),
        if (endDate != null) 'date__lt': endDate.toIso8601String(),
      });

      final response = await client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Event>.fromJson(
          jsonDecode(response.body),
              (json) => Event.fromJson(json),
        );
      }
      throw Exception('Failed to get past events: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get past events: $e');
    }
  }

  Future<PaginatedResults<Event>> getOngoingEvents({
    int page = 1,
    String query = "",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String? token = await getAccessToken(storage);
      final uri = Uri.parse('${baseUrl}ongoing_this_month/').replace(queryParameters: {
        'page': page.toString(),
        if (query.isNotEmpty) 'q': query,
        if (startDate != null) 'date__gte': startDate.toIso8601String(),
        if (endDate != null) 'date__lt': endDate.toIso8601String(),
      });

      final response = await client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Event>.fromJson(
          jsonDecode(response.body),
              (json) => Event.fromJson(json),
        );
      }
      throw Exception('Failed to get ongoing events: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get ongoing events: $e');
    }
  }

  Future<PaginatedResults<Event>> getUpcomingEvents({
    int page = 1,
    String query = "",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String? token = await getAccessToken(storage);
      final uri = Uri.parse('${baseUrl}upcoming/').replace(queryParameters: {
        'page': page.toString(),
        if (query.isNotEmpty) 'q': query,
        if (startDate != null) 'date__gte': startDate.toIso8601String(),
        if (endDate != null) 'date__lt': endDate.toIso8601String(),
      });

      final response = await client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Event>.fromJson(
          jsonDecode(response.body),
              (json) => Event.fromJson(json),
        );
      }
      throw Exception('Failed to get upcoming events: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get upcoming events: $e');
    }
  }


  // Future<PaginatedResults<Event>> getPastEvents({
  //   int page = 1,
  //   String query = "",
  // }) async {
  //   try {
  //     String? token = await getAccessToken(storage);
  //     final response = await client.get(
  //       Uri.parse('${baseUrl}past/?page=$page&q=$query'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       return PaginatedResults<Event>.fromJson(
  //         jsonDecode(response.body),
  //         (json) => Event.fromJson(json),
  //       );
  //     }
  //     throw Exception('Failed to get events: ${response.statusCode}');
  //   } catch (e) {
  //     throw Exception('Failed to get events: $e');
  //   }
  // }
  //
  // Future<PaginatedResults<Event>> getOngoingEvents({
  //   int page = 1,
  //   String query = "",
  // }) async {
  //   try {
  //     String? token = await getAccessToken(storage);
  //     final response = await client.get(
  //       Uri.parse('${baseUrl}ongoing_this_month/?page=$page&q=$query'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       return PaginatedResults<Event>.fromJson(
  //         jsonDecode(response.body),
  //         (json) => Event.fromJson(json),
  //       );
  //     }
  //     throw Exception('Failed to get events: ${response.statusCode}');
  //   } catch (e) {
  //     throw Exception('Failed to get events: $e');
  //   }
  // }
  //
  // Future<PaginatedResults<Event>> getUpcomingEvents({
  //   int page = 1,
  //   String query = "",
  // }) async {
  //   try {
  //     String? token = await getAccessToken(storage);
  //     final response = await client.get(
  //       Uri.parse('${baseUrl}upcoming/?page=$page&q=$query'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       return PaginatedResults<Event>.fromJson(
  //         jsonDecode(response.body),
  //         (json) => Event.fromJson(json),
  //       );
  //     }
  //     throw Exception('Failed to get events: ${response.statusCode}');
  //   } catch (e) {
  //     throw Exception('Failed to get events: $e');
  //   }
  // }

  Future<Event> getEvent(int id) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return Event.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get record: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get record: $e');
    }
  }

  Future<bool> deleteEvent(int eventId) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.delete(
        Uri.parse('$baseUrl$eventId/'),
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

  Future<Event> attendEvent(int eventId) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode({
        'action': 'attend',
      });
      final response = await client.post(
        Uri.parse('$baseUrl$eventId/attend/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        // 201 Created
        return Event.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to resolve event: $e');
    }
  }

  Future<Event> unattendEvent(int eventId) async {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode({
        'action': 'unattend',
      });
      final response = await client.post(
        Uri.parse('$baseUrl$eventId/attend/'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        // 201 Created
        return Event.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to update event: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to resolve event: $e');
    }
  }

  Future<void> uploadFileAdaptive(
      int eventId, PlatformFile file, bool isWeb) async {
    try {
      String? token = await getAccessToken(storage);
      if (token == null) throw Exception("Invalid Access not found.");
      // Create a multipart request
      var request = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl$eventId/upload/'));

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
      throw Exception('Failed to update event image: $e');
    }
  }
}
