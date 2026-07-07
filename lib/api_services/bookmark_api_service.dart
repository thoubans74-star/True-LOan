import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  /// Toggles bookmark for a Borrower (type 1116)
  /// Returns the wishlist_status (1 = added, 0 = removed) or null on error
  static Future<int?> toggleBorrowerBookmark({
    required String loanId,
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '234';
      final String ln = prefs.getString('ln') ?? '445';
      final String lt = prefs.getString('lt') ?? '345';
      final String token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'cid': '21472147',
          'type': '1116',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'loan_id': loanId,
          'user_id': userId,
          'token': token,
        },
      );

      debugPrint('[Bookmark API (1116)] Request: device_id: $deviceId, loan_id: $loanId, user_id: $userId');
      debugPrint('[Bookmark API (1116)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['error'] == false) {
          final dynamic status = responseData['wishlist_status'];
          return int.tryParse(status.toString()) ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error in toggleBorrowerBookmark: $e');
    }
    return null;
  }

  /// Toggles bookmark for a Lender (type 1117)
  /// Returns the wishlist_status (1 = added, 0 = removed) or null on error
  static Future<int?> toggleLenderBookmark({
    required String loanId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '234';
      final String ln = prefs.getString('ln') ?? '445';
      final String lt = prefs.getString('lt') ?? '345';
      final String token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'cid': '21472147',
          'type': '1117',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'loan_id': loanId,
          'token': token,
        },
      );

      debugPrint('[Bookmark API (1117)] Request: device_id: $deviceId, loan_id: $loanId');
      debugPrint('[Bookmark API (1117)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['error'] == false) {
          final dynamic status = responseData['wishlist_status'];
          return int.tryParse(status.toString()) ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error in toggleLenderBookmark: $e');
    }
    return null;
  }

  /// Fetches bookmarked entries from table 10501 (type 1110, form sm_main_form_10501)
  static Future<List<Map<String, dynamic>>?> fetchBookmarks() async {
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
          'form': 'sm_main_form_10501',
        },
      );

      debugPrint('[Bookmark API (1110)] Fetch request: device_id: $deviceId');
      debugPrint('[Bookmark API (1110)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['error'] == false && responseData['data'] != null) {
          final List<dynamic> list = responseData['data'];
          return list.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error in fetchBookmarks: $e');
    }
    return null;
  }
}
