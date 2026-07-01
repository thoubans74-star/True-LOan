import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppUpdatesApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  /// Checks for application updates using type 1114 API
  static Future<Map<String, dynamic>?> checkAppUpdates({
    required String version,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String rawDeviceId = prefs.getString('device_id') ?? '';
      final String rawLn = prefs.getString('ln') ?? '';
      final String rawLt = prefs.getString('lt') ?? '';

      final String deviceId = rawDeviceId.isNotEmpty ? rawDeviceId : '13';
      final String ln = rawLn.isNotEmpty ? rawLn : '11';
      final String lt = rawLt.isNotEmpty ? rawLt : '11';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'cid': '21472147',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'type': '1114',
          'version': version,
        },
      );

      debugPrint('[App Update Check (1114)] Request version: $version, device_id: $deviceId, ln: $ln, lt: $lt');
      debugPrint('[App Update Check (1114)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error in checkAppUpdates: $e');
    }
    return null;
  }
}
