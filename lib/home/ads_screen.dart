import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'marketplace_screen.dart';

class AdsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  const AdsScreen({super.key, this.onBackTap});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  List<MarketUser> _bookmarkedUsers = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 for Lenders, 1 for Borrowers

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> bookmarkedJsonList = prefs.getStringList('bookmarked_users') ?? [];
      final List<MarketUser> users = [];
      for (var jsonStr in bookmarkedJsonList) {
        try {
          final decoded = jsonDecode(jsonStr);
          users.add(MarketUser.fromJson(decoded));
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _bookmarkedUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDetailsBottomSheet(MarketUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final screenHeight = mediaQuery.size.height;
        final statusBarHeight = mediaQuery.padding.top;
        final topOffset = statusBarHeight + 56.0 + 148.0;
        final bottomSheetHeight = screenHeight - topOffset;

        return DetailsBottomSheet(user: user, height: bottomSheetHeight);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _bookmarkedUsers.where((user) {
      // Role toggle check
      final matchesRole = _selectedTab == 0
          ? user.role.toLowerCase().contains('lender')
          : user.role.toLowerCase().contains('borrower');
      return matchesRole;
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF004AC6),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Blue AppBar ──────────────────────────────────────────────────
          Container(
            color: const Color(0xFF004AC6),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  children: [
                    Text(
                      'Book Marks',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Lenders / Borrowers Toggle ────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        gradient: _selectedTab == 0
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF004AC6),
                                  Color(0xFF135AF7),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: _selectedTab != 0 ? Colors.white : null,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: const Color(0xFF004AC6),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Lenders',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 0
                              ? Colors.white
                              : const Color(0xFF004AC6),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        gradient: _selectedTab == 1
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF004AC6),
                                  Color(0xFF135AF7),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: _selectedTab != 1 ? Colors.white : null,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: const Color(0xFF004AC6),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Borrowers',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 1
                              ? Colors.white
                              : const Color(0xFF004AC6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bookmarks List ──────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF004AC6),
                    ),
                  )
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border_rounded,
                              color: const Color(0xFF94A3B8),
                              size: 48.w,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              _selectedTab == 0
                                  ? 'No Bookmarked Lenders'
                                  : 'No Bookmarked Borrowers',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                        physics: const ClampingScrollPhysics(),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: MarketCard(
                              user: user,
                              onViewDetailsTap: () => _showDetailsBottomSheet(user),
                              onBookmarkToggle: _loadBookmarks,
                            ),
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
