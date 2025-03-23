import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/User.dart';
import '../models/LoginRequest.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:7007/api/Users';

  // Sign Up
  Future<String> signUp(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      // Throw exception with status code and body
      throw HttpException(response.statusCode, response.body);
    }
  }

  // Loginu
  Future<String> login(LoginRequest loginRequest) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginRequest.toJson()),
    );

    if (response.statusCode == 200) {
      return response.body; // e.g., "welcome username"
    } else {
      throw HttpException(response.statusCode, response.body);
    }
  }
}

class HttpException implements Exception {
  final int statusCode;
  final String message;

  HttpException(this.statusCode, this.message);

  @override
  String toString() => 'HttpException: $statusCode → $message';
}
