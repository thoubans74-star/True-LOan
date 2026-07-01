import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:tm/verification_manager/app_colors.dart';
import 'verification_request.dart';
import 'schedule_field_visit.dart';

/// Home / Dashboard screen for the field-verification agent app.
/// Matches the "Daily Overview" reference design pixel-for-pixel:
/// navy header -> floating blue "Total Assigned" stat card -> pending/approved
/// mini stats -> quick action buttons -> urgent review list.
class VerificationHomeScreen extends StatelessWidget {
  const VerificationHomeScreen({
    super.key,
    this.agentName = 'Akhil',
    this.totalAssigned = 1248,
    this.newCasesSinceLogin = 24,
    this.trendPercent = 12,
    this.pending = 42,
    this.approved = 1186,
    this.onRequestTap,
    this.onSupportTap,
    this.onNotificationTap,
    this.onStartVisit,
  });

  final String agentName;
  final int totalAssigned;
  final int newCasesSinceLogin;
  final int trendPercent;
  final int pending;
  final int approved;
  final VoidCallback? onRequestTap;
  final VoidCallback? onSupportTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onStartVisit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderWithStatCard(
                agentName: agentName,
                totalAssigned: totalAssigned,
                newCasesSinceLogin: newCasesSinceLogin,
                trendPercent: trendPercent,
                onNotificationTap: onNotificationTap,
              ),
              SizedBox(height: 68.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        label: 'PENDING',
                        value: pending.toString(),
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.orange,
                        iconBg: AppColors.orangeLightBg,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'APPROVED',
                        value: approved.toString(),
                        icon: Icons.check_circle_rounded,
                        iconColor: AppColors.green,
                        iconBg: AppColors.greenLightBg,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text('Quick Actions', style: AppText.h2),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Request',
                        icon: Icons.assignment_outlined,
                        gradient: AppColors.greenButtonGradient,
                        onTap: onRequestTap ?? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VerificationRequestScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _QuickActionButton(
                        label: 'Support',
                        icon: Icons.support_agent_outlined,
                        gradient: AppColors.pinkButtonGradient,
                        onTap: onSupportTap,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text('Urgent Reviews', style: AppText.h2),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _UrgentReviewCard(
                  tag: 'LENDER AUDIT',
                  name: 'Priya Sharma',
                  address:
                      'Indiranagar 12th Main, Near Metro Station, Bangalore East, 560038',
                  assignedTime: '09:15 AM',
                  priority: 'Normal',
                  priorityColor: AppColors.amberPriority,
                  onStartVisit: onStartVisit ?? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScheduleFieldVisitScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderWithStatCard extends StatelessWidget {
  const _HeaderWithStatCard({
    required this.agentName,
    required this.totalAssigned,
    required this.newCasesSinceLogin,
    required this.trendPercent,
    this.onNotificationTap,
  });

  final String agentName;
  final int totalAssigned;
  final int newCasesSinceLogin;
  final int trendPercent;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 18 + MediaQuery.of(context).padding.top, 20, 80),
          decoration: BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0.r),
              bottomRight: Radius.circular(0.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Good Morning!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 24.w),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(agentName, style: AppText.h1White),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.trending_up_rounded,
                          color: Color(0xFF4ADE80), size: 14.w),
                      SizedBox(width: 2.w),
                      Text(
                        '+$trendPercent%',
                        style: TextStyle(
                          color: Color(0xFF4ADE80),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Updated 2 mins ago',
                style: TextStyle(color: Colors.white54, fontSize: 11.sp),
              ),
            ],
          ),
        ),
        // Floating "Total Assigned" stat card, overlapping the header bottom.
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: -50,
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              gradient: AppColors.totalAssignedGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlueDark.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ASSIGNED',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatThousands(totalAssigned),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.white70, size: 13.w),
                    SizedBox(width: 4.w),
                    Text(
                      '$newCasesSinceLogin new cases since last login',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatThousands(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.label),
              SizedBox(height: 6.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 17.w),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22.w),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrgentReviewCard extends StatelessWidget {
  const _UrgentReviewCard({
    required this.tag,
    required this.name,
    required this.address,
    required this.assignedTime,
    required this.priority,
    required this.priorityColor,
    this.onStartVisit,
  });

  final String tag;
  final String name;
  final String address;
  final String assignedTime;
  final String priority;
  final Color priorityColor;
  final VoidCallback? onStartVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.tagBg,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textGrey,
                letterSpacing: 0.4,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 15.w, color: AppColors.textGrey),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textGrey,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: AppColors.cardBorder),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ASSIGNED', style: AppText.label),
                    SizedBox(height: 2.h),
                    Text(assignedTime,
                        style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRIORITY', style: AppText.label),
                    SizedBox(height: 2.h),
                    Text(priority,
                        style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: priorityColor)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onStartVisit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Start Visit',
                          style: TextStyle(
                              fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward_rounded, size: 14.w),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
