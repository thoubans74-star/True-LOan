import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/theme_manager.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tm/api_services/razorpay_service.dart';
import '../utils/app_snackbar.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  int _selectedPlanIndex =
      0; // 0 for Free Tier, 1 for Boost Your Reach, 2 for Unlimited Pro Plan

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
    showAppSnackBar(context, 'Payment Successful! ID: ${response.paymentId}', isError: false);
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    showAppSnackBar(context, 'Payment Failed: ${response.message ?? 'Unknown error'}', isError: true);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    showAppSnackBar(context, 'External Wallet: ${response.walletName}', isError: false);
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      body: Column(
        children: [
          // ── Blue AppBar (Same header design like Ads/MarketPlace/Edit Profile) ──
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
                      'Subscription Plan',
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

          // ── Scrollable Body ──
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 18, 20, 26),
              child: Column(
                children: [
                  // ── Plan 1: Free Tier ──
                  _buildPlanCard(
                    index: 0,
                    backgroundColor: const Color(0xFFF6FDF9),
                    selectedBorderColor: const Color(0xFF15803D),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Gift icon box
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color:  Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.redeem_rounded,
                                color: Color(0xFF15803D),
                                size: 22.w,
                              ),
                            ),
                            // NEW USER badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color:  Color(0xFF065F46),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'NEW USER',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Free Tier',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: context.textColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Your First Ad is On Us. Experience the power of TrueMoney at zero cost.',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: context.subTextColor,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // Bullet features
                        _buildFeatureRow(
                          Icons.check_circle_outline_rounded,
                          'Standard Listing',
                        ),
                        SizedBox(height: 8.h),
                        _buildFeatureRow(
                          Icons.check_circle_outline_rounded,
                          'Basic Analytics',
                        ),
                        SizedBox(height: 8.h),
                        _buildFeatureRow(
                          Icons.check_circle_outline_rounded,
                          '1 Free Ad Post',
                        ),
                        SizedBox(height: 28.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹0',
                              style: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'FOREVER FREE',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF15803D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── Plan 2: Boost Your Reach ──
                  _buildPlanCard(
                    index: 1,
                    backgroundColor: const Color(0xFFFAF5FF),
                    selectedBorderColor: const Color(0xFFE4D4F5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Bolt icon box
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color:  Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.bolt_rounded,
                                color: Color(0xFF9333EA),
                                size: 22.w,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Boost Your Reach',
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: context.textColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Get instant visibility for individual listings with premium placement.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: context.subTextColor,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // Bullet features
                        _buildFeatureRow(
                          Icons.check_circle_outline_rounded,
                          'Priority Listing (Top 5%)',
                        ),
                        SizedBox(height: 8.h),
                        _buildFeatureRow(
                          Icons.check_circle_outline_rounded,
                          'Verified Seller Badge',
                        ),
                        SizedBox(height: 8.h),
                        _buildFeatureRow(
                          Icons.trending_up_rounded,
                          '2x Visibility for 7 days',
                        ),
                        SizedBox(height: 28.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                  Text(
                                    '₹499',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w800,
                                      color: context.textColor,
                                    ),
                                  ),
                                  Text(
                                    '/ad',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.subTextColor,
                                    ),
                                  ),
                              ],
                            ),
                            // MOST POPULAR badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color:  Color(0xFFFCE7F3),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'MOST POPULAR',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA13454),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── Plan 3: Unlimited Pro Plan ──
                  _buildPlanCard(
                    index: 2,
                    backgroundColor: const Color(0xFFF8FAFC),
                    selectedBorderColor: const Color(0xFF4F46E5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Badge icon box
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color:  Color(0xFFEEF2F6),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFF6366F1),
                                size: 22.w,
                              ),
                            ),
                            // PRO MEMBER badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color:  Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFF7C3AED),
                                    size: 12.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'PRO MEMBER',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF7C3AED),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Unlimited Pro Plan',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: context.textColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'The ultimate solution for high-volume advertisers and professional agents.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: context.subTextColor,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Stats row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.inputBg,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: context.borderColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AD LIMIT',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700,
                                        color:  Color(0xFF7C3AED),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Unlimited',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: context.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.inputBg,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: context.borderColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SUPPORT',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700,
                                        color:  Color(0xFF7C3AED),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '24/7 Priority',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: context.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹1,999',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w800,
                                    color: context.textColor,
                                  ),
                                ),
                                Text(
                                  '/mo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: context.subTextColor,
                                  ),
                                ),
                              ],
                            ),
                            // BEST VALUE badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:  Color(0xFFBE123C),
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'BEST VALUE',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFBE123C),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Action Button ──
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: context.navBarBg,
              boxShadow: [
                BoxShadow(
                  color: context.isDarkMode ? Colors.black38 : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(top: BorderSide(color: context.dividerColor)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  final planData = [
                    {
                      'name': 'Free Tier',
                      'price': '₹0',
                      'duration': 'free',
                      'features': [
                        'Standard Listing',
                        'Basic Analytics',
                        '1 Free Ad Post',
                      ],
                    },
                    {
                      'name': 'Boost Your Reach',
                      'price': '₹499',
                      'duration': 'ad',
                      'features': [
                        'Priority Listing (Top 5%)',
                        'Verified Seller Badge',
                        '2x Visibility for 7 days',
                      ],
                    },
                    {
                      'name': 'Unlimited Pro Plan',
                      'price': '₹1999',
                      'duration': 'month',
                      'features': [
                        'Advanced Analytics Dashboard',
                        'Unlimited Requests per month',
                        'Smart AI Matching Engine',
                      ],
                    },
                  ];
                  final selected = planData[_selectedPlanIndex];
                  final priceStr = selected['price'] as String;
                  final amountInPaise = RazorpayService.priceToPaise(priceStr);

                  if (amountInPaise > 0) {
                    _razorpayService.openCheckout(
                      amountInPaise: amountInPaise,
                      planName: '${selected['name']} - ${selected['duration']}',
                    );
                  } else {
                    // Free tier
                    showAppSnackBar(context, '${selected['name']} activated successfully!', isError: false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF004AC6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Payment',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required Color backgroundColor,
    required Color selectedBorderColor,
    required Widget child,
  }) {
    final bool isSelected = _selectedPlanIndex == index;
    final cardBgColor = context.isDarkMode ? context.cardBg : backgroundColor;
    final cardBorderColor = context.isDarkMode
        ? (isSelected ? selectedBorderColor : context.borderColor)
        : (isSelected ? selectedBorderColor : const Color(0xFFE2E8F0));
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration:  Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: cardBorderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Icon(icon, color:  Color(0xFF15803D), size: 16.w),
            SizedBox(width: 8.w),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: context.subTextColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
