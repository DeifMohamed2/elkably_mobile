import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../../models/models.dart';

class NotificationsApiService {
  static const String _baseUrl = 'https://elkably.org';
  static const String _onlineBaseUrl = 'https://elkably.com';

  static Future<NotificationsResult> getNotificationsOnline({
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_onlineBaseUrl/api/parent/notifications').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    debugPrint('========== ONLINE NOTIFICATIONS API REQUEST ==========');
    debugPrint('[NOTIFICATIONS_ONLINE] URL: $uri');
    debugPrint('[NOTIFICATIONS_ONLINE] Page: $page, Limit: $limit');

    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('[NOTIFICATIONS_ONLINE] ❌ No JWT token found');
        return NotificationsResult(
          success: false,
          message: 'Not authenticated',
        );
      }

      debugPrint('[NOTIFICATIONS_ONLINE] Token: ${token.substring(0, 20)}...');

      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('========== ONLINE NOTIFICATIONS API RESPONSE ==========');
      debugPrint('[NOTIFICATIONS_ONLINE] Status Code: ${resp.statusCode}');
      debugPrint('[NOTIFICATIONS_ONLINE] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[NOTIFICATIONS_ONLINE] Parsed Data: $data');

        if (data['success'] == true) {
          final dataObj = data['data'] as Map<String, dynamic>?;
          final notificationsJson = (dataObj?['notifications'] as List?) ?? [];
          debugPrint(
            '[NOTIFICATIONS_ONLINE] Notifications JSON count: ${notificationsJson.length}',
          );

          final notifications =
              notificationsJson.map<AppNotification>((e) {
                final m = e as Map<String, dynamic>;
                debugPrint(
                  '[NOTIFICATIONS_ONLINE] Mapping notification: ${m['title']}',
                );
                return AppNotification.fromJson(m);
              }).toList();

          final pagination = dataObj?['pagination'] as Map<String, dynamic>?;

          debugPrint(
            '[NOTIFICATIONS_ONLINE] ✅ Successfully parsed ${notifications.length} notifications',
          );
          for (var n in notifications) {
            debugPrint('   - ${n.title} (${n.type.name}) - Read: ${!n.isNew}');
          }

          return NotificationsResult(
            success: true,
            notifications: notifications,
            page: pagination?['page'] as int? ?? page,
            limit: pagination?['limit'] as int? ?? limit,
            total: pagination?['total'] as int? ?? notifications.length,
            pages: pagination?['pages'] as int? ?? 1,
          );
        }
        debugPrint('[NOTIFICATIONS_ONLINE] ❌ API returned success=false');
        return NotificationsResult(
          success: false,
          message: data['message']?.toString(),
        );
      }

      // Handle error responses
      debugPrint(
        '[NOTIFICATIONS_ONLINE] ❌ Non-200 status code: ${resp.statusCode}',
      );
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[NOTIFICATIONS_ONLINE] Error response: $data');
        return NotificationsResult(
          success: false,
          message: data['message']?.toString(),
        );
      } catch (parseError) {
        debugPrint(
          '[NOTIFICATIONS_ONLINE] Failed to parse error response: $parseError',
        );
      }

      return NotificationsResult(
        success: false,
        message: 'Server error. Please try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('[NOTIFICATIONS_ONLINE] ❌ Exception: $e');
      debugPrint('[NOTIFICATIONS_ONLINE] Stack trace: $stackTrace');
      return NotificationsResult(
        success: false,
        message: 'Network error. Check your connection.',
      );
    }
  }

  static Future<NotificationsResult> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/parent/notifications').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    debugPrint('========== NOTIFICATIONS API REQUEST ==========');
    debugPrint('[NOTIFICATIONS] URL: $uri');
    debugPrint('[NOTIFICATIONS] Page: $page, Limit: $limit');

    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('[NOTIFICATIONS] ❌ No JWT token found');
        return NotificationsResult(
          success: false,
          message: 'Not authenticated',
        );
      }

      debugPrint('[NOTIFICATIONS] Token: ${token.substring(0, 20)}...');

      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('========== NOTIFICATIONS API RESPONSE ==========');
      debugPrint('[NOTIFICATIONS] Status Code: ${resp.statusCode}');
      debugPrint('[NOTIFICATIONS] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[NOTIFICATIONS] Parsed Data: $data');

        if (data['success'] == true) {
          final notificationsJson = (data['notifications'] as List?) ?? [];
          debugPrint(
            '[NOTIFICATIONS] Notifications JSON count: ${notificationsJson.length}',
          );

          final notifications =
              notificationsJson.map<AppNotification>((e) {
                final m = e as Map<String, dynamic>;
                debugPrint(
                  '[NOTIFICATIONS] Mapping notification: ${m['title']}',
                );
                return AppNotification.fromJson(m);
              }).toList();

          final pagination = data['pagination'] as Map<String, dynamic>?;

          debugPrint(
            '[NOTIFICATIONS] ✅ Successfully parsed ${notifications.length} notifications',
          );
          for (var n in notifications) {
            debugPrint('   - ${n.title} (${n.type.name}) - Read: ${!n.isNew}');
          }

          return NotificationsResult(
            success: true,
            notifications: notifications,
            page: pagination?['page'] as int? ?? page,
            limit: pagination?['limit'] as int? ?? limit,
            total: pagination?['total'] as int? ?? notifications.length,
            pages: pagination?['pages'] as int? ?? 1,
          );
        }
        debugPrint('[NOTIFICATIONS] ❌ API returned success=false');
        return NotificationsResult(
          success: false,
          message: data['message']?.toString(),
        );
      }

      // Handle error responses
      debugPrint('[NOTIFICATIONS] ❌ Non-200 status code: ${resp.statusCode}');
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[NOTIFICATIONS] Error response: $data');
        return NotificationsResult(
          success: false,
          message: data['message']?.toString(),
        );
      } catch (parseError) {
        debugPrint(
          '[NOTIFICATIONS] Failed to parse error response: $parseError',
        );
      }

      return NotificationsResult(
        success: false,
        message: 'Server error. Please try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('[NOTIFICATIONS] ❌ Exception: $e');
      debugPrint('[NOTIFICATIONS] Stack trace: $stackTrace');
      return NotificationsResult(
        success: false,
        message: 'Network error. Check your connection.',
      );
    }
  }

  static Future<bool> markAsReadOnline(String notificationId) async {
    final uri = Uri.parse(
      '$_onlineBaseUrl/api/parent/notifications/$notificationId/read',
    );

    debugPrint('========== ONLINE MARK NOTIFICATION READ API ==========');
    debugPrint('[MARK_READ_ONLINE] URL: $uri');
    debugPrint('[MARK_READ_ONLINE] Notification ID: $notificationId');

    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('[MARK_READ_ONLINE] ❌ No JWT token found');
        return false;
      }

      debugPrint('[MARK_READ_ONLINE] Token: ${token.substring(0, 20)}...');

      final resp = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        '========== ONLINE MARK NOTIFICATION READ RESPONSE ==========',
      );
      debugPrint('[MARK_READ_ONLINE] Status Code: ${resp.statusCode}');
      debugPrint('[MARK_READ_ONLINE] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[MARK_READ_ONLINE] Parsed Data: $data');

        if (data['success'] == true) {
          debugPrint('[MARK_READ_ONLINE] ✅ Notification marked as read');
          return true;
        }
        debugPrint('[MARK_READ_ONLINE] ❌ API returned success=false');
        return false;
      }

      // Handle error responses
      debugPrint(
        '[MARK_READ_ONLINE] ❌ Non-200 status code: ${resp.statusCode}',
      );
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[MARK_READ_ONLINE] Error response: $data');
      } catch (parseError) {
        debugPrint(
          '[MARK_READ_ONLINE] Failed to parse error response: $parseError',
        );
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint('[MARK_READ_ONLINE] ❌ Exception: $e');
      debugPrint('[MARK_READ_ONLINE] Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> markAsRead(String notificationId) async {
    final uri = Uri.parse(
      '$_baseUrl/api/parent/notifications/$notificationId/read',
    );

    debugPrint('========== MARK NOTIFICATION READ API ==========');
    debugPrint('[MARK_READ] URL: $uri');
    debugPrint('[MARK_READ] Notification ID: $notificationId');

    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('[MARK_READ] ❌ No JWT token found');
        return false;
      }

      debugPrint('[MARK_READ] Token: ${token.substring(0, 20)}...');

      final resp = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('========== MARK NOTIFICATION READ RESPONSE ==========');
      debugPrint('[MARK_READ] Status Code: ${resp.statusCode}');
      debugPrint('[MARK_READ] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[MARK_READ] Parsed Data: $data');

        if (data['success'] == true) {
          debugPrint('[MARK_READ] ✅ Notification marked as read');
          return true;
        }
        debugPrint('[MARK_READ] ❌ API returned success=false');
        return false;
      }

      // Handle error responses
      debugPrint('[MARK_READ] ❌ Non-200 status code: ${resp.statusCode}');
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[MARK_READ] Error response: $data');
      } catch (parseError) {
        debugPrint('[MARK_READ] Failed to parse error response: $parseError');
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint('[MARK_READ] ❌ Exception: $e');
      debugPrint('[MARK_READ] Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> markAllAsReadOnline() async {
    final uri = Uri.parse('$_onlineBaseUrl/api/parent/notifications/mark-all-read');

    debugPrint('========== ONLINE MARK ALL NOTIFICATIONS READ API ==========');
    debugPrint('[MARK_ALL_READ_ONLINE] URL: $uri');

    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('[MARK_ALL_READ_ONLINE] ❌ No JWT token found');
        return false;
      }

      debugPrint('[MARK_ALL_READ_ONLINE] Token: ${token.substring(0, 20)}...');

      final resp = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        '========== ONLINE MARK ALL NOTIFICATIONS READ RESPONSE ==========',
      );
      debugPrint('[MARK_ALL_READ_ONLINE] Status Code: ${resp.statusCode}');
      debugPrint('[MARK_ALL_READ_ONLINE] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[MARK_ALL_READ_ONLINE] Parsed Data: $data');

        if (data['success'] == true) {
          final message = data['message']?.toString() ?? '';
          debugPrint('[MARK_ALL_READ_ONLINE] ✅ $message');
          return true;
        }
        debugPrint('[MARK_ALL_READ_ONLINE] ❌ API returned success=false');
        return false;
      }

      // Handle error responses
      debugPrint(
        '[MARK_ALL_READ_ONLINE] ❌ Non-200 status code: ${resp.statusCode}',
      );
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[MARK_ALL_READ_ONLINE] Error response: $data');
      } catch (parseError) {
        debugPrint(
          '[MARK_ALL_READ_ONLINE] Failed to parse error response: $parseError',
        );
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint('[MARK_ALL_READ_ONLINE] ❌ Exception: $e');
      debugPrint('[MARK_ALL_READ_ONLINE] Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> markAllAsRead() async {
    final uri = Uri.parse('$_baseUrl/api/parent/notifications/read-all');

    debugPrint('========== MARK ALL NOTIFICATIONS READ API ==========');
    debugPrint('[MARK_ALL_READ] URL: $uri');

    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        debugPrint('[MARK_ALL_READ] ❌ No JWT token found');
        return false;
      }

      debugPrint('[MARK_ALL_READ] Token: ${token.substring(0, 20)}...');

      final resp = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('========== MARK ALL NOTIFICATIONS READ RESPONSE ==========');
      debugPrint('[MARK_ALL_READ] Status Code: ${resp.statusCode}');
      debugPrint('[MARK_ALL_READ] Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[MARK_ALL_READ] Parsed Data: $data');

        if (data['success'] == true) {
          final message = data['message']?.toString() ?? '';
          debugPrint('[MARK_ALL_READ] ✅ $message');
          return true;
        }
        debugPrint('[MARK_ALL_READ] ❌ API returned success=false');
        return false;
      }

      // Handle error responses
      debugPrint('[MARK_ALL_READ] ❌ Non-200 status code: ${resp.statusCode}');
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[MARK_ALL_READ] Error response: $data');
      } catch (parseError) {
        debugPrint(
          '[MARK_ALL_READ] Failed to parse error response: $parseError',
        );
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint('[MARK_ALL_READ] ❌ Exception: $e');
      debugPrint('[MARK_ALL_READ] Stack trace: $stackTrace');
      return false;
    }
  }
}

class NotificationsResult {
  final bool success;
  final String? message;
  final List<AppNotification> notifications;
  final int page;
  final int limit;
  final int total;
  final int pages;

  NotificationsResult({
    required this.success,
    this.message,
    this.notifications = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.pages = 1,
  });
}
