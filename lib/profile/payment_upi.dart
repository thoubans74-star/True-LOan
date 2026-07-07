import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tm/api_services/razorpay_service.dart';
import 'package:tm/theme_manager.dart';

class PaymentUpiBody extends StatefulWidget {
  final String planName;
  final String planPrice;
  final String planDuration;
  final List<String> planFeatures;

  const PaymentUpiBody({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
    required this.planFeatures,
  });

  @override
  State<PaymentUpiBody> createState() => _PaymentUpiBodyState();
}

class _PaymentUpiBodyState extends State<PaymentUpiBody> {
  final _upiController = TextEditingController();
  bool _isVerified = false;
  int _selectedApp = -1; // -1 means none selected

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
          'Payment Failed: ${response.message ?? "Unknown error"}',
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
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pay via UPI ID ──
          Text(
            'Pay via UPI ID',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          SizedBox(height: 12.h),

          // UPI ID Input with Verify button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: context.isDarkMode ? context.inputBg : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _upiController,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: context.textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter VPA (e.g. mobile@upi)',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: context.isDarkMode ? Colors.white24 : const Color(0xFF94A3B8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      if (_isVerified) {
                        setState(() {
                          _isVerified = false;
                        });
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_upiController.text.isNotEmpty) {
                      setState(() {
                        _isVerified = true;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _isVerified
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF004AC6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _isVerified ? 'VERIFIED' : 'VERIFY',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Security note
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12.w,
                color: context.subTextColor,
              ),
              SizedBox(width: 4.w),
              Text(
                'Your VPA is securely handled via encrypted gateways.',
                style: GoogleFonts.poppins(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w400,
                  color: context.subTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // ── Quick Select Popular Apps ──
          Text(
            'QUICK SELECT POPULAR APPS',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: context.subTextColor,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 14.h),

          Row(
            children: [
              Expanded(
                child: _buildUpiAppButton(0, 'assets/payment/gpay.png', 'Google Pay',
                    const Color(0xFF4285F4)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildUpiAppButton(1, 'assets/payment/phonepe.png', 'PhonePe',
                    const Color(0xFF5F259F)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildUpiAppButton(
                    2, 'assets/payment/paytm.png', 'Paytm',
                    const Color(0xFF00BAF2)),
              ),
            ],
          ),
          SizedBox(height: 28.h),

          // ── Order Summary (matching Card screen) ──
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
          ),
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

  // ── UPI App Button ──
  Widget _buildUpiAppButton(
      int index, String imagePath, String label, Color color) {
    final isSelected = _selectedApp == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedApp = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : (context.isDarkMode ? context.cardBg : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : context.borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                imagePath,
                width: 40.w,
                height: 40.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : context.subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
