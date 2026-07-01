import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:tm/verification_manager/app_colors.dart';

/// "Visit Detail" screen shown after a visit is scheduled — dark summary
/// card, route/ETA preview, address + call action, checklist, and bottom CTAs.
///
/// The map preview is a lightweight stylized placeholder (no external map
/// dependency). Swap `_RoutePreview` for a `google_maps_flutter` /
/// `flutter_map` widget when wiring up real navigation.
class VisitDetailsScreen extends StatelessWidget {
  const VisitDetailsScreen({
    super.key,
    this.visitTypeLabel = 'Field Visit',
    this.customerName = 'Thanusri',
    this.referenceLine = 'TM-2026-7842 · Personal Loan',
    this.scheduledTime = '10:00',
    this.priorityLabel = 'URGENT',
    this.stepsCount = 5,
    this.eta = 'ETA:12mins.4.2km',
    this.trafficNote = '9 min Heavy traffic',
    this.addressTitle = "Thanusri's Residence",
    this.addressLine = 'Kundadam, Dharapuram Road, Tirupur, Tamil Nadu – 641654',
    this.phoneNumber = '+91 98765 43210',
    this.checklist = const [
      'Navigate to Location',
      'Identity Verification',
      'Document Collection',
      'Customer Interview',
    ],
    this.onBack,
    this.onCallCustomer,
    this.onCancel,
    this.onStartVisit,
  });

  final String visitTypeLabel;
  final String customerName;
  final String referenceLine;
  final String scheduledTime;
  final String priorityLabel;
  final int stepsCount;
  final String eta;
  final String trafficNote;
  final String addressTitle;
  final String addressLine;
  final String phoneNumber;
  final List<String> checklist;
  final VoidCallback? onBack;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onCancel;
  final VoidCallback? onStartVisit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _TopAppBar(title: 'Visit Detail', onBack: onBack ?? () {
              Navigator.pop(context);
            }),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCard(
                      visitTypeLabel: visitTypeLabel,
                      customerName: customerName,
                      referenceLine: referenceLine,
                      scheduledTime: scheduledTime,
                      priorityLabel: priorityLabel,
                      stepsCount: stepsCount,
                    ),
                    SizedBox(height: 16.h),
                    _RoutePreview(eta: eta, trafficNote: trafficNote),
                    SizedBox(height: 16.h),
                    _AddressCard(
                      title: addressTitle,
                      addressLine: addressLine,
                      phoneNumber: phoneNumber,
                      onCallCustomer: onCallCustomer,
                    ),
                    SizedBox(height: 18.h),
                    Text('Visit Checklist', style: AppText.h2),
                    SizedBox(height: 10.h),
                    ...List.generate(
                      checklist.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Container(
                              width: 22.w,
                              height: 22.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primaryBlue, width: 1.4),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(checklist[i], style: AppText.body),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            _BottomActions(onCancel: onCancel, onStartVisit: onStartVisit),
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
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.visitTypeLabel,
    required this.customerName,
    required this.referenceLine,
    required this.scheduledTime,
    required this.priorityLabel,
    required this.stepsCount,
  });

  final String visitTypeLabel;
  final String customerName;
  final String referenceLine;
  final String scheduledTime;
  final String priorityLabel;
  final int stepsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            visitTypeLabel,
            style: TextStyle(color: Colors.white60, fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            customerName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            referenceLine,
            style: TextStyle(color: Colors.white54, fontSize: 11.5.sp),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _SummaryPill(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$scheduledTime ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                       TextSpan(
                        text: 'Scheduled Time',
                        style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _SummaryPill(
                color: AppColors.red.withValues(alpha: 0.18),
                child: Text(
                  priorityLabel,
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _SummaryPill(
                child: Text(
                  '$stepsCount Steps',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
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

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color ?? AppColors.navyPillBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: child,
    );
  }
}

/// Stylized stand-in for a live map/route preview. Replace with a real map
/// widget (e.g. GoogleMap) for production; the ETA + traffic banners are
/// real widgets you can keep overlaying on top of any map implementation.
class _RoutePreview extends StatelessWidget {
  const _RoutePreview({required this.eta, required this.trafficNote});
  final String eta;
  final String trafficNote;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 150.h,
        child: Stack(
          children: [
            Container(color: const Color(0xFFE9ECF2)),
            CustomPaint(
              size: const Size.fromHeight(150),
              painter: _RoadPainter(),
            ),
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.greenDark,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  eta,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car,
                        size: 13.w, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      trafficNote,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final redPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.15,
          size.width * 0.55, size.height * 0.5);
    canvas.drawPath(path1, bluePaint);

    final path2 = Path()
      ..moveTo(size.width * 0.55, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.75,
          size.width * 0.9, size.height * 0.2);
    canvas.drawPath(path2, redPaint);

    final dotPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.85), 5, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.2), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.title,
    required this.addressLine,
    required this.phoneNumber,
    this.onCallCustomer,
  });

  final String title;
  final String addressLine;
  final String phoneNumber;
  final VoidCallback? onCallCustomer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            children: [
              Icon(Icons.location_on, size: 16.w, color: AppColors.primaryBlue),
              SizedBox(width: 6.w),
              Text(title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ],
          ),
          SizedBox(height: 6.h),
          Text(addressLine,
              style: TextStyle(
                  fontSize: 12.5.sp, color: AppColors.textGrey, height: 1.4)),
          SizedBox(height: 2.h),
          Text(phoneNumber,
              style: TextStyle(
                  fontSize: 12.5.sp,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCallCustomer,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.greenDark,
                side:  BorderSide(color: AppColors.green),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call, size: 16.w),
                  SizedBox(width: 6.w),
                  Text('Call Customer',
                      style:
                          TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({this.onCancel, this.onStartVisit});

  final VoidCallback? onCancel;
  final VoidCallback? onStartVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel ?? () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDark,
                side:  BorderSide(color: AppColors.inputBorder),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text('Cancel',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: onStartVisit ?? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Field Visit Started!')),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text('Start Visit Now',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
