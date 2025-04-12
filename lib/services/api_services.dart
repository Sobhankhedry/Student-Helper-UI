import 'dart:convert';
import 'package:flutter_application_2/models/Course.dart';
import 'package:flutter_application_2/term_schedule_page.dart';
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
  Future<User> login(LoginRequest loginRequest) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginRequest.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return User.fromJson(json);
    } else {
      throw HttpException(response.statusCode, response.body);
    }
  }

  Future<List<Course>> fetchSchedule(String university, String major) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/TermCourse'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'university': university, 'major': major}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        List<Course> entries = [];

        for (var item in decoded) {
          entries.add(Course.fromJson(item));
        }

        return entries;
      } else {
        throw Exception('خطا در دریافت برنامه: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور: $e');
    }
  }

  Future<List<Course>> fetchExam(
    String university,
    String major,
    String username,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Exam'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'university': university,
          'major': major,
          'userName': username,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        List<Course> entriess = [];

        for (var item in decoded) {
          entriess.add(Course.fromJson(item));
        }

        return entriess;
      } else {
        throw Exception('خطا در دریافت برنامه: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور: $e');
    }
  }

  Future<List<Course>> fetchWeekly(
    String university,
    String major,
    String username,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Weekly'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'university': university,
          'major': major,
          'userName': username,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        List<Course> entriess = [];

        for (var item in decoded) {
          entriess.add(Course.fromJson(item));
        }

        return entriess;
      } else {
        throw Exception('خطا در دریافت برنامه: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور: $e');
    }
  }

  Future<List<Course>> fetchScheduleByCourseIds(List<String> courseIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/TermCourse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': courseIds}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch selected schedule');
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
