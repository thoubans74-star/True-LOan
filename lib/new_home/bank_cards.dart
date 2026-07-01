import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/create_ad_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'guest_restriction_dialog.dart';

// ── Bank Offer Data Model ────────────────────────────────────────────────────
class BankOfferData {
  final String bankName;
  final String logoText;
  final Color logoBgColor;
  final Color logoTextColor;
  final String interestRate;
  final String loanAmount;
  final String tenure;
  final String maxLoanAmount;
  final String maxLoanFormatted;

  const BankOfferData({
    required this.bankName,
    required this.logoText,
    required this.logoBgColor,
    required this.logoTextColor,
    required this.interestRate,
    required this.loanAmount,
    required this.tenure,
    required this.maxLoanAmount,
    required this.maxLoanFormatted,
  });
}

// ── Predefined Bank Data ─────────────────────────────────────────────────────
List<BankOfferData> bankOffers = [
  BankOfferData(
    bankName: 'HDFC BANK',
    logoText: 'HDFC',
    logoBgColor: Color(0xFFFFFFFF),
    logoTextColor: Color(0xFF0C3C96),
    interestRate: '10.50% p.a.',
    loanAmount: '₹25 Lakhs',
    tenure: '60 months',
    maxLoanAmount: '₹25,00,000',
    maxLoanFormatted: '25,00,000',
  ),
  BankOfferData(
    bankName: 'SBI BANK',
    logoText: 'SBI',
    logoBgColor: Color(0xFFFFFFFF),
    logoTextColor: Color(0xFF00A2E8),
    interestRate: '10.25% p.a.',
    loanAmount: '₹20 Lakhs',
    tenure: '48 months',
    maxLoanAmount: '₹20,00,000',
    maxLoanFormatted: '20,00,000',
  ),
  BankOfferData(
    bankName: 'ICICI BANK',
    logoText: 'ICICI',
    logoBgColor: Color(0xFFFFFFFF),
    logoTextColor: Color(0xFFE58023),
    interestRate: '10.75% p.a.',
    loanAmount: '₹30 Lakhs',
    tenure: '72 months',
    maxLoanAmount: '₹30,00,000',
    maxLoanFormatted: '30,00,000',
  ),
];

// ── Helper to find bank data by name ─────────────────────────────────────────
BankOfferData getBankOfferByName(String bankName) {
  final lower = bankName.toLowerCase();
  if (lower.contains('hdfc')) return bankOffers[0];
  if (lower.contains('sbi')) return bankOffers[1];
  if (lower.contains('icic')) return bankOffers[2];
  return bankOffers[0]; // Default to HDFC
}

// ── Show Bank Offer Dialog (Centered on screen) ─────────────────────────────
void showBankOfferDialog(BuildContext context, BankOfferData bank) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: _BankOfferCard(bank: bank),
    ),
  );
}

class _BankOfferCard extends StatelessWidget {
  final BankOfferData bank;
  const _BankOfferCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dark Navy Header with Bank Logo ─────────────────────────
              _buildHeader(context),

          // ── Card Body ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              children: [
                // Bank Name
                Text(
                  bank.bankName,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7F8C8D),
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),

                // Title
                Text(
                  'Exclusive Personal Loan Offer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 20.h),

                // Info Rows
                _buildInfoRow(
                  icon: Icons.percent_rounded,
                  iconBg: const Color(0xFF2E7D6F),
                  label: 'Interest Rate',
                  value: 'Starting at ${bank.interestRate}',
                ),
                SizedBox(height: 12.h),
                _buildInfoRow(
                  icon: Icons.account_balance_wallet_rounded,
                  iconBg: const Color(0xFF1A3A5C),
                  label: 'Loan Amount',
                  value: 'Up to ${bank.loanAmount}',
                ),
                SizedBox(height: 12.h),
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  iconBg: const Color(0xFF4A5568),
                  label: 'Flexible Tenure',
                  value: 'Up to ${bank.tenure}',
                ),
                SizedBox(height: 24.h),

                // View More Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            BankVisitDetailScreen(bank: bank),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color:  Color(0xFF00033F),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View More',
                          style: GoogleFonts.poppins(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 24.w,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Maybe Later
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'MAYBE LATER',
                    style: GoogleFonts.manrope(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF454651),
                      letterSpacing: 1.07,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Verified Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified,
                      color: Color(0xFF006C4B),
                      size: 18.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Verified TrueLoan Partner Offer',
                      style: GoogleFonts.manrope(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF454651),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xFF00033F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Close button
          Positioned(
            top: 12.h,
            right: 12.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16.w),
              ),
            ),
          ),
          // Bank Logo (positioned to hang below the header)
          Positioned(
            bottom: 10.h,
            left: 0.w,
            right: 0.w,
            child: Center(
              child: Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: bank.logoBgColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  bank.logoText,
                  style: GoogleFonts.poppins(
                    fontSize: bank.logoText.length > 4 ? 10 : 12,
                    fontWeight: FontWeight.w800,
                    color: bank.logoTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color:  Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEF2F6), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.white, size: 20.w),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color:  Color(0xFF454651),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF191C1D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Bank Visit Detail Screen (Full-page scrollable) ──────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class BankVisitDetailScreen extends StatelessWidget {
  final BankOfferData bank;
  const BankVisitDetailScreen({super.key, required this.bank});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00033F),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Visit Detail',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bank Header Card ─────────────────────────────────
            _buildBankHeaderCard(),
            SizedBox(height: 16.h),

            // ── Max Loan Amount Card ──────────────────────────────
            _buildMaxLoanCard(),
            SizedBox(height: 16.h),

            // ── Interest Rate & Tenure Row ────────────────────────
            _buildRateTenureRow(),
            SizedBox(height: 24.h),

            // ── Features & Benefits ───────────────────────────────
            _buildFeaturesSection(),
            SizedBox(height: 24.h),

            // ── Eligibility Check ─────────────────────────────────
            _buildEligibilitySection(),
            SizedBox(height: 24.h),

            // ── EMI Example ───────────────────────────────────────
            _buildEmiExampleSection(),
            SizedBox(height: 20.h),

            // ── Bottom Section (Apply Now) ────────────────────────
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBankHeaderCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bank Logo
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: bank.logoBgColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              bank.logoText,
              style: GoogleFonts.poppins(
                fontSize: bank.logoText.length > 4 ? 9 : 11,
                fontWeight: FontWeight.w800,
                color: bank.logoTextColor,
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Bank Name + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bank.bankName.split(' ').first.substring(0, 1).toUpperCase()}${bank.bankName.split(' ').first.substring(1).toLowerCase()} Bank',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  'Personal Loan Offer',
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),

          // Pre-Approved Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color:  Color(0xFFE6FFF5),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFF72F8BF), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Color(0xFF00714E), size: 12.w),
                SizedBox(width: 4.w),
                Text(
                  'Pre-Approved',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00714E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaxLoanCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color:  Color(0xFF00033F),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00033F).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Maximum Loan Amount',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            bank.maxLoanAmount,
            style: GoogleFonts.manrope(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          SizedBox(height: 16.h),
          // Chips
          Row(
            children: [
              _buildChip('Quick Approval'),
              SizedBox(width: 10.w),
              _buildChip('Paperless'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRateTenureRow() {
    // Parse rate number for display
    final rateNumber = bank.interestRate.replaceAll(' p.a.', '');
    // Parse tenure number
    final tenureText = bank.tenure;

    return Row(
      children: [
        // Interest Rate Card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color:  Color(0xFF302000),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interest Rate',
                  style: GoogleFonts.manrope(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffB18210),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  rateNumber,
                  style: GoogleFonts.manrope(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xffB18210),
                    height: 1.1,
                  ),
                ),
                Text(
                  'per annum',
                  style: GoogleFonts.manrope(
                    fontSize: 10.sp,
                    color: Color(0xffB18210),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 14.w),

        // Tenure Card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color:  Color(0xFFF5F3ED),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE8E4D8), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tenure',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color:  Color(0xFF7F8C8D),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Up to ${tenureText.split(' ').first}',
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    height: 1.1,
                  ),
                ),
                Text(
                  'Months',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features & Benefits',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color:  Color(0xFF1A1A2E),
          ),
        ),
        SizedBox(height: 16.h),
        _buildFeatureItem(
          Icons.flash_on_rounded,
          'Instant Disbursal',
          'Funds credited to your account in 10 mins.',
        ),
        SizedBox(height: 14.h),
        _buildFeatureItem(
          Icons.description_outlined,
          'Paperless Process',
          '100% digital journey, no physical docs needed.',
        ),
        SizedBox(height: 14.h),
        _buildFeatureItem(
          Icons.visibility_off_outlined,
          'No Hidden Charges',
          'Transparent processing fees and zero loan trap.',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color:  Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color:  Color(0xFF00033F), size: 18.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
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
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eligibility Check',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color:  Color(0xFF1A1A2E),
          ),
        ),
        SizedBox(height: 14.h),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildEligibilityChip(
              Icons.currency_rupee,
              'Monthly Income > ₹25,000',
            ),
            _buildEligibilityChip(
              Icons.person_outline,
              'Age between 21 - 60 years',
            ),
            _buildEligibilityChip(
              Icons.work_outline,
              'Employment at Registered Org.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEligibilityChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE0E4E8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color:  Color(0xFF03C68A)),
          SizedBox(width: 8.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiExampleSection() {
    // EMI data varies by bank
    final emiData = _getEmiData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMI Example',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color:  Color(0xFF1A1A2E),
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFEEF2F6)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF00033F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Loan Amount',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Tenure',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'EMI',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              // Table Rows
              ...emiData.asMap().entries.map((entry) {
                final isLast = entry.key == emiData.length - 1;
                final row = entry.value;
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(color: Color(0xFFEEF2F6)),
                          ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          row['amount']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          row['tenure']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: const Color(0xFF7F8C8D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          row['emi']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0050CC),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '* EMI calculations are indicative and may vary.',
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: const Color(0xFF7F8C8D),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getEmiData() {
    if (bank.bankName.contains('HDFC')) {
      return [
        {'amount': '₹1,00,000', 'tenure': '60 Mo', 'emi': '₹2,149'},
        {'amount': '₹5,00,000', 'tenure': '60 Mo', 'emi': '₹10,745'},
      ];
    } else if (bank.bankName.contains('SBI')) {
      return [
        {'amount': '₹1,00,000', 'tenure': '48 Mo', 'emi': '₹2,540'},
        {'amount': '₹5,00,000', 'tenure': '48 Mo', 'emi': '₹12,700'},
      ];
    } else {
      return [
        {'amount': '₹1,00,000', 'tenure': '72 Mo', 'emi': '₹1,868'},
        {'amount': '₹5,00,000', 'tenure': '72 Mo', 'emi': '₹9,340'},
      ];
    }
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Apply Now Button
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
                Navigator.pop(context); // Close visit detail
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const CreateAdScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
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
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color:  Color(0xFF00033F),
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Apply Now',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'By clicking Apply Now, you agree to the T&Cs.',
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }
}
