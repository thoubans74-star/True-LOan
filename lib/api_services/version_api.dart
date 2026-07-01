import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppUpdateModel {
  final bool error;
  final String status;
  final bool updateRequired;
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String message;
  final String uid;

  AppUpdateModel({
    required this.error,
    required this.status,
    required this.updateRequired,
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.message,
    required this.uid,
  });

  factory AppUpdateModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateModel(
      error: json['error'] ?? false,
      status: json['status'] ?? '',
      updateRequired: json['update_required'] ?? false,
      currentVersion: json['current_version']?.toString() ?? '',
      latestVersion: json['latest_version']?.toString() ?? '',
      downloadUrl: json['download_url'] ?? '',
      message: json['message'] ?? '',
      uid: json['uid'] ?? '',
    );
  }
}

class VersionApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  static Future<AppUpdateModel?> checkVersion(String version) async {
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
          'type': '1114',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'version': version,
        },
      );

      debugPrint('[Version API Check (1114)] Request version: $version, device_id: $deviceId, ln: $ln, lt: $lt');
      debugPrint('[Version API Check (1114)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return AppUpdateModel.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error in checkVersion: $e');
    }
    return null;
  }
}
