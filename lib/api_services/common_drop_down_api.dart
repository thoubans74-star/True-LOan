import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommonDropDownApi {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  /// Fetches drop down options using the type 1113 API
  static Future<Map<String, dynamic>?> fetchDropDownOptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('user_id') ?? '35';
      final String deviceId = prefs.getString('device_id') ?? '234';
      final String lt = prefs.getString('lt') ?? '345';
      final String ln = prefs.getString('ln') ?? '445';
      final String token = prefs.getString('token') ?? 'rt5yuu';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'type': '1113',
          'cid': '21472147',
          'device_id': deviceId,
          'ln': ln,
          'lt': lt,
          'form': 'sm_main_form_11',
          'list_id': '2020',
          'user_id': userId,
          'token': token,
        },
      );

      debugPrint('[Common DropDown (1113)] Request user_id: $userId, token: $token');
      debugPrint('[Common DropDown (1113)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      }
    } catch (e) {
      debugPrint('Error in fetchDropDownOptions: $e');
    }
    return null;
  }
}
