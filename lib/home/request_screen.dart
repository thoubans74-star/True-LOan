import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RequestStatus { pending, approved, closed }

class LoanRequest {
  final String name;
  final String requestId;
  final String requestedAmount;
  final String interestRate;
  final String date;
  final RequestStatus status;
  final String? imageUrl;

  const LoanRequest({
    required this.name,
    required this.requestId,
    required this.requestedAmount,
    required this.interestRate,
    required this.date,
    required this.status,
    this.imageUrl,
  });
}

// ----------------- SCREEN -----------------

class RequestScreen extends StatelessWidget {
  final VoidCallback? onBackTap;

  const RequestScreen({super.key, this.onBackTap});

  static const Color primaryBlue = Color(0xFF1646C7);
  static const Color greenAccent = Color(0xFF1E8E5A);
  static const Color purpleAccent = Color(0xFF7B3FE4);

  final List<LoanRequest> requests = const [
    LoanRequest(
      name: 'Marcus Thorne',
      requestId: '#TR-9821',
      requestedAmount: '₹25,00,000',
      interestRate: '10.5% p.a.',
      date: 'Oct 24, 2023',
      status: RequestStatus.pending,
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    LoanRequest(
      name: 'Sarah Jenkins',
      requestId: '#TR-9744',
      requestedAmount: '₹12,50,000',
      interestRate: '9.8% p.a.',
      date: 'Oct 18, 2023',
      status: RequestStatus.approved,
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    LoanRequest(
      name: 'Rahul Verma',
      requestId: '#TR-9502',
      requestedAmount: '₹5,00,000',
      interestRate: '11.2% p.a.',
      date: 'Sep 30, 2023',
      status: RequestStatus.closed,
      imageUrl: 'https://randomuser.me/api/portraits/men/65.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24.w,
          ),
          onPressed: () {
            if (onBackTap != null) {
              onBackTap!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Request',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            SizedBox(height: 24.h),
            _buildSectionHeader(),
            SizedBox(height: 12.h),
            ...requests.map(
              (r) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _RequestCard(request: r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REQUESTS OVERVIEW',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Requests',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '08',
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '03',
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: purpleAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          'Filter',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: greenAccent,
          ),
        ),
      ],
    );
  }
}

// ----------------- CARD WIDGET -----------------

class _RequestCard extends StatelessWidget {
  final LoanRequest request;

  const _RequestCard({required this.request});

  static const Color greenAccent = Color(0xFF1E8E5A);

  Color get _borderColor {
    switch (request.status) {
      case RequestStatus.pending:
        return const Color(0xFFD6A8E8); // light purple/pink
      case RequestStatus.approved:
        return const Color(0xFF6FCF97); // light green
      case RequestStatus.closed:
        return const Color(0xFFE0E0E0); // light grey
    }
  }

  Widget _buildStatusBadge() {
    late Color bg;
    late Color fg;
    late String label;

    switch (request.status) {
      case RequestStatus.pending:
        bg = const Color(0xFFFCE7D4);
        fg = const Color(0xFFE08A2C);
        label = 'PENDING';
        break;
      case RequestStatus.approved:
        bg = const Color(0xFFDCF3E4);
        fg = const Color(0xFF1E8E5A);
        label = 'APPROVED';
        break;
      case RequestStatus.closed:
        bg = const Color(0xFFE9EBEE);
        fg = const Color(0xFF6B7280);
        label = 'CLOSED';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: fg,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    switch (request.status) {
      case RequestStatus.pending:
        return SizedBox(
          height: 27.h,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor:  Color(0xFFE8F5E9),
              foregroundColor: greenAccent,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.r),
              ),
            ),
            child: Text(
              'View Details',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      case RequestStatus.approved:
        return SizedBox(
          height: 27.h,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor:  Color(0xFF1E7A4C),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.r),
              ),
            ),
            child: Text(
              'Accept Offer',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      case RequestStatus.closed:
        return SizedBox(
          height: 27.h,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor:  Color(0xFFEEEEEE),
              disabledForegroundColor: Colors.grey.shade600,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.r),
              ),
            ),
            child: Text(
              'Expired',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border(left: BorderSide(color: _borderColor, width: 4.w)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: request.imageUrl != null
                    ? NetworkImage(request.imageUrl!)
                    : null,
                child: request.imageUrl == null
                    ? Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            request.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildStatusBadge(),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Request ID: ${request.requestId}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested Amount',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      request.requestedAmount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Interest Rate',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      request.interestRate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: request.status == RequestStatus.closed
                            ? Colors.black54
                            : greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.date,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              _buildBottomAction(),
            ],
          ),
        ],
      ),
    );
  }
}
