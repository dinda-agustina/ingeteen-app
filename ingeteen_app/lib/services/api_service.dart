import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;
  final FlutterSecureStorage _storage;

  ApiService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  // Header umum untuk request API
  Future<Map<String, String>> _headers({bool withToken = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (withToken) {
      final token = await _storage.read(key: 'auth_token');

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  

  // Mengambil token yang tersimpan
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Menyimpan token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Menghapus token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    bool withToken = false,
  }) async {
    final response = await _client.get(
      Uri.parse(endpoint),
      headers: await _headers(withToken: withToken),
    );

    return _handleResponse(response);
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withToken = false,
  }) async {
    final response = await _client.post(
      Uri.parse(endpoint),
      headers: await _headers(withToken: withToken),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  // PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withToken = false,
  }) async {
    final response = await _client.patch(
      Uri.parse(endpoint),
      headers: await _headers(withToken: withToken),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool withToken = false,
  }) async {
    final response = await _client.delete(
      Uri.parse(endpoint),
      headers: await _headers(withToken: withToken),
    );

    return _handleResponse(response);
  }

  // Memproses response dari Laravel
  dynamic _handleResponse(http.Response response) {
    dynamic decodedBody;

    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      decodedBody = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    String message = 'Terjadi kesalahan pada server.';

    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody['message'] != null) {
        message = decodedBody['message'].toString();
      }

      // Mengambil pesan validasi Laravel
      if (decodedBody['errors'] is Map) {
        final errors = decodedBody['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          }
        }
      }
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
    );
  }
}