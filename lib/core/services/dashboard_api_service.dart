import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../models/models.dart';

class DashboardApiService {
  static const String _baseUrl = 'https://elkably.org';

  /// Fetch dashboard data for a student
  /// 
  /// [studentId] - MongoDB ObjectId of the student
  /// [token] - JWT authentication token
  static Future<DashboardResult> getDashboard({
    required String studentId,
    required String token,
  }) async {
    try {
      final url = '$_baseUrl/api/parent/dashboard/$studentId';
      final uri = Uri.parse(url);
      
      debugPrint('========== DASHBOARD API REQUEST ==========');
      debugPrint('[DASHBOARD] URL: $uri');
      debugPrint('[DASHBOARD] Student ID: $studentId');
      debugPrint('[DASHBOARD] Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('========== DASHBOARD API RESPONSE ==========');
      debugPrint('[DASHBOARD] Status Code: ${response.statusCode}');
      debugPrint('[DASHBOARD] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final dashboardData = DashboardData.fromJson(data);

          debugPrint('[DASHBOARD] ✅ Dashboard data loaded');
          debugPrint('[DASHBOARD] Last session: ${dashboardData.lastSession?.date ?? "None"}');
          debugPrint('[DASHBOARD] Balance: ${dashboardData.payment.balance}');
          debugPrint('[DASHBOARD] Notifications: ${dashboardData.recentNotifications.length}');
          
          return DashboardResult.success(dashboardData: dashboardData);
        } else {
          final message = data['message'] as String? ?? 'Failed to fetch dashboard';
          debugPrint('[DASHBOARD] ❌ API Error: $message');
          return DashboardResult.error(message);
        }
      } else if (response.statusCode == 404) {
        return DashboardResult.error('Student not found');
      } else if (response.statusCode == 403) {
        return DashboardResult.error('You are not authorized to view this student');
      } else if (response.statusCode == 401) {
        return DashboardResult.error('Unauthorized. Please login again.');
      } else {
        return DashboardResult.error('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[DASHBOARD] ❌ Exception: $e');
      return DashboardResult.error('Network error: ${e.toString()}');
    }
  }
}

/// Result class for dashboard API calls
class DashboardResult {
  final bool success;
  final DashboardData? dashboardData;
  final String? errorMessage;

  const DashboardResult({
    required this.success,
    this.dashboardData,
    this.errorMessage,
  });

  factory DashboardResult.success({
    required DashboardData dashboardData,
  }) {
    return DashboardResult(
      success: true,
      dashboardData: dashboardData,
    );
  }

  factory DashboardResult.error(String message) {
    return DashboardResult(
      success: false,
      errorMessage: message,
    );
  }
}
