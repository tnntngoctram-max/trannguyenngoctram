import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage.dart';

/// Dio/Http client gắn JWT Token
class ApiClient {
  Future<Map<String, String>> _getHeaders() async {
    final token = await Storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(endpoint), headers: headers);
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }
}
