import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String url) async {
    final response = await _client.get(
      Uri.parse(url),
      headers: _jsonHeaders(),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getJsonList(String url) async {
    final response = await _client.get(
      Uri.parse(url),
      headers: _jsonHeaders(),
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: _jsonHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, String> _jsonHeaders() => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_buildErrorMessage(response));
    }
    final body = response.body.trim();
    if (body.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected response format.');
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_buildErrorMessage(response));
    }
    final body = response.body.trim();
    if (body.isEmpty) {
      return <dynamic>[];
    }
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded;
    }
    throw Exception('Unexpected response format.');
  }

  String _buildErrorMessage(http.Response response) {
    final status = response.statusCode;
    final body = response.body.trim();
    if (body.isEmpty) {
      return 'Request failed ($status).';
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        final details = decoded['details'];
        if (details is List && details.isNotEmpty) {
          return 'Request failed ($status): $message (${details.join(', ')})';
        }
        if (message != null && message.isNotEmpty) {
          return 'Request failed ($status): $message';
        }
      }
    } catch (_) {
      // Fall through to raw body.
    }
    return 'Request failed ($status): $body';
  }
}
