import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const _baseUrl = 'https://vercel.com/ankitseths-projects/login-signup/92QUrjxS74dXARkXVbqHZYCRx67e'; // e.g. https://api.example.com
  final AuthService authService;

  ApiService({required this.authService});

  Map<String, String> _defaultHeaders() {
    final headers = {'Content-Type': 'application/json'};
    final token = authService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> sendChat({
    required String domain,
    required String message,
  }) async {
    final url = Uri.parse('$_baseUrl/chat');
    final body = jsonEncode({
      'domain': domain,
      'message': message,
    });

    final resp = await http.post(url, headers: _defaultHeaders(), body: body);

    if (resp.statusCode == 200) {
      final parsed = jsonDecode(resp.body);
      return {'success': true, 'data': parsed};
    } else if (resp.statusCode == 401) {
      return {'success': false, 'unauthorized': true, 'message': 'Unauthorized'};
    } else {
      return {'success': false, 'message': 'Server error: ${resp.statusCode}'};
    }
  }

  Future<bool> ping() async {
    final url = Uri.parse('$_baseUrl/ping');
    final resp = await http.get(url, headers: _defaultHeaders());
    return resp.statusCode == 200;
  }
}
