import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _expandedFaqIndex; // Tracks which FAQ item is currently expanded

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I withdraw funds?',
      'answer':
          'To withdraw funds, navigate to your Wallet screen, tap on \'Withdraw\', enter the amount you wish to transfer, select your linked bank account, and confirm the transaction. Withdrawals typically process within 2-4 hours.',
    },
    {
      'question': 'Is my data secure?',
      'answer':
          'Yes, we prioritize your data security. All personal information and KYC documents are encrypted using bank-grade AES-256 encryption. We never share your details with unauthorized third parties.',
    },
    {
      'question': 'What are the transaction fees?',
      'answer':
          'We charge a nominal fee of 1.5% on successful transactions. There are no hidden charges, and listing/requesting loans is completely free of cost.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0058BE),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF0058BE,
        ), // Match primary blue brand color
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Help Center',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics:  ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // How can we help?
            Text(
              'How can we help?',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color:  Color(0xFF000000),
              ),
            ),
            SizedBox(height: 16.h),

            // Search Bar
            TextField(
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF191C1E),
              ),
              decoration: InputDecoration(
                hintText: 'Search for help articles...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xFF76777D)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
            SizedBox(height: 24.h),

            // Chat with Us card
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 20.h,
                left: 20.w,
                right: 20.w,
                bottom: 32.h,
              ),
              decoration: BoxDecoration(
                color:  Color(0xFF0058BE),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981), // Green active dot
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Active now',
                            style: GoogleFonts.poppins(
                              color:  Color(0xFFFFFFFF),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Chat with Us',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Average wait: 2 mins',
                        style: GoogleFonts.poppins(
                          color:  Color(0xFFFFFFFF),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                  Positioned(
                    bottom: -18,
                    right: 0.w,
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white.withOpacity(0.18),
                      size: 44.w,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Call Support card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Call Support',
                    style: GoogleFonts.poppins(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color:  Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Available 24/7 for urgent issues',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color:  Color(0xFF76777D),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        color: Color(0xFF0058BE),
                        size: 32.w,
                      ),
                      TextButton(
                        onPressed: () {
                          // Call support action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connecting to support...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Connect Now',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00356C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            // Frequently Asked Questions
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color:  Color(0xFF000000),
              ),
            ),
            SizedBox(height: 16.h),

            // FAQ List Accordions
            ...List.generate(_faqs.length, (index) {
              final faq = _faqs[index];
              final isExpanded = _expandedFaqIndex == index;

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _expandedFaqIndex = isExpanded ? null : index;
                        });
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(18.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq['question']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF000000),
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color:  Color(0xFF76777D),
                              size: 26.w,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      Divider(height: 1, color: Color(0xFFE2E8F0)),
                      Padding(
                        padding: EdgeInsets.all(18.w),
                        child: Text(
                          faq['answer']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF45464D),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      ),
    );
  }
}
