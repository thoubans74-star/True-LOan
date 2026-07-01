import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MarketplaceApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  /// Fetches raw lenders list from type 1110 API (form: sm_main_form_10201)
  static Future<List<Map<String, dynamic>>?> fetchLenders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '234';
      final String ln = prefs.getString('ln') ?? '445';
      final String lt = prefs.getString('lt') ?? '345';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'type': '1110',
          'cid': '21472147',
          'device_id': deviceId,
          'ln': ln,
          'lt': lt,
          'form': 'sm_main_form_10201',
        },
      );

      debugPrint('[Marketplace API (1110)] Lenders Request: device_id: $deviceId, ln: $ln, lt: $lt');
      debugPrint('[Marketplace API (1110)] Lenders Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['error'] == false && responseData['data'] != null) {
          final List<dynamic> list = responseData['data'];
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error in fetchLenders: $e');
    }
    return null;
  }

  /// Fetches user profiles from type 1110 API (form: sm_main_form_10001)
  static Future<List<Map<String, dynamic>>?> fetchProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '234';
      final String ln = prefs.getString('ln') ?? '445';
      final String lt = prefs.getString('lt') ?? '345';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'type': '1110',
          'cid': '21472147',
          'device_id': deviceId,
          'ln': ln,
          'lt': lt,
          'form': 'sm_main_form_10001',
        },
      );

      debugPrint('[Marketplace API (1110)] Profiles Request: device_id: $deviceId, ln: $ln, lt: $lt');
      debugPrint('[Marketplace API (1110)] Profiles Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['error'] == false && responseData['data'] != null) {
          final List<dynamic> list = responseData['data'];
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error in fetchProfiles: $e');
    }
    return null;
  }

  /// Fetches raw borrowers list from type 1110 API (form: sm_main_form_10101)
  static Future<List<Map<String, dynamic>>?> fetchBorrowers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '234';
      final String ln = prefs.getString('ln') ?? '445';
      final String lt = prefs.getString('lt') ?? '345';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'type': '1110',
          'cid': '21472147',
          'device_id': deviceId,
          'ln': ln,
          'lt': lt,
          'form': 'sm_main_form_10101',
        },
      );

      debugPrint('[Marketplace API (1110)] Borrowers Request: device_id: $deviceId, ln: $ln, lt: $lt');
      debugPrint('[Marketplace API (1110)] Borrowers Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['error'] == false && responseData['data'] != null) {
          final List<dynamic> list = responseData['data'];
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error in fetchBorrowers: $e');
    }
    return null;
  }
}
