import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:online_reservation/config/host.dart';
import 'package:online_reservation/Features/Authentication/Data/Model/auth.model.dart';

abstract class TokenService {

  final http.Client client;
  final FlutterSecureStorage storage;

  TokenService({required this.storage,required this.client});

  Future<String?> getAccessToken(final FlutterSecureStorage storage) async {
    return await storage.read(key: "access");
  }

  Future<String?> getRefreshToken(final FlutterSecureStorage storage) async {
    return await storage.read(key: "refresh");
  }

  Future<bool> refreshAccessToken(final FlutterSecureStorage storage, final http.Client client) async {
    String? refreshToken = await getRefreshToken(storage);
    if (refreshToken == null) return false;

    try {
      var response = await client.post(
        Uri.parse('${authURL}token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      if (response.statusCode == 200) {
        var token = TokenResponse.fromJson(jsonDecode(response.body));
        await storage.write(key: "access", value: token.accessToken);
        await storage.write(key: "refresh", value: token.refreshToken);
        return true;
      } else {
        throw Exception(
            'Failed to get refresh token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

}