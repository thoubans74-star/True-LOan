import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:tm/verification_manager/app_colors.dart';
import 'visit_details.dart';

/// "Schedule Field Visit" form screen. Stateful so the form fields are
/// editable; wire `onConfirm` / `onCancel` to your own navigation + API call.
class ScheduleFieldVisitScreen extends StatefulWidget {
  const ScheduleFieldVisitScreen({
    super.key,
    this.applicationIdCustomer = 'TM-2026-7842 · Thanusri',
    this.visitPurpose = 'Document Verification',
    this.visitDate = '1-04-2026',
    this.visitTime = '10:30',
    this.visitAddress = 'Kundadam, Dharapuram, Tirupur, TN 641654',
    this.priority = 'Urgent',
    this.docsToVerify = const [
      DocToVerify('🪪', 'Aadhar Card (Physical)'),
      DocToVerify('🪪', 'PAN Card (Physical)'),
      DocToVerify('📘', 'Bank Passbook / Statement'),
      DocToVerify('🤳', 'Selfie with Customer'),
      DocToVerify('📄', 'Property Documents'),
    ],
    this.notes = 'Customer available from 10 AM – 1 PM. Ring doorbell twice.',
    this.onConfirm,
    this.onCancel,
    this.onBack,
  });

  final String applicationIdCustomer;
  final String visitPurpose;
  final String visitDate;
  final String visitTime;
  final String visitAddress;
  final String priority;
  final List<DocToVerify> docsToVerify;
  final String notes;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onBack;

  @override
  State<ScheduleFieldVisitScreen> createState() =>
      _ScheduleFieldVisitScreenState();
}

class DocToVerify {
  const DocToVerify(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _ScheduleFieldVisitScreenState extends State<ScheduleFieldVisitScreen> {
  late final TextEditingController _appIdCtrl;
  late final TextEditingController _purposeCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _appIdCtrl = TextEditingController(text: widget.applicationIdCustomer);
    _purposeCtrl = TextEditingController(text: widget.visitPurpose);
    _dateCtrl = TextEditingController(text: widget.visitDate);
    _timeCtrl = TextEditingController(text: widget.visitTime);
    _addressCtrl = TextEditingController(text: widget.visitAddress);
    _notesCtrl = TextEditingController(text: widget.notes);
  }

  @override
  void dispose() {
    _appIdCtrl.dispose();
    _purposeCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _TopAppBar(title: 'Schedule Field Visit', onBack: widget.onBack ?? () {
              Navigator.pop(context);
            }),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoBanner(
                      text:
                          "Schedule on offline visit to physically verify the applicant's documents and residence.",
                    ),
                    SizedBox(height: 18.h),
                     _FieldLabel('Application ID / Customer'),
                    _FieldBox(controller: _appIdCtrl),
                    SizedBox(height: 16.h),
                     _FieldLabel('Visit Purpose'),
                    _FieldBox(controller: _purposeCtrl),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Visit Date'),
                              _FieldBox(
                                  controller: _dateCtrl,
                                  trailingIcon:
                                      Icons.calendar_today_outlined),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Visit Time'),
                              _FieldBox(
                                  controller: _timeCtrl,
                                  trailingIcon: Icons.access_time),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                     _FieldLabel('Visit Address'),
                    _FieldBox(controller: _addressCtrl, maxLines: 2),
                    SizedBox(height: 16.h),
                    const _FieldLabel('Priority Level'),
                    Text(
                      widget.priority,
                      style: TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text('Docs to Verify (at visit)', style: AppText.h2),
                    SizedBox(height: 10.h),
                    ...widget.docsToVerify.map(
                      (d) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            Text(d.emoji, style: TextStyle(fontSize: 15.sp)),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(d.label, style: AppText.body),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                     _FieldLabel('Notes For Visit'),
                    _FieldBox(controller: _notesCtrl, maxLines: 3),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            _BottomActions(
              onConfirm: widget.onConfirm ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisitDetailsScreen(),
                  ),
                );
              },
              onCancel: widget.onCancel ?? () {
                Navigator.pop(context);
              },
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
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.infoBannerBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18.w, color: AppColors.primaryBlue),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: AppColors.primaryBlueDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({
    required this.controller,
    this.maxLines = 1,
    this.trailingIcon,
  });

  final TextEditingController controller;
  final int maxLines;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: 13.5.sp, color: AppColors.textDark),
      decoration: InputDecoration(
        suffixIcon: trailingIcon != null
            ? Icon(trailingIcon, size: 18.w, color: AppColors.textGrey)
            : null,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide:  BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide:  BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({this.onConfirm, this.onCancel});

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 18.w),
                  SizedBox(width: 6.w),
                  Text('Confirm & Schedule Visit',
                      style:
                          TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCancel,
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
        ],
      ),
    );
  }
}
