import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../models/models.dart';

class AttendanceApiService {
  static const String _baseUrl = 'https://elkably.org';

  /// Fetch attendance records for a student
  /// 
  /// [studentId] - MongoDB ObjectId of the student
  /// [token] - JWT authentication token
  /// [startDate] - Optional start date (YYYY-MM-DD)
  /// [endDate] - Optional end date (YYYY-MM-DD)
  static Future<AttendanceResult> getAttendance({
    required String studentId,
    required String token,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Build URL with query parameters
      var url = '$_baseUrl/api/parent/attendance/$studentId';
      final queryParams = <String, String>{};
      
      if (startDate != null) queryParams['start'] = startDate;
      if (endDate != null) queryParams['end'] = endDate;
      
      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final uri = Uri.parse(url);
      
      debugPrint('========== ATTENDANCE API REQUEST ==========');
      debugPrint('[ATTENDANCE] URL: $uri');
      debugPrint('[ATTENDANCE] Student ID: $studentId');
      debugPrint('[ATTENDANCE] Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('========== ATTENDANCE API RESPONSE ==========');
      debugPrint('[ATTENDANCE] Status Code: ${response.statusCode}');
      debugPrint('[ATTENDANCE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final attendanceList = (data['attendance'] as List<dynamic>)
              .map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>))
              .toList();

          final studentData = data['student'] as Map<String, dynamic>?;
          final totalRecords = data['totalRecords'] as int? ?? attendanceList.length;

          debugPrint('[ATTENDANCE] ✅ Fetched ${attendanceList.length} records');
          
          return AttendanceResult.success(
            attendance: attendanceList,
            totalRecords: totalRecords,
            studentInfo: studentData,
          );
        } else {
          final message = data['message'] as String? ?? 'Failed to fetch attendance';
          debugPrint('[ATTENDANCE] ❌ API Error: $message');
          return AttendanceResult.error(message);
        }
      } else if (response.statusCode == 404) {
        return AttendanceResult.error('Student not found');
      } else if (response.statusCode == 403) {
        return AttendanceResult.error('You are not authorized to view this student');
      } else if (response.statusCode == 401) {
        return AttendanceResult.error('Unauthorized. Please login again.');
      } else {
        return AttendanceResult.error('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ATTENDANCE] ❌ Exception: $e');
      return AttendanceResult.error('Network error: ${e.toString()}');
    }
  }
}

/// Result class for attendance API calls
class AttendanceResult {
  final bool success;
  final List<AttendanceRecord>? attendance;
  final int? totalRecords;
  final Map<String, dynamic>? studentInfo;
  final String? errorMessage;

  const AttendanceResult({
    required this.success,
    this.attendance,
    this.totalRecords,
    this.studentInfo,
    this.errorMessage,
  });

  factory AttendanceResult.success({
    required List<AttendanceRecord> attendance,
    required int totalRecords,
    Map<String, dynamic>? studentInfo,
  }) {
    return AttendanceResult(
      success: true,
      attendance: attendance,
      totalRecords: totalRecords,
      studentInfo: studentInfo,
    );
  }

  factory AttendanceResult.error(String message) {
    return AttendanceResult(
      success: false,
      errorMessage: message,
    );
  }
}
