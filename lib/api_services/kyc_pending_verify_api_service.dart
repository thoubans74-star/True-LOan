import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KycPendingVerifyApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  /// Checks the pending KYC verification status using the type 1109 API
  static Future<Map<String, dynamic>?> checkKycStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storedUserId = prefs.getString('user_id') ?? '';
      final String userId = storedUserId.isEmpty ? '' : storedUserId;
      final String storedDeviceId = prefs.getString('device_id') ?? '';
      final String deviceId = storedDeviceId.isEmpty ? '13' : storedDeviceId;
      final String storedLt = prefs.getString('lt') ?? '';
      final String lt = storedLt.isEmpty ? '11' : storedLt;
      final String storedLn = prefs.getString('ln') ?? '';
      final String ln = storedLn.isEmpty ? '11' : storedLn;
      final String storedToken = prefs.getString('token') ?? '';
      final String token = storedToken.isEmpty ? '' : storedToken;

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'cid': '21472147',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'type': '1109',
          'user_id': userId,
          'token': token,
        },
      );

      debugPrint('[KYC Status Check (1109)] Request user_id: $userId, token: $token');
      debugPrint('[KYC Status Check (1109)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      }
    } catch (e) {
      debugPrint('Error in checkKycStatus: $e');
    }
    return null;
  }
}
