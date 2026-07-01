import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/create_ad_screen.dart';
import 'bank_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'guest_restriction_dialog.dart';

class BusinessLoanCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const BusinessLoanCard({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isSelected ? const Color(0xFFC99A2E) : const Color(0xFFFFF4DC);
    final labelColor = isSelected ? Colors.white : const Color(0xFFB4690E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160.w,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFC99A2E) : const Color(0xFFFFDC8B),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFC99A2E).withValues(alpha: 0.4),
                    offset: const Offset(0, 6),
                    blurRadius: 16,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  )
                ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon
            Image.asset(
              'assets/new_home/bussiness_loan.png',
              width: 40.w,
              height: 40.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 6.w),

            // Card details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUSSINESS LOAN',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 2.w),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                    children: [
                      TextSpan(
                        text: 'Starting from\n',
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF171D17),
                        ),
                      ),
                      TextSpan(
                        text: '11.0% p.a.',
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF006B2A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),

            // Divider Line
            Container(
              height: 0.5,
              color: isSelected ? Colors.white :  Color(0xFF475569),
            ),
            SizedBox(height: 6.w),

            // Bottom row: limit and arrow indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Up to ₹1 Cr',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
                isSelected
                    ? Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20.w,
                      )
                    : Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFC5922F),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 14.w,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessLoanBottomCard extends StatelessWidget {
  const BusinessLoanBottomCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lenders = [
      {
        'name': 'Axis Bank',
        'logoText': 'AX',
        'logoBg': const Color(0xFF900C3F),
        'badge': 'BANK',
        'rate': '11.0% p.a.',
      },
      {
        'name': 'Tata Capital',
        'logoText': 'TC',
        'logoBg': const Color(0xFF009688),
        'badge': 'NBFC',
        'rate': '11.5% p.a.',
      },
      {
        'name': 'Bajaj Finance',
        'logoText': 'BF',
        'logoBg': const Color(0xFFF05A28),
        'badge': 'NBFC',
        'rate': '12.0% p.a.',
      },
    ];

    return SizedBox(
      height: 190.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics:  ClampingScrollPhysics(),
        padding: EdgeInsets.only(left: 20.w, right: 6.w),
        itemCount: lenders.length,
        itemBuilder: (context, index) {
          final lender = lenders[index];
          return Padding(
            padding: EdgeInsets.only(right: 14.w, bottom: 4.w),
            child: _buildLenderCard(context, lender),
          );
        },
      ),
    );
  }

  Widget _buildLenderCard(BuildContext context, Map<String, dynamic> lender) {
    return Container(
      width: 210.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEEF2F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: lender['logoBg'] as Color,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  lender['logoText'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lender['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF171D17),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.w),
                      decoration: BoxDecoration(
                        color:  Color(0xFFE8F2FF),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        lender['badge'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A6AE8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Loan',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color:  Color(0xFF7F8C8D),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                lender['rate'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF0050CC),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              final bankData = getBankOfferByName(lender['name'] as String);
              showBankOfferDialog(context, bankData);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.w),
              decoration: BoxDecoration(
                color:  Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'View Offer',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A6AE8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Business Loan Bottom Sheet ──────────────────────────────────────────────
void showBusinessLoanBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (context) => const BusinessLoanBottomSheet(),
  );
}

class BusinessLoanBottomSheet extends StatelessWidget {
  const BusinessLoanBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color:  Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Image.asset(
                        'assets/new_home/bussiness_loan.png',
                        width: 48.w,
                        height: 48.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.business, size: 48.w, color: Color(0xFF061A5C)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Loan Details',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color:  Color(0xFF1A1A2E),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Text(
                                  'POWERED BY  ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF7F8C8D),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color:  Color(0xFFE8F0FE),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8.w,
                                        height: 8.h,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF0050CC),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Bajaj Finance',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0050CC),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Interest / Max Amount / Tenure Bar
                  _buildInfoBar(),
                  SizedBox(height: 24.h),

                  // Key Features
                  Text(
                    'Key Features',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color:  Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  _buildFeatureItem(
                    Icons.shield_outlined,
                    'No Collateral Required',
                    'For loans up to ₹50L',
                  ),
                  SizedBox(height: 16.h),
                  _buildFeatureItem(
                    Icons.swap_horiz,
                    'Flexible End-use',
                    'Use funds for any business need',
                  ),
                  SizedBox(height: 16.h),
                  _buildFeatureItem(
                    Icons.description_outlined,
                    'Minimal Documentation',
                    'Hassle-free digital application',
                  ),
                  SizedBox(height: 16.h),
                  _buildFeatureItem(
                    Icons.bolt,
                    'Quick Disbursal',
                    'Funds in your bank within 24-48 hrs',
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          // Fixed bottom section
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF03C68A), Color(0xFF00B87C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'INTEREST',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '11.0%p.a.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36.h, color: Colors.white.withValues(alpha: 0.3)),
          Expanded(
            child: Column(
              children: [
                Text(
                  'MAX AMOUNT',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹2 Cr',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36.h, color: Colors.white.withValues(alpha: 0.3)),
          Expanded(
            child: Column(
              children: [
                Text(
                  'TENURE',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '5 Yrs',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color:  Color(0xFFE6F9F1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color:  Color(0xFF03C68A), size: 20.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color:  Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final String userId = prefs.getString('user_id') ?? '';
              if (userId.isEmpty) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => const GuestRestrictionDialog(),
                  );
                }
                return;
              }

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const CreateAdScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color:  Color(0xFF0266FF),
                borderRadius: BorderRadius.circular(28.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Apply Now',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'No hidden charges • Secure Application',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }
}
