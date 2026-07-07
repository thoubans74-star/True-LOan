import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:tm/theme_manager.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.themedStatusBar,
      child: Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AC6),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        physics:  ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Effective Date Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/home/shield.png',
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6.w),
                Text(
                  'EFFECTIVE: OCTOBER 2023',
                  style: GoogleFonts.poppins(
                    color:  Color(0xFF009668),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Legal Agreement
            Text(
              'Legal Agreement',
              style: GoogleFonts.poppins(
                color: context.textColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            // Intro Text
            Text(
              'Please read these terms carefully before using the TrueMoney platform. By accessing our services, you agree to be bound by these requirements.',
              style: GoogleFonts.poppins(
                color: context.subTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // 1. Introduction
            _buildSectionHeader('1.', 'Introduction'),
            SizedBox(height: 12.h),
            Text(
              'Welcome to TrueMoney. These Terms and Conditions constitute a legally binding agreement made between you, whether personally or on behalf of an entity ("you") and TrueMoney ("we," "us" or "our"), concerning your access to and use of our mobile application and financial services. You agree that by accessing the application, you have read, understood, and agreed to be bound by all of these Terms and Conditions.',
              style: GoogleFonts.poppins(
                color: context.subTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'IF YOU DO NOT AGREE WITH ALL OF THESE TERMS AND CONDITIONS, THEN YOU ARE EXPRESSLY PROHIBITED FROM USING THE APP AND YOU MUST DISCONTINUE USE IMMEDIATELY.',
              style: GoogleFonts.poppins(
                color: context.subTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
            SizedBox(height: 24.h),

            // 2. Eligibility
            _buildSectionHeader('2.', 'Eligibility'),
            SizedBox(height: 12.h),
            Text(
              'The services offered by TrueMoney are intended solely for users who are eighteen (18) years of age or older. Any registration by, use of or access to the app by anyone under 18 is unauthorized, unlicensed and in violation of these Terms. By using the services, you represent and warrant that you are 18 or older and that you agree to abide by all of the terms and conditions of this Agreement.',
              style: GoogleFonts.poppins(
                color: context.subTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // 3. User Obligations
            _buildSectionHeader('3.', 'User Obligations'),
            SizedBox(height: 12.h),
            _buildBulletItem(
              'You must provide accurate, current, and complete information during the registration process.',
            ),
            SizedBox(height: 12.h),
            _buildBulletItem(
              'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
            ),
            SizedBox(height: 12.h),
            _buildBulletItem(
              'You agree to notify us immediately of any unauthorized use of your account or any other breach of security.',
            ),
            SizedBox(height: 12.h),
            _buildBulletItem(
              'The service must not be used for any illegal or unauthorized purpose, including but not limited to money laundering or fraudulent transactions.',
            ),
            SizedBox(height: 24.h),

            // Investment Notice Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              decoration: BoxDecoration(
                color:  Color(0x0D2170E4), // #2170E40D
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
                border: Border(
                  left: BorderSide(color: Color(0xFF2170E4), width: 4.w),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF2170E4),
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Investment Notice',
                        style: GoogleFonts.poppins(
                          color:  Color(0xFF004395),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.only(left: 28.w),
                    child: Text(
                      'All financial instruments involve risk. Past performance is not a guarantee of future results.',
                      style: GoogleFonts.poppins(
                        color: context.subTextColor,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // 4. Investment Risks
            _buildSectionHeader('4.', 'Investment Risks'),
            SizedBox(height: 12.h),
            Text(
              'The value of investments and the income from them can fall as well as rise and you may not get back the amount originally invested. Decisions to buy, sell or hold any financial instrument involve risk and are best made based on the advice of qualified financial professionals. Any "backtesting" or "simulated" performance results have certain inherent limitations.',
              style: GoogleFonts.poppins(
                color: context.subTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'TrueMoney provides tools for data analysis but does not provide personalized investment advice. You are solely responsible for determining whether any investment is appropriate for you based on your personal objectives and financial situation.',
              style: GoogleFonts.poppins(
                color: context.subTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // 5. Privacy Policy
            _buildSectionHeader('5.', 'Privacy Policy'),
            SizedBox(height: 12.h),
            Text.rich(
              TextSpan(
                style: GoogleFonts.poppins(
                  color:  Color(0xFF45464D),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Your privacy is important to us. Please review our ',
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF0058BE),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ', which also governs your use of our services, to understand our practices. We use industry-standard encryption and security protocols to ensure your data remains protected at all times.',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title) {
    return Builder(
      builder: (context) {
        return RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600),
            children: [
              TextSpan(
                text: number,
                style: TextStyle(color: Color(0xFF009668)),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: title,
                style: TextStyle(color: context.textColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletItem(String text) {
    return Builder(
      builder: (context) {
        return Text(
          text,
          style: GoogleFonts.poppins(
            color: context.subTextColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        );
      },
    );
  }
}
