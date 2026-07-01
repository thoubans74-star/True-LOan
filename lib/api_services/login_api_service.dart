import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tm/googleplay/playstore.dart';

class LoginApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  /// Sends OTP using type 1100 API
  static Future<Map<String, dynamic>?> sendOtp({
    required String phone,
    required String deviceId,
    required String appSignature,
    required String lt,
    required String ln,
  }) async {
    try {
      if (PlaystoreMock.isPlaystoreUser(phone)) {
        return PlaystoreMock.mockSendOtpResponse();
      }
      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'cid': '21472147',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'type': '1100',
          'mobile': phone,
          'app_signature': appSignature,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error in sendOtp: $e');
    }
    return null;
  }

  /// Verifies OTP using type 1101 API
  static Future<Map<String, dynamic>?> verifyOtp({
    required String mobile,
    required String pin,
    required String token,
    required String deviceId,
    required String lt,
    required String ln,
  }) async {
    try {
      if (PlaystoreMock.isPlaystoreUser(mobile)) {
        return PlaystoreMock.mockVerifyOtpResponse();
      }
      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'cid': '21472147',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'type': '1101',
          'mobile': mobile,
          'otp': pin,
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error in verifyOtp: $e');
    }
    return null;
  }
}
