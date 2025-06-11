
import 'dart:convert';

import 'package:online_reservation/Core/Data/API_Services/token.service.dart';
import 'package:online_reservation/Core/Data/Models/paginated.model.dart';
import 'package:online_reservation/Features/Issue/Data/Model/issue.comment.model.dart';
import 'package:online_reservation/config/host.dart';

class IssueCommentApiService extends TokenService{
  static const String baseUrl = '${appURL}comments/';

  IssueCommentApiService({required super.storage, required super.client});

  Future<Comment> createComment({required Comment comment}) async  {
    try {
      String? token = await getAccessToken(storage);
      final body = json.encode(comment.toJson());
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
        return Comment.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create comment: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<PaginatedResults<Comment>> getComments({int page = 1, required int issue}) async {
    try {
      String? token = await getAccessToken(storage);
      final response = await client.get(
        Uri.parse('$baseUrl?page=$page&issue=$issue'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return PaginatedResults<Comment>.fromJson(
          jsonDecode(response.body),
              (json) => Comment.fromJson(json),
        );
      }
      throw Exception('Failed to get comments: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }
}