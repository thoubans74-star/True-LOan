import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tm/theme_manager.dart';

/// Shows the main sector selection bottom sheet.
void showSectorSelectionBottomSheet(
  BuildContext context, {
  required VoidCallback onSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SectorSelectionBottomSheet(onSuccess: onSuccess);
    },
  );
}

class SectorSelectionBottomSheet extends StatelessWidget {
  final VoidCallback onSuccess;

  const SectorSelectionBottomSheet({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2.5.r),
            ),
          ),
          SizedBox(height: 24.h),
          _buildSectorButton(
            context: context,
            label: 'Private Sector',
            onTap: () {
              Navigator.pop(context); // Close selection sheet
              _showPrivateSectorSheet(context, onSuccess);
            },
          ),
          SizedBox(height: 14.h),
          _buildSectorButton(
            context: context,
            label: 'NBFC',
            onTap: () {
              Navigator.pop(context); // Close selection sheet
              _showNbfcSheet(context, onSuccess);
            },
          ),
          SizedBox(height: 14.h),
          _buildSectorButton(
            context: context,
            label: 'Bank Sector',
            onTap: () {
              Navigator.pop(context); // Close selection sheet
              _showBankSheet(context, onSuccess);
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSectorButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 58.h,
      decoration: BoxDecoration(
        color:  Color(0xFF0056D2), // premium blue matching screenshot
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private Sector Bottom Sheet ──────────────────────────────────────────────
void _showPrivateSectorSheet(BuildContext context, VoidCallback onSuccess) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return PrivateSectorVerificationBottomSheet(onSuccess: onSuccess);
    },
  );
}

class PrivateSectorVerificationBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const PrivateSectorVerificationBottomSheet({
    super.key,
    required this.onSuccess,
  });

  @override
  State<PrivateSectorVerificationBottomSheet> createState() =>
      _PrivateSectorVerificationBottomSheetState();
}

class _PrivateSectorVerificationBottomSheetState
    extends State<PrivateSectorVerificationBottomSheet> {
  String? _bankStatementFileName;
  String? _itrFileName;
  String? _salarySlipsFileName;
  String? _panFileName;

  Future<void> _pickFile(int index) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          final fileName = result.files.single.name;
          if (index == 0) {
            _bankStatementFileName = fileName;
          } else if (index == 1) {
            _itrFileName = fileName;
          } else if (index == 2) {
            _salarySlipsFileName = fileName;
          } else if (index == 3) {
            _panFileName = fileName;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.85;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2.5.r),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Color(0xFF0058BE),
                    size: 24.w,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints:  BoxConstraints(),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Private Sector Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.dividerColor),
          Expanded(
            child: SingleChildScrollView(
              physics:  ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('IDENTITY PROOF'),
                  SizedBox(height: 12.h),
                  _buildIdentityCard(
                    icon: 'assets/profile/aadhar card.png',
                    iconBgColor: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    title: 'Aadhaar Card',
                    statusText: 'Verified',
                    statusColor: const Color(0xFF004AC6),
                    isVerified: true,
                    rightWidget: Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 24.w,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildIdentityCard(
                    icon: Icons.credit_card_rounded,
                    iconBgColor: const Color(0xFFF1F5F9),
                    iconColor: const Color(0xFF64748B),
                    title: 'PAN Card',
                    statusText: _panFileName != null
                        ? 'Uploaded'
                        : 'Action Required',
                    statusColor: _panFileName != null
                        ? const Color(0xFF004AC6)
                        : const Color(0xFFBA1A1A),
                    isVerified: _panFileName != null,
                    rightWidget: _panFileName != null
                        ? Text(
                            _panFileName!,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: const Color(0xFF004AC6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : ElevatedButton(
                            onPressed: () => _pickFile(3),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  Color(0xFF004AC6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 6.h,
                              ),
                              minimumSize: Size.zero,
                              elevation: 0,
                            ),
                            child: Text(
                              'Upload',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('BANK ACCOUNT VERIFICATION'),
                  SizedBox(height: 12.h),
                  CustomPaint(
                    painter: DashedRectPainter(
                      color: context.borderColor,
                      gap: 4.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: context.isDarkMode ? context.inputBg : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.account_balance_rounded,
                              size: 28.w,
                              color: Color(0xFF0058BE),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Primary bank account linked successfully.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: context.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _buildSectionTitle('FINANCIAL CAPACITY PROOF'),
                  SizedBox(height: 4.h),
                  Text(
                    'Upload any one of the following.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color:  Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildFinancialCard(
                    icon: Icons.description_outlined,
                    title: 'Last 6 Months Bank Statement',
                    fileName: _bankStatementFileName,
                    onUpload: () => _pickFile(0),
                    onRemove: () =>
                        setState(() => _bankStatementFileName = null),
                  ),
                  SizedBox(height: 12.h),
                  _buildFinancialCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Latest ITR Acknowledgement',
                    fileName: _itrFileName,
                    onUpload: () => _pickFile(1),
                    onRemove: () => setState(() => _itrFileName = null),
                  ),
                  SizedBox(height: 12.h),
                  _buildFinancialCard(
                    icon: Icons.payments_outlined,
                    title: 'Salary Slips (last 3 months)',
                    fileName: _salarySlipsFileName,
                    onUpload: () => _pickFile(2),
                    onRemove: () => setState(() => _salarySlipsFileName = null),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onSuccess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFF0056D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
              child: Text(
                'Complete Verification',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: context.subTextColor,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildIdentityCard({
    required dynamic icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String statusText,
    required Color statusColor,
    required bool isVerified,
    required Widget rightWidget,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.inputBg : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: icon is IconData
                ? Icon(icon, color: iconColor, size: 24.w)
                : (icon is String
                      ? Image.asset(
                          icon,
                          width: 24.w,
                          height: 24.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.credit_card,
                            color: iconColor,
                            size: 24.w,
                          ),
                        )
                      : SizedBox.shrink()),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (isVerified) ...[
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF004AC6),
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          rightWidget,
        ],
      ),
    );
  }

  Widget _buildFinancialCard({
    required IconData icon,
    required String title,
    required String? fileName,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color:  Color(0xFF64748B), size: 22.w),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                if (fileName != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    fileName,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF004AC6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (fileName == null)
            InkWell(
              onTap: onUpload,
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? const Color(0xFF1E2B4A) : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.file_upload_outlined,
                  color: context.isDarkMode ? Colors.blueAccent : const Color(0xFF2563EB),
                  size: 18.w,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 20.w,
              ),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

// ── NBFC Verification Bottom Sheet ───────────────────────────────────────────
void _showNbfcSheet(BuildContext context, VoidCallback onSuccess) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return NbfcVerificationBottomSheet(onSuccess: onSuccess);
    },
  );
}

class NbfcVerificationBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const NbfcVerificationBottomSheet({super.key, required this.onSuccess});

  @override
  State<NbfcVerificationBottomSheet> createState() =>
      _NbfcVerificationBottomSheetState();
}

class _NbfcVerificationBottomSheetState
    extends State<NbfcVerificationBottomSheet> {
  final _cinController = TextEditingController();
  final _panController = TextEditingController();
  final _rbiRegController = TextEditingController();
  String? _corFileName;

  Future<void> _pickCorFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _corFileName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking COR file: $e');
    }
  }

  @override
  void dispose() {
    _cinController.dispose();
    _panController.dispose();
    _rbiRegController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.85;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2.5.r),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Color(0xFF0056D2),
                    size: 24.w,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints:  BoxConstraints(),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'NBFC Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color:  Color(0xFFC3FAE9), // Light green capsule
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Progress: 25%',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF004AC6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.dividerColor),
          Expanded(
            child: SingleChildScrollView(
              physics:  ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  // CARD 1: Company Registration
                  _buildFormCard(
                    icon: Icons.business_rounded,
                    title: 'Company Registration',
                    children: [
                      _buildFieldLabel('Corporate Identification Number (CIN)'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _cinController,
                        hintText: 'U12345DL2023PTC123456',
                      ),
                      SizedBox(height: 16.h),
                      _buildFieldLabel('Company PAN Card Number'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _panController,
                        hintText: 'ABCDE1234F',
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // CARD 2: RBI Authorization
                  _buildFormCard(
                    icon: Icons.gavel_rounded,
                    title: 'RBI Authorization',
                    children: [
                      _buildFieldLabel('RBI Registration Number'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _rbiRegController,
                        hintText: 'B.14.XXXXX',
                        textCapitalization: TextCapitalization.characters,
                      ),
                      SizedBox(height: 16.h),
                      _buildFieldLabel('RBI Certificate of Registration'),
                      SizedBox(height: 8.h),
                      _buildCorUploadBox(
                        fileName: _corFileName,
                        onTap: _pickCorFile,
                        onRemove: () => setState(() => _corFileName = null),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onSuccess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF0056D2,
                ), // matching blue button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
              child: Text(
                'Submit for Verification',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color:  Color(0xFF0056D2), size: 22.w),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color:  Color(0xFFF1F3F9), // Light grey matching screenshot
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        textCapitalization: textCapitalization,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCorUploadBox({
    required String? fileName,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return CustomPaint(
      painter: DashedRectPainter(color: const Color(0xFFCBD5E1), gap: 4.0),
      child: InkWell(
        onTap: fileName == null ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color:  Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF64748B),
                size: 20.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? 'RBI Certificate of Registration',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      fileName != null
                          ? 'File Uploaded'
                          : 'Upload Original COR',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (fileName == null)
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Color(0xFF0056D2),
                  size: 24.w,
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 20.w,
                  ),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bank Sector Verification Bottom Sheet ────────────────────────────────────
void _showBankSheet(BuildContext context, VoidCallback onSuccess) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BankVerificationBottomSheet(onSuccess: onSuccess);
    },
  );
}

class BankVerificationBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const BankVerificationBottomSheet({super.key, required this.onSuccess});

  @override
  State<BankVerificationBottomSheet> createState() =>
      _BankVerificationBottomSheetState();
}

class _BankVerificationBottomSheetState
    extends State<BankVerificationBottomSheet> {
  final _licenseController = TextEditingController();
  final _panController = TextEditingController();
  final _rbiApproveController = TextEditingController();
  String? _corFileName;

  Future<void> _pickCorFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _corFileName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking COR file: $e');
    }
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _panController.dispose();
    _rbiApproveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.85;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2.5.r),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Color(0xFF0056D2),
                    size: 24.w,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints:  BoxConstraints(),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Bank Sector Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      187,
                      241,
                      219,
                    ), // Light green capsule
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Progress: 25%',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF009668),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.dividerColor),
          Expanded(
            child: SingleChildScrollView(
              physics:  ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  // CARD 1: Bank Registration
                  _buildFormCard(
                    icon: Icons.account_balance_rounded,
                    title: 'Bank Registration',
                    children: [
                      _buildFieldLabel('Bank License Number'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _licenseController,
                        hintText: 'L-12345-XXXX',
                      ),
                      SizedBox(height: 16.h),
                      _buildFieldLabel('Bank PAN Card Number'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _panController,
                        hintText: 'BANK1234F',
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // CARD 2: RBI Authorization
                  _buildFormCard(
                    icon: Icons.gavel_rounded,
                    title: 'RBI Authorization',
                    children: [
                      _buildFieldLabel('RBI Approval Code'),
                      SizedBox(height: 8.h),
                      _buildTextField(
                        controller: _rbiApproveController,
                        hintText: 'RBI-APP-XXXX',
                        textCapitalization: TextCapitalization.characters,
                      ),
                      SizedBox(height: 16.h),
                      _buildFieldLabel('RBI Certificate of Registration'),
                      SizedBox(height: 8.h),
                      _buildCorUploadBox(
                        fileName: _corFileName,
                        onTap: _pickCorFile,
                        onRemove: () => setState(() => _corFileName = null),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onSuccess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF0056D2,
                ), // matching blue button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
              child: Text(
                'Submit for Verification',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color:  Color(0xFF0056D2), size: 22.w),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color:  Color(0xFFF1F3F9), // Light grey matching screenshot
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        textCapitalization: textCapitalization,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCorUploadBox({
    required String? fileName,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return CustomPaint(
      painter: DashedRectPainter(color: const Color(0xFFCBD5E1), gap: 4.0),
      child: InkWell(
        onTap: fileName == null ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color:  Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF64748B),
                size: 20.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? 'RBI Certificate of Registration',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      fileName != null
                          ? 'File Uploaded'
                          : 'Upload Original COR',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (fileName == null)
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Color(0xFF0056D2),
                  size: 24.w,
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 20.w,
                  ),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── DashedRectPainter ────────────────────────────────────────────────────────
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = const Color(0xFF94A3B8),
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(8.r),
      ),
    );

    final Path dashedPath = Path();
    double distance = 0.0;
    for (final PathMetric measure in path.computeMetrics()) {
      while (distance < measure.length) {
        dashedPath.addPath(
          measure.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
