import 'package:shared_preferences/shared_preferences.dart';

class PlaystoreMock {
  static const String mockMobile = '7777799999';
  static const String mockOtp = '876754';
  static const String mockUserId = '57';
  static const String mockToken = '9e448fa08affe89a96b1d2cb42ab0856';

  /// Checks if the input mobile number matches the Play Store mock mobile
  static bool isPlaystoreUser(String mobile) {
    return mobile == mockMobile;
  }

  /// Checks if the current user qualifies for automatic 10-second KYC approval
  static Future<bool> shouldAutoApproveKyc() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String currentUserId = prefs.getString('user_id') ?? '';
      return currentUserId == mockUserId;
    } catch (_) {
      return false;
    }
  }

  /// Returns static mock response for type 1100 (sendOtp)
  static Map<String, dynamic> mockSendOtpResponse() {
    return {
      "error": false,
      "error_msg": "Allow to next page",
      "user_id": int.parse(mockUserId),
      "cid": 21472147,
      "comp_name": "TRUE MONEY",
      "otp": mockOtp,
      "mobile": mockMobile,
      "device_id": "13",
      "f_token": mockToken,
      "app_signature": "itufuifyfufu",
      "is_new_user": false
    };
  }

  /// Returns static mock response for type 1101 (verifyOtp)
  static Map<String, dynamic> mockVerifyOtpResponse() {
    return {
      "error": false,
      "error_msg": "OTP Verified Successfully",
      "user_id": int.parse(mockUserId),
      "token": mockToken,
      "is_new_user": false
    };
  }
}
