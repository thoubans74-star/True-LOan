import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GiveALoanApiService {
  static const String baseUrl = 'https://trueloan.ai.in/ai/api/m_api/';

  /// Submits the Give a Loan form data to the server (type 1111)
  static Future<Map<String, dynamic>?> submitGiveALoan({
    required String loanType,
    required String loanAmt,
    required String interest,
    required String loanTenure,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storedDeviceId = prefs.getString('device_id') ?? '';
      final String deviceId = storedDeviceId.isEmpty ? '13' : storedDeviceId;
      final String storedLn = prefs.getString('ln') ?? '';
      final String ln = storedLn.isEmpty ? '11' : storedLn;
      final String storedLt = prefs.getString('lt') ?? '';
      final String lt = storedLt.isEmpty ? '11' : storedLt;
      final String storedUserId = prefs.getString('user_id') ?? '';
      final String userId = storedUserId.isEmpty ? '' : storedUserId;

      final response = await http.post(
        Uri.parse(baseUrl),
        body: {
          'type': '1111',
          'cid': '21472147',
          'device_id': deviceId,
          'ln': ln,
          'lt': lt,
          'form': 'sm_main_form_10201',
          'ledger_name': userId,
          'loan_type': loanType,
          'loan_amt': loanAmt,
          'interest': interest,
          'loan_tenure': loanTenure,
        },
      );

      debugPrint('[Give A Loan Submit (1111)] Request device_id: $deviceId, ln: $ln, lt: $lt, ledger_name: $userId');
      debugPrint('[Give A Loan Submit (1111)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      }
    } catch (e) {
      debugPrint('Error in submitGiveALoan: $e');
    }
    return null;
  }
}
