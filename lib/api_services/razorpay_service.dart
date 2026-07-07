import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Razorpay Payment Service
///
/// Handles all Razorpay payment operations.
/// Keys are static for now — will be replaced with API-fetched keys later.
class RazorpayService {
  // ── Static Razorpay Credentials ──

  static const String _keyId = 'rzp_live_0JaXxZHLE0HNDj';

  late Razorpay _razorpay;

  // Callbacks
  final void Function(PaymentSuccessResponse)? onSuccess;
  final void Function(PaymentFailureResponse)? onFailure;
  final void Function(ExternalWalletResponse)? onWallet;

  RazorpayService({
    this.onSuccess,
    this.onFailure,
    this.onWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // ── Open Razorpay Checkout ──
  /// [amountInPaise] — amount in paise (e.g., ₹499 = 49900)
  /// [planName] — description shown on checkout
  /// [contactNumber] — user's phone number
  /// [email] — user's email address
  Future<void> openCheckout({
    required int amountInPaise,
    required String planName,
    String? contactNumber,
    String? email,
    String? orderId,
  }) async {
    String finalKeyId = _keyId;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '32';
      final String ln = prefs.getString('ln') ?? '12';
      final String lt = prefs.getString('lt') ?? '22';

      final response = await http.post(
        Uri.parse('https://trueloan.ai.in/ai/api/m_api/'),
        body: {
          'cid': '21472147',
          'type': '1118',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
        },
      );

      debugPrint('[Razorpay API (1118)] Request: device_id: $deviceId, ln: $ln, lt: $lt');
      debugPrint('[Razorpay API (1118)] Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['pay_key'] != null) {
          finalKeyId = responseData['pay_key'].toString();
          debugPrint('Fetched dynamic Razorpay key successfully: $finalKeyId');
        }
      }
    } catch (e) {
      debugPrint('Error fetching dynamic Razorpay key: $e. Falling back to static key.');
    }

    final options = <String, dynamic>{
      'key': finalKeyId,
      'amount': amountInPaise,
      'name': 'True Loan',
      'description': planName,
      'retry': {'enabled': true, 'max_count': 3},
      'send_sms_hash': true,
      'prefill': {
        'contact': contactNumber ?? '',
        'email': email ?? '',
      },
      'theme': {
        'color': '#004AC6',
      },
    };

    // If an order_id is provided (from your backend), attach it
    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
    }
  }

  // ── Internal Handlers ──

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success: ${response.paymentId}');
    debugPrint('   Order ID: ${response.orderId}');
    debugPrint('   Signature: ${response.signature}');
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Failed: ${response.code} | ${response.message}');
    onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet: ${response.walletName}');
    onWallet?.call(response);
  }

  /// Dispose the Razorpay instance when done
  void dispose() {
    _razorpay.clear();
  }

  // ── Utility: Parse price string to paise ──
  /// Converts a price string like "₹499", "₹1,999", "$499" to paise (int).
  /// Returns 0 if parsing fails.
  static int priceToPaise(String priceString) {
    try {
      // Remove currency symbols, commas, spaces
      final cleaned = priceString
          .replaceAll(RegExp(r'[₹$,\s]'), '')
          .replaceAll('/yr', '')
          .replaceAll('/mo', '')
          .replaceAll('/year', '')
          .replaceAll('/month', '')
          .trim();
      final amount = double.parse(cleaned);
      return (amount * 100).round();
    } catch (e) {
      debugPrint('Error parsing price "$priceString": $e');
      return 0;
    }
  }
}
