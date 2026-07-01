import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/api_services/need_a_loan_api_services.dart';
import 'package:tm/api_services/give_a_loan_api_services.dart';
import 'package:tm/api_services/common_drop_down_api.dart';
import 'main_navigation.dart';

class NeedALoanFormScreen extends StatefulWidget {
  const NeedALoanFormScreen({super.key});

  @override
  State<NeedALoanFormScreen> createState() => _NeedALoanFormScreenState();
}

class _NeedALoanFormScreenState extends State<NeedALoanFormScreen> {
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  
  Map<String, dynamic>? _selectedOption;
  List<Map<String, dynamic>> _dropdownOptions = [
    {'id': 1348, 'value': '1', 'label': 'Home Loan'},
    {'id': 1349, 'value': '2', 'label': 'Vehicle Loan'},
    {'id': 1350, 'value': '3', 'label': 'Business Loan'},
    {'id': 1351, 'value': '4', 'label': 'Education Loan'},
    {'id': 1352, 'value': '5', 'label': 'Professional Loan'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedOption = _dropdownOptions.first;
    _loadDropdownOptions();
  }

  Future<void> _loadDropdownOptions() async {
    final res = await CommonDropDownApi.fetchDropDownOptions();
    if (mounted) {
      if (res != null && res['error'] == false && res['dropdown'] != null) {
        final List<dynamic> dropdownData = res['dropdown'];
        setState(() {
          _dropdownOptions = dropdownData.map((e) => Map<String, dynamic>.from(e)).toList();
          final exists = _dropdownOptions.any((opt) => opt['value'].toString() == _selectedOption?['value'].toString());
          if (!exists && _dropdownOptions.isNotEmpty) {
            _selectedOption = _dropdownOptions.first;
          }
        });
      }
    }
  }

  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final amt = _amountController.text.trim();
    final rate = _rateController.text.trim();
    final tenure = _tenureController.text.trim();

    if (amt.isEmpty || rate.isEmpty || tenure.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields before submitting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final res = await NeedALoanApiService.submitNeedALoan(
      loanType: _selectedOption?['value']?.toString() ?? '1',
      loanAmt: amt,
      interest: rate,
      loanTenure: tenure,
    );

    setState(() {
      _submitting = false;
    });

    if (mounted) {
      if (res != null) {
        _showSuccessSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      builder: (context) {
        return const _SuccessBottomSheet();
      },
    );

    // Close after 2.5 seconds and go back to home screen
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
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
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AC6),
        elevation: 0,
        leadingWidth: 64.w,
        titleSpacing: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24.w),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
        title: Text(
          'Need a Loan',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Loan Amount (₹)'),
              _buildTextField(_amountController, 'e.g. 500000', TextInputType.number),
              SizedBox(height: 18.h),

              _buildLabel('Interest Rate (% p.a.)'),
              _buildTextField(_rateController, 'e.g. 12', TextInputType.number),
              SizedBox(height: 18.h),

              _buildLabel('Tenure (months)'),
              _buildTextField(_tenureController, 'e.g. 24', TextInputType.number),
              SizedBox(height: 18.h),

              _buildLabel('Loan Type'),
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFBDD8FF), width: 1.2),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.centerLeft,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _dropdownOptions.contains(_selectedOption) ? _selectedOption : (_dropdownOptions.isNotEmpty ? _dropdownOptions.first : null),
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF64748B), size: 24.w),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                    items: _dropdownOptions.map((opt) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: opt,
                        child: Text(opt['label'].toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedOption = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 40.h),

              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit For Review',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType keyboardType) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFBDD8FF), width: 1.2),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class GiveALoanFormScreen extends StatefulWidget {
  const GiveALoanFormScreen({super.key});

  @override
  State<GiveALoanFormScreen> createState() => _GiveALoanFormScreenState();
}

class _GiveALoanFormScreenState extends State<GiveALoanFormScreen> {
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  
  Map<String, dynamic>? _selectedOption;
  List<Map<String, dynamic>> _dropdownOptions = [
    {'id': 1348, 'value': '1', 'label': 'Home Loan'},
    {'id': 1349, 'value': '2', 'label': 'Vehicle Loan'},
    {'id': 1350, 'value': '3', 'label': 'Business Loan'},
    {'id': 1351, 'value': '4', 'label': 'Education Loan'},
    {'id': 1352, 'value': '5', 'label': 'Professional Loan'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedOption = _dropdownOptions.first;
    _loadDropdownOptions();
  }

  Future<void> _loadDropdownOptions() async {
    final res = await CommonDropDownApi.fetchDropDownOptions();
    if (mounted) {
      if (res != null && res['error'] == false && res['dropdown'] != null) {
        final List<dynamic> dropdownData = res['dropdown'];
        setState(() {
          _dropdownOptions = dropdownData.map((e) => Map<String, dynamic>.from(e)).toList();
          final exists = _dropdownOptions.any((opt) => opt['value'].toString() == _selectedOption?['value'].toString());
          if (!exists && _dropdownOptions.isNotEmpty) {
            _selectedOption = _dropdownOptions.first;
          }
        });
      }
    }
  }

  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final amt = _amountController.text.trim();
    final rate = _rateController.text.trim();
    final tenure = _tenureController.text.trim();

    if (amt.isEmpty || rate.isEmpty || tenure.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields before submitting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final res = await GiveALoanApiService.submitGiveALoan(
      loanType: _selectedOption?['value']?.toString() ?? '1',
      loanAmt: amt,
      interest: rate,
      loanTenure: tenure,
    );

    setState(() {
      _submitting = false;
    });

    if (mounted) {
      if (res != null) {
        _showSuccessSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      builder: (context) {
        return const _SuccessBottomSheet();
      },
    );

    // Close after 2.5 seconds and go back to home screen
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
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
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AC6),
        elevation: 0,
        leadingWidth: 64.w,
        titleSpacing: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24.w),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
        title: Text(
          'Give a Loan',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Loan Amount (₹)'),
              _buildTextField(_amountController, 'e.g. 500000', TextInputType.number),
              SizedBox(height: 18.h),

              _buildLabel('Interest Rate (% p.a.)'),
              _buildTextField(_rateController, 'e.g. 12', TextInputType.number),
              SizedBox(height: 18.h),

              _buildLabel('Tenure (months)'),
              _buildTextField(_tenureController, 'e.g. 24', TextInputType.number),
              SizedBox(height: 18.h),

              _buildLabel('Loan Type'),
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFBDD8FF), width: 1.2),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.centerLeft,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _dropdownOptions.contains(_selectedOption) ? _selectedOption : (_dropdownOptions.isNotEmpty ? _dropdownOptions.first : null),
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF64748B), size: 24.w),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                    items: _dropdownOptions.map((opt) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: opt,
                        child: Text(opt['label'].toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedOption = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 40.h),

              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit For Review',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType keyboardType) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFBDD8FF), width: 1.2),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _SuccessBottomSheet extends StatelessWidget {
  const _SuccessBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 36.h),

          // Green circle check icon
          Container(
            width: 72.w,
            height: 72.w,
            decoration: const BoxDecoration(
              color: Color(0xFFE8FDF0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              size: 44.w,
            ),
          ),
          SizedBox(height: 24.h),

          // Text message
          Text(
            'Submit Successfully',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
