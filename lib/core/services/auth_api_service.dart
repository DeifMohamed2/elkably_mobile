import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../../models/models.dart';

class AuthApiService {
  static const String _baseUrl = 'https://elkably.org';
  static const String _onlineBaseUrl = 'https://elkably.com';

  static Future<_LoginResult> loginParentOnline({
    required String parentPhone,
    required String studentCode,
    String? fcmToken,
  }) async {
    final uri = Uri.parse('$_onlineBaseUrl/api/parent/login');
    final body = jsonEncode({
      'parentPhone': parentPhone,
      'studentCode': studentCode,
      'fcmToken': fcmToken ?? '',
    });

    debugPrint('========== ONLINE LOGIN API REQUEST ==========');
    debugPrint('[AUTH] URL: $uri');
    debugPrint('[AUTH] Request Body: $body');
    debugPrint('[AUTH] FCM Token: ${fcmToken ?? "empty"}');

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('========== ONLINE LOGIN API RESPONSE ==========');
      debugPrint('[AUTH] Status Code: ${resp.statusCode}');
      debugPrint('[AUTH] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AUTH] Parsed Data: $data');

        if (data['success'] == true) {
          final token = data['token'] as String?;
          final studentsJson = (data['students'] as List?) ?? [];
          debugPrint('[AUTH] Token received: ${token?.substring(0, 20)}...');
          debugPrint('[AUTH] Students JSON: $studentsJson');

          final students =
              studentsJson.map<Student>((e) {
                final m = e as Map<String, dynamic>;
                debugPrint('[AUTH] Mapping student: $m');
                return Student(
                  id: (m['_id'] ?? m['id'] ?? '').toString(),
                  name: (m['Username'] ?? m['name'] ?? '').toString(),
                  grade: (m['Grade'] ?? m['grade'] ?? '').toString(),
                  studentClass:
                      (m['Code'] ?? m['studentClass'] ?? '').toString(),
                );
              }).toList();

          debugPrint(
            '[AUTH] ✅ Successfully parsed ${students.length} students',
          );
          for (var s in students) {
            debugPrint('   - ${s.name} (${s.studentClass}) - ${s.grade}');
          }

          if (token != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt_token', token);
            debugPrint('[AUTH] ✅ JWT token saved to SharedPreferences');
          }

          return _LoginResult(success: true, token: token, students: students);
        }
        debugPrint('[AUTH] ❌ API returned success=false');
        return _LoginResult(
          success: false,
          message: data['message']?.toString(),
        );
      }

      // Handle known error bodies
      debugPrint('[AUTH] ❌ Non-200 status code: ${resp.statusCode}');
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AUTH] Error response: $data');
        return _LoginResult(
          success: false,
          message: data['message']?.toString(),
        );
      } catch (parseError) {
        debugPrint('[AUTH] Failed to parse error response: $parseError');
      }

      return _LoginResult(
        success: false,
        message: 'Server error. Please try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('[AUTH] ❌ Online login exception: $e');
      debugPrint('[AUTH] Stack trace: $stackTrace');
      return _LoginResult(
        success: false,
        message: 'Network error. Check your connection.',
      );
    }
  }

  static Future<_LoginResult> loginParent({
    required String parentPhone,
    required String studentCode,
    String? fcmToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/parent/login');
    final body = jsonEncode({
      'parentPhone': parentPhone,
      'studentCode': studentCode,
      if (fcmToken != null) 'fcmToken': fcmToken,
    });

    debugPrint('========== LOGIN API REQUEST ==========');
    debugPrint('[AUTH] URL: $uri');
    debugPrint('[AUTH] Request Body: $body');
    debugPrint('[AUTH] FCM Token: ${fcmToken ?? "null"}');

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('========== LOGIN API RESPONSE ==========');
      debugPrint('[AUTH] Status Code: ${resp.statusCode}');
      debugPrint('[AUTH] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AUTH] Parsed Data: $data');

        if (data['success'] == true) {
          final token = data['token'] as String?;
          final studentsJson = (data['students'] as List?) ?? [];
          debugPrint('[AUTH] Token received: ${token?.substring(0, 20)}...');
          debugPrint('[AUTH] Students JSON: $studentsJson');

          final students =
              studentsJson.map<Student>((e) {
                final m = e as Map<String, dynamic>;
                debugPrint('[AUTH] Mapping student: $m');
                return Student(
                  id: (m['_id'] ?? m['id'] ?? '').toString(),
                  name: (m['Username'] ?? m['name'] ?? '').toString(),
                  grade: (m['Grade'] ?? m['grade'] ?? '').toString(),
                  studentClass:
                      (m['Code'] ?? m['studentClass'] ?? '').toString(),
                );
              }).toList();

          debugPrint(
            '[AUTH] ✅ Successfully parsed ${students.length} students',
          );
          for (var s in students) {
            debugPrint('   - ${s.name} (${s.studentClass}) - ${s.grade}');
          }

          if (token != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt_token', token);
            debugPrint('[AUTH] ✅ JWT token saved to SharedPreferences');
          }

          return _LoginResult(success: true, token: token, students: students);
        }
        debugPrint('[AUTH] ❌ API returned success=false');
        return _LoginResult(
          success: false,
          message: data['message']?.toString(),
        );
      }

      // Handle known error bodies
      debugPrint('[AUTH] ❌ Non-200 status code: ${resp.statusCode}');
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AUTH] Error response: $data');
        return _LoginResult(
          success: false,
          message: data['message']?.toString(),
        );
      } catch (parseError) {
        debugPrint('[AUTH] Failed to parse error response: $parseError');
      }

      return _LoginResult(
        success: false,
        message: 'Server error. Please try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('[AUTH] ❌ Login exception: $e');
      debugPrint('[AUTH] Stack trace: $stackTrace');
      return _LoginResult(
        success: false,
        message: 'Network error. Check your connection.',
      );
    }
  }

  static Future<bool> logoutOnline() async {
    final uri = Uri.parse('$_onlineBaseUrl/api/parent/logout');

    debugPrint('========== ONLINE LOGOUT API REQUEST ==========');
    debugPrint('[AUTH] URL: $uri');

    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('[AUTH] ⚠️ No JWT token found for logout');
        return true; // Consider it successful if no token exists
      }

      debugPrint('[AUTH] Token: ${token.substring(0, 20)}...');

      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('========== ONLINE LOGOUT API RESPONSE ==========');
      debugPrint('[AUTH] Status Code: ${resp.statusCode}');
      debugPrint('[AUTH] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AUTH] Parsed Data: $data');

        if (data['success'] == true) {
          debugPrint('[AUTH] ✅ Online logout successful');
          await prefs.remove('jwt_token');
          debugPrint('[AUTH] ✅ JWT token removed from SharedPreferences');
          return true;
        }
        debugPrint('[AUTH] ❌ API returned success=false');
        return false;
      }

      // Handle error responses
      debugPrint('[AUTH] ❌ Non-200 status code: ${resp.statusCode}');
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AUTH] Error response: $data');
      } catch (parseError) {
        debugPrint('[AUTH] Failed to parse error response: $parseError');
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint('[AUTH] ❌ Online logout exception: $e');
      debugPrint('[AUTH] Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> logout() async {
    final uri = Uri.parse('$_baseUrl/api/parent/logout');

    debugPrint('========== LOGOUT API REQUEST ==========');
    debugPrint('[AUTH] URL: $uri');

    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('[AUTH] ⚠️ No JWT token found for logout');
        return true; // Consider it successful if no token exists
      }

      debugPrint('[AUTH] Token: ${token.substring(0, 20)}...');

      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('========== LOGOUT API RESPONSE ==========');
      debugPrint('[AUTH] Status Code: ${resp.statusCode}');
      debugPrint('[AUTH] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AUTH] Parsed Data: $data');

        if (data['success'] == true) {
          debugPrint('[AUTH] ✅ Logout successful');
          await prefs.remove('jwt_token');
          debugPrint('[AUTH] ✅ JWT token removed from SharedPreferences');
          return true;
        }
        debugPrint('[AUTH] ❌ API returned success=false');
        return false;
      }

      // Handle error responses
      debugPrint('[AUTH] ❌ Non-200 status code: ${resp.statusCode}');
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AUTH] Error response: $data');
      } catch (parseError) {
        debugPrint('[AUTH] Failed to parse error response: $parseError');
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint('[AUTH] ❌ Logout exception: $e');
      debugPrint('[AUTH] Stack trace: $stackTrace');
      return false;
    }
  }
}

class _LoginResult {
  final bool success;
  final String? message;
  final String? token;
  final List<Student> students;

  _LoginResult({
    required this.success,
    this.message,
    this.token,
    this.students = const [],
  });
}
