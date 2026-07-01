import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  /// Fetches the list of states from the type 1113 dropdown API with list_id = 3
  static Future<List<Map<String, dynamic>>> fetchStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '234';
      final String ln = prefs.getString('ln') ?? '445';
      final String lt = prefs.getString('lt') ?? '345';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'type': '1113',
          'cid': '21472147',
          'device_id': deviceId,
          'ln': ln,
          'lt': lt,
          'form': 'sm_main_form_11',
          'list_id': '3',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['error'] == false && data['dropdown'] != null) {
          final List<dynamic> list = data['dropdown'];
          return list.map<Map<String, dynamic>>((item) => <String, dynamic>{
            'id': item['id']?.toString() ?? '',
            'value': item['value']?.toString() ?? '',
            'label': item['label']?.toString() ?? '',
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error in fetchStates: $e');
    }
    return [];
  }

  /// Fetches the list of districts for a given state from the type 1113 dropdown API with list_id = 201
  static Future<List<Map<String, dynamic>>> fetchDistricts(String stateValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '234';
      final String ln = prefs.getString('ln') ?? '445';
      final String lt = prefs.getString('lt') ?? '345';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'type': '1113',
          'cid': '21472147',
          'device_id': deviceId,
          'ln': ln,
          'lt': lt,
          'form': 'sm_main_form_11',
          'list_id': '201',
          'parent_id': stateValue, // bind selected state value as filter
          'parent_value': stateValue,
          'p_val': stateValue,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['error'] == false && data['dropdown'] != null) {
          final List<dynamic> list = data['dropdown'];
          return list.map<Map<String, dynamic>>((item) => <String, dynamic>{
            'id': item['id']?.toString() ?? '',
            'value': item['value']?.toString() ?? '',
            'label': item['label']?.toString() ?? '',
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error in fetchDistricts: $e');
    }
    return [];
  }

  /// Fetches the location data for a given pincode from the type 1115 API
  static Future<Map<String, dynamic>?> autofillPincode(String pincode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '23';
      final String ln = prefs.getString('ln') ?? '13';
      final String lt = prefs.getString('lt') ?? '11';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'cid': '21472147',
          'type': '1115',
          'pincode': pincode,
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if ((data['status'] == true || data['status']?.toString() == 'true') && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error in autofillPincode: $e');
    }
    return null;
  }
}
