import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tm/api_services/razorpay_service.dart';
import 'package:tm/theme_manager.dart';
import 'payment_upi.dart';

class PaymentCardScreen extends StatefulWidget {
  final String planName;
  final String planPrice;
  final String planDuration;
  final List<String> planFeatures;

  const PaymentCardScreen({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
    required this.planFeatures,
  });

  @override
  State<PaymentCardScreen> createState() => _PaymentCardScreenState();
}

class _PaymentCardScreenState extends State<PaymentCardScreen> {
  int _selectedTab = 0; // 0 = Card, 1 = UPI
  bool _saveCard = false;

  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService(
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentFailure,
      onWallet: _onExternalWallet,
    );
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Successful! ID: ${response.paymentId}',
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
    // TODO: Call your backend to verify payment & activate subscription
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Failed: ${response.message ?? 'Unknown error'}',
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'External Wallet: ${response.walletName}',
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        backgroundColor: const Color(0xFF004AC6),
      ),
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      body: Column(
        children: [
          // ── Blue AppBar ──
          Container(
            color: const Color(0xFF004AC6),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                    Text(
                      'Payment',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Tab Switcher (Card / UPI) ──
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: context.inputBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    index: 0,
                    icon: Icons.credit_card_rounded,
                    label: 'Card',
                  ),
                  _buildTabButton(
                    index: 1,
                    icon: Icons.account_balance_rounded,
                    label: 'UPI',
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          Expanded(
            child: _selectedTab == 0 ? _buildCardBody() : PaymentUpiBody(
              planName: widget.planName,
              planPrice: widget.planPrice,
              planDuration: widget.planDuration,
              planFeatures: widget.planFeatures,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Button ──
  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? context.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.isDarkMode ? Colors.black26 : Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.w,
                color: isSelected
                    ? const Color(0xFF004AC6)
                    : context.subTextColor,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? context.textColor
                      : context.subTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card Payment Body ──
  Widget _buildCardBody() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Form ──
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cardholder Name
                Text(
                  'CARDHOLDER NAME',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: context.subTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _cardholderController,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: context.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'John Doe',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: context.isDarkMode ? Colors.white24 : const Color(0xFFCBD5E1),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: context.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: context.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF004AC6),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Card Number
                Text(
                  'CARD NUMBER',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: context.subTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: context.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: '0000 0000 0000 0000',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: context.isDarkMode ? Colors.white24 : const Color(0xFFCBD5E1),
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Icon(
                        Icons.credit_card_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 22.w,
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 40.w,
                      minHeight: 20.h,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: context.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: context.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF004AC6),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Expiry Date & CVV
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPIRY DATE',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: context.subTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: _expiryController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryDateFormatter(),
                            ],
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: context.textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'MM / YY',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: context.isDarkMode ? Colors.white24 : const Color(0xFFCBD5E1),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                  color: context.borderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                  color: context.borderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF004AC6),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CVV',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: context.subTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: context.textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: '***',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: context.isDarkMode ? Colors.white24 : const Color(0xFFCBD5E1),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                  color: context.borderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                  color: context.borderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF004AC6),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Save card checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: Checkbox(
                        value: _saveCard,
                        onChanged: (val) {
                          setState(() {
                            _saveCard = val ?? false;
                          });
                        },
                        activeColor: const Color(0xFF004AC6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Save card details for future payments',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: context.subTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),

                // Security Badges inside card
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 12.w, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 3.w),
                        Text('SSL SECURE', style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8), letterSpacing: 0.3)),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Row(
                      children: [
                        Icon(Icons.verified_user_outlined, size: 12.w, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 3.w),
                        Text('PCI COMPLIANT', style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8), letterSpacing: 0.3)),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 12.w, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 3.w),
                        Text('ENCRYPTED', style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8), letterSpacing: 0.3)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),


          // ── Order Summary ──
          _buildOrderSummary(),
          SizedBox(height: 20.h),

          // ── Security Notice ──
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: context.isDarkMode ? const Color(0xFF102E42) : const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: const Color(0xFF16A34A),
                    size: 16.w,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Your transaction is secure with SSL encryption. True Money does not store your full card details.',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: context.subTextColor,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // ── Pay Button ──
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                final amountInPaise = RazorpayService.priceToPaise(widget.planPrice);
                if (amountInPaise > 0) {
                  _razorpayService.openCheckout(
                    amountInPaise: amountInPaise,
                    planName: '${widget.planName} - ${widget.planDuration}',
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Invalid plan price',
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AC6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pay ${widget.planPrice} Now',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 18.w,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── PCI-DSS Footer ──
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/payment/pci.png',
                  width: 15.w,
                  height: 15.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  'PCI-DSS COMPLIANT GATEWAY',
                  style: GoogleFonts.poppins(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }


  // ── Order Summary ──
  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Summary',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: context.isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: context.isDarkMode ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  'BEST VALUE',
                  style: GoogleFonts.poppins(
                    fontSize: 6.sp,
                    fontWeight: FontWeight.w700,
                    color: context.isDarkMode ? Colors.white : const Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'YEARLY SUBSCRIPTION',
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: context.subTextColor,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),

          // Plan name & price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.planName,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004AC6),
                ),
              ),
              Text(
                widget.planPrice,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Features
          ...widget.planFeatures.map(
            (feature) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFF16A34A),
                    size: 16.w,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: context.subTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Divider
          Divider(color: context.dividerColor, thickness: 1),
          SizedBox(height: 12.h),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: context.subTextColor,
                ),
              ),
              Text(
                widget.planPrice,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: context.subTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Tax
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax (GST 0%)',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: context.subTextColor,
                ),
              ),
              Text(
                '\$0.00',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: context.subTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 16.41.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
              Text(
                widget.planPrice,
                style: GoogleFonts.poppins(
                  fontSize: 16.41.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Card Number Formatter (adds spaces every 4 digits) ──
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// ── Expiry Date Formatter (MM/YY) ──
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write(' / ');
      buffer.write(text[i]);
    }
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
