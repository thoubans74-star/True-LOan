import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:tm/verification_manager/app_colors.dart';
import 'schedule_field_visit.dart';

/// Model for a single verification request shown in the list.
class VerificationRequest {
  const VerificationRequest({
    required this.type,
    required this.name,
    required this.address,
    required this.assignedTime,
    required this.priority,
    this.isNewRequest = false,
  });

  final String type; // e.g. "BORROWER VERIFICATION", "LENDER AUDIT"
  final String name;
  final String address;
  final String assignedTime; // e.g. "10:30 AM" or "Yesterday"
  final RequestPriority priority;
  final bool isNewRequest;
}

enum RequestPriority { high, normal, standard }

extension on RequestPriority {
  String get label {
    switch (this) {
      case RequestPriority.high:
        return 'High';
      case RequestPriority.normal:
        return 'Normal';
      case RequestPriority.standard:
        return 'Standard';
    }
  }

  Color get color {
    switch (this) {
      case RequestPriority.high:
        return AppColors.red;
      case RequestPriority.normal:
        return AppColors.amberPriority;
      case RequestPriority.standard:
        return AppColors.textGrey;
    }
  }
}

/// "Requests" screen — green live-assignments banner + scrollable list of
/// request cards, each with a "Start Visit" CTA.
class VerificationRequestScreen extends StatelessWidget {
  const VerificationRequestScreen({
    super.key,
    this.requests = const [
      VerificationRequest(
        type: 'BORROWER VERIFICATION',
        name: 'Aravind Swamy',
        address: '42nd Floor, Brigade Tower, MG Road, Bangalore North, 560001',
        assignedTime: '10:30 AM',
        priority: RequestPriority.high,
        isNewRequest: true,
      ),
      VerificationRequest(
        type: 'LENDER AUDIT',
        name: 'Priya Sharma',
        address: 'Indiranagar 12th Main, Near Metro Station, Bangalore East, 560038',
        assignedTime: '09:15 AM',
        priority: RequestPriority.normal,
      ),
      VerificationRequest(
        type: 'BORROWER VERIFICATION',
        name: 'Karthik Narayanan',
        address: 'Sobha Dream Acres, Panathur Road, Varthur, Bangalore, 560087',
        assignedTime: 'Yesterday',
        priority: RequestPriority.standard,
      ),
    ],
    this.onBack,
    this.onStartVisit,
  });

  final List<VerificationRequest> requests;
  final VoidCallback? onBack;
  final void Function(VerificationRequest request)? onStartVisit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _TopAppBar(title: 'Requests', onBack: onBack),
            _LiveAssignmentsBanner(count: requests.length),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
                physics:  BouncingScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (context, index) => SizedBox(height: 14.h),
                itemBuilder: (context, i) {
                  final r = requests[i];
                  return _RequestCard(
                    request: r,
                    onStartVisit: () {
                      if (onStartVisit != null) {
                        onStartVisit!.call(r);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScheduleFieldVisitScreen(),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
      decoration: BoxDecoration(gradient: AppColors.appBarGradient),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveAssignmentsBanner extends StatelessWidget {
  const _LiveAssignmentsBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(gradient: AppColors.greenBannerGradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVE ASSIGNMENTS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$count Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 7.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Live Updates',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, this.onStartVisit});

  final VerificationRequest request;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.tagBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  request.type,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (request.isNewRequest)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenLightBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12.w,
                        color: AppColors.greenText,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'New Request',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenText,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            request.name,
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
              Icon(
                Icons.location_on_outlined,
                size: 15.w,
                color: AppColors.textGrey,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  request.address,
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
                    Text(
                      request.assignedTime,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRIORITY', style: AppText.label),
                    SizedBox(height: 2.h),
                    Text(
                      request.priority.label,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: request.priority.color,
                      ),
                    ),
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
                      Text(
                        'Start Visit',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
