
import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Events/Data/Model/event.model.dart';
import 'package:online_reservation/config/host.dart';

class EventApiService extends TokenService{
  static const String baseUrl = '${appURL}events/';
  EventApiService({required super.storage, required super.client});

  Future<Event> createEvent({required Event event}) async  {
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

  Future<PaginatedResults<Event>> getEvents({int page = 1, String query = "",}) async {
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

  Future<Event> getEvent(int id) async {
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
}