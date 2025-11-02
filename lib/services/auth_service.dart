import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  static const _storageKey = 'suvidha_jwt';
  static const _baseUrl = 'http://localhost:3000'; 

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  bool isChecking = true;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    _token = await _storage.read(key: _storageKey);
    isChecking = false;
    notifyListeners();
  }

  bool get isAuthenticated => _token != null;

  String? get token => _token;

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: _storageKey);
    notifyListeners();
  }

  Future<void> storeToken(String token) async {
    _token = token;
    await _storage.write(key: _storageKey, value: token);
    notifyListeners();
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final url = Uri.parse('$_baseUrl/login');
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['token'] != null) {
      await storeToken(body['token']);
      return {'success': true};
    } else {
      return {'success': false, 'message': body['message'] ?? 'Login failed'};
    }
  }

  Future<Map<String, dynamic>> signup({required String name, required String email, required String password}) async {
    final url = Uri.parse('$_baseUrl/signup');
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}));
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 201 && body['token'] != null) {
      await storeToken(body['token']);
      return {'success': true};
    } else {
      return {'success': false, 'message': body['message'] ?? 'Signup failed'};
    }
  }
}
