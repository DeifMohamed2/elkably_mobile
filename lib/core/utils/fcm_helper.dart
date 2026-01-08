import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class FcmHelper {
  static const _tokenKey = 'fcm_token';

  /// Retrieve a cached FCM token if available, otherwise fetch from Firebase.
  static Future<String?> getFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_tokenKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await prefs.setString(_tokenKey, token);
      }
      return token;
    } catch (e) {
      debugPrint('[FCM] Token retrieval error: $e');
      return null;
    }
  }

  /// Force refresh and persist the token.
  static Future<String?> refreshToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString(_tokenKey, token);
      }
      return token;
    } catch (e) {
      debugPrint('[FCM] Token refresh error: $e');
      return null;
    }
  }
}
