import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/theme_manager.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      body: Column(
        children: [
          // ── Blue Header ────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1741B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                    Text(
                      'Matches',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Match List ──────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
              physics:  ClampingScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _MatchListCard(
                  name: ['Sowmiya', 'Arjun Kumar', 'Priya Nair',
                    'Ravi Sharma', 'Meena Devi', 'Suresh Kumar'][index],
                  role: index.isEven ? 'Lender' : 'Borrower',
                  matchPercent: 97 - (index * 2),
                  amount: '₹50,00,000',
                  roi: '10-14%',
                  tenure: '12-48M',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchListCard extends StatelessWidget {
  final String name;
  final String role;
  final int matchPercent;
  final String amount;
  final String roi;
  final String tenure;

  const _MatchListCard({
    required this.name,
    required this.role,
    required this.matchPercent,
    required this.amount,
    required this.roi,
    required this.tenure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF145A32), Color(0xFF1A7A47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + match badge
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.isDarkMode ? const Color(0xFF1E2B4A) : const Color(0xFFE2E8F0),
                ),
                child: Icon(
                  Icons.person,
                  color: context.isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                  size: 22.w,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    role,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color:  Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$matchPercent% Match',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Text(
                'ROI: $roi',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 20.w),
              Text(
                'Tenure: $tenure',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
