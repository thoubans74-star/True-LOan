import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Loans', 'Account'];

  // Notification data model  
  final List<_NotificationItem> _allNotifications = [
    _NotificationItem(
      icon: Icons.camera_alt_rounded,
      iconBgColor: const Color(0xFF1A3C8E),
      iconColor: Colors.white,
      title: 'Loan Request Approved',
      time: '2 mins ago',
      description:
          'Your loan request for \$5,000 has been approved by the lender. Funds will be available shortly.',
      isUnread: true,
      category: 'Loans',
      section: 'TODAY',
    ),
    _NotificationItem(
      icon: Icons.shield_rounded,
      iconBgColor: const Color(0xFFFFEBEE),
      iconColor: const Color(0xFFD32F2F),
      title: 'New Login Detected',
      time: '45 mins ago',
      description:
          'A new login was detected from a MacBook Pro in San Francisco. Was this you?',
      isUnread: true,
      category: 'Account',
      section: 'TODAY',
    ),
    _NotificationItem(
      icon: Icons.insert_chart_rounded,
      iconBgColor: const Color(0xFFE8EAF6),
      iconColor: const Color(0xFF1A3C8E),
      title: 'Portfolio Milestone',
      time: '1 day ago',
      description:
          'Congratulations! Your portfolio has grown by 12.4% this month. View your performance report.',
      isUnread: false,
      category: 'Loans',
      section: 'YESTERDAY',
    ),
    _NotificationItem(
      icon: Icons.campaign_rounded,
      iconBgColor: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFE65100),
      title: 'Ad Performance Update',
      time: '1 day ago',
      description:
          "Your 'Business Expansion' ad reached 1,500 more investors yesterday. Check new inquiries.",
      isUnread: false,
      category: 'Account',
      section: 'YESTERDAY',
    ),
  ];

  List<_NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 0) return _allNotifications;
    final category = _filters[_selectedFilter];
    return _allNotifications
        .where((n) => n.category == category)
        .toList();
  }


  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final todayItems =
        filtered.where((n) => n.section == 'TODAY').toList();
    final yesterdayItems =
        filtered.where((n) => n.section == 'YESTERDAY').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // ── Blue Header (same as MarketPlace) ──────────
          Container(
            color: const Color(0xFF004AC6),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20.w,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

            SizedBox(height: 14.h),

            // ── Filter Chips ─────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A3C8E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1A3C8E)
                                : const Color(0xFFDDE1EA),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected ? Colors.white : const Color(0xFF4A5568),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: 16.h),

            // ── Notification List ────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const BouncingScrollPhysics(),
                children: [
                  if (todayItems.isNotEmpty) ...[
                    _buildSectionHeader('TODAY'),
                    SizedBox(height: 8.h),
                    ...todayItems.map((n) => _buildNotificationCard(n)),
                  ],
                  if (yesterdayItems.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Divider(
                      color: const Color(0xFFE0E0E0),
                      thickness: 0.8,
                      height: 24.h,
                    ),
                    _buildSectionHeader('YESTERDAY'),
                    SizedBox(height: 8.h),
                    ...yesterdayItems.map((n) => _buildNotificationCard(n)),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
    );
  }

  // ── Section Header (TODAY / YESTERDAY) ──────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, top: 8.h, bottom: 4.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8A8FA3),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // ── Notification Card ───────────────────────────────────
  Widget _buildNotificationCard(_NotificationItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 18.w,
            ),
          ),
          SizedBox(width: 12.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      item.time,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
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

// ── Data Model ─────────────────────────────────────────────
class _NotificationItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String time;
  final String description;
  bool isUnread;
  final String category; // 'Loans' or 'Account'
  final String section; // 'TODAY' or 'YESTERDAY'

  _NotificationItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.description,
    required this.isUnread,
    required this.category,
    required this.section,
  });
}
