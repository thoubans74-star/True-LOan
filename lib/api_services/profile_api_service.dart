import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tm/api_services/marketplace_api_service.dart';

class ProfileApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  static final ValueNotifier<String> nameNotifier = ValueNotifier<String>('Profile');
  static final ValueNotifier<String?> profileImageNotifier = ValueNotifier<String?>(null);

  static Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    nameNotifier.value = prefs.getString('name') ?? 'Profile';
    profileImageNotifier.value = prefs.getString('profile_image');
  }

  /// Fetches profile details from the server using the type 1104 API
  static Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('user_id') ?? '33';
      final String token = prefs.getString('token') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '5';
      final String lt = prefs.getString('lt') ?? '11';
      final String ln = prefs.getString('ln') ?? '11';

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'cid': '21472147',
          'ln': ln,
          'lt': lt,
          'user_id': userId,
          'type': '1104',
          'device_id': deviceId,
          if (token.isNotEmpty) 'token': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final data = responseData['data'];
          // Cache the profile details
          await prefs.setString(
            'user_id',
            data['user_id']?.toString() ?? userId,
          );
          final String nameVal = data['name']?.toString() ?? '';
          final String imageVal = data['profile_image']?.toString() ?? '';
          await prefs.setString('name', nameVal);
          await prefs.setString('mobile', data['mobile']?.toString() ?? '');
          await prefs.setString('email', data['email']?.toString() ?? '');
          await prefs.setString('profile_image', imageVal);
          await prefs.setString('address', data['address']?.toString() ?? '');
          await prefs.setString('pincode', data['pincode']?.toString() ?? '');
          await prefs.setString('state', data['state']?.toString() ?? '');
          await prefs.setString('district', data['district']?.toString() ?? '');
          if (data['token'] != null) {
            await prefs.setString('token', data['token']?.toString() ?? '');
          }
          nameNotifier.value = nameVal.isEmpty ? 'Profile' : nameVal;
          profileImageNotifier.value = imageVal;
          return responseData;
        }
      }
    } catch (e) {
      debugPrint('Error in fetchProfile: $e');
    }
    return null;
  }

  /// Updates profile details on the server using the type 1103 multipart/form-data API
  static Future<Map<String, dynamic>?> updateProfile({
    required String name,
    required String email,
    required String mobile,
    String? address,
    String? pincode,
    String? state,
    String? district,
    PlatformFile? pickedFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString('user_id') ?? '33';
      final String token = prefs.getString('token') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '13';
      final String lt = prefs.getString('lt') ?? '11';
      final String ln = prefs.getString('ln') ?? '11';

      final uri = Uri.parse(baseUrl);
      final request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'cid': '21472147',
        'ln': ln,
        'lt': lt,
        'device_id': deviceId,
        'type': '1103',
        'mobile': mobile,
        'name': name,
        'email': email,
        'user_id': userId,
        if (token.isNotEmpty) 'token': token,
        if (address != null) 'address': address,
        if (pincode != null) 'pincode': pincode,
        if (state != null) 'state': state,
        if (district != null) 'district': district,
      });

      if (pickedFile != null) {
        if (kIsWeb) {
          if (pickedFile.bytes != null) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'profile_image',
                pickedFile.bytes!,
                filename: pickedFile.name,
              ),
            );
          }
        } else {
          if (pickedFile.path != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'profile_image',
                pickedFile.path!,
                filename: pickedFile.name,
              ),
            );
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('[Profile Update (1103)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final status = responseData['status'];
        if ((status == 'success' || status == true || status?.toString() == 'true') &&
            responseData['data'] != null) {
          final data = responseData['data'];
          // Cache the updated profile details
          await prefs.setString(
            'user_id',
            data['user_id']?.toString() ?? userId,
          );
          await prefs.setString(
            'mobile',
            data['phone']?.toString() ?? data['mobile']?.toString() ?? mobile,
          );
          final String nameVal = data['name']?.toString() ?? name;
          final String imageVal = data['profile_image']?.toString() ?? '';
          await prefs.setString('name', nameVal);
          await prefs.setString('email', data['email']?.toString() ?? email);
          await prefs.setString('profile_image', imageVal);
          await prefs.setString('address', data['address']?.toString() ?? address ?? '');
          await prefs.setString('pincode', data['pincode']?.toString() ?? pincode ?? '');
          await prefs.setString('state', data['state']?.toString() ?? state ?? '');
          await prefs.setString('district', data['district']?.toString() ?? district ?? '');
          if (data['token'] != null) {
            await prefs.setString('token', data['token']?.toString() ?? '');
          }
          nameNotifier.value = nameVal.isEmpty ? 'Profile' : nameVal;
          profileImageNotifier.value = imageVal;
          return responseData;
        }
      }
    } catch (e) {
      debugPrint('Error in updateProfile: $e');
    }
    return null;
  }

  /// Checks the user's lenders and borrowers ads counts and caches the premium role
  static Future<void> cacheUserPremiumRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String currentUserId = prefs.getString('user_id') ?? '';
      if (currentUserId.isEmpty) return;

      final lenders = await MarketplaceApiService.fetchLenders();
      final borrowers = await MarketplaceApiService.fetchBorrowers();

      int lenderCount = 0;
      int borrowerCount = 0;

      if (lenders != null) {
        lenderCount = lenders
            .where((l) => l['ledger_name']?.toString() == currentUserId)
            .length;
      }
      if (borrowers != null) {
        borrowerCount = borrowers
            .where((b) => b['ledger_name']?.toString() == currentUserId)
            .length;
      }

      if (lenderCount >= borrowerCount) {
        await prefs.setString('user_role_premium', 'Premium Buyer - Lender');
      } else {
        await prefs.setString('user_role_premium', 'Premium Buyer - Borrower');
      }
      debugPrint(
        '[Profile API] Cached user role premium: ${prefs.getString('user_role_premium')} (lenders: $lenderCount, borrowers: $borrowerCount)',
      );
    } catch (e) {
      debugPrint('Error in cacheUserPremiumRole: $e');
    }
  }
}
