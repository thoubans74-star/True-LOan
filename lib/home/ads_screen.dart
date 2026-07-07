import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tm/theme_manager.dart';
import 'marketplace_screen.dart';
import '../api_services/bookmark_api_service.dart';
import '../api_services/marketplace_api_service.dart';

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
      final profilesData = await MarketplaceApiService.fetchProfiles();
      final lendersData = await MarketplaceApiService.fetchLenders();
      final borrowersData = await MarketplaceApiService.fetchBorrowers();
      final dbBookmarks = await BookmarkApiService.fetchBookmarks();

      final Map<String, Map<String, dynamic>> profilesMap = {};
      if (profilesData != null) {
        for (var prof in profilesData) {
          final String idStr = prof['id']?.toString() ?? '';
          final String nameStr = prof['ledger_Name']?.toString().toLowerCase() ?? '';
          if (idStr.isNotEmpty) profilesMap[idStr] = prof;
          if (nameStr.isNotEmpty) profilesMap[nameStr] = prof;
        }
      }

      final List<MarketUser> lendersList = [];
      if (lendersData != null) {
        for (var item in lendersData) {
          lendersList.add(MarketplaceScreen.mapToMarketUser(item, 'Individual Lender', profilesMap));
        }
      }

      final List<MarketUser> borrowersList = [];
      if (borrowersData != null) {
        for (var item in borrowersData) {
          borrowersList.add(MarketplaceScreen.mapToMarketUser(item, 'Individual Borrower', profilesMap));
        }
      }

      final List<MarketUser> resolvedBookmarks = [];
      final List<String> updatedBookmarksJson = [];

      if (dbBookmarks != null) {
        for (var b in dbBookmarks) {
          if (b['status'] == 1 || b['status']?.toString() == '1') {
            final String loanId = b['loan_id']?.toString() ?? '';
            final String sourceTable = b['source_table']?.toString() ?? '';

            if (sourceTable == '10101') {
              // Borrower
              final matched = borrowersList.firstWhere(
                (u) => u.loanId == loanId,
                orElse: () => const MarketUser(
                  name: '', role: '', isPopular: false, requiredAmount: '',
                  tenure: '', interestRate: '', income: '', creditScore: 0,
                  creditRatingText: '', verifiedDocs: [], profileImage: '',
                  category: '', location: '', phone: '', loanId: '', userId: ''
                ),
              );
              if (matched.loanId.isNotEmpty) {
                resolvedBookmarks.add(matched);
                updatedBookmarksJson.add(jsonEncode(matched.toJson()));
              }
            } else if (sourceTable == '10201') {
              // Lender
              final matched = lendersList.firstWhere(
                (u) => u.loanId == loanId,
                orElse: () => const MarketUser(
                  name: '', role: '', isPopular: false, requiredAmount: '',
                  tenure: '', interestRate: '', income: '', creditScore: 0,
                  creditRatingText: '', verifiedDocs: [], profileImage: '',
                  category: '', location: '', phone: '', loanId: '', userId: ''
                ),
              );
              if (matched.loanId.isNotEmpty) {
                resolvedBookmarks.add(matched);
                updatedBookmarksJson.add(jsonEncode(matched.toJson()));
              }
            }
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('bookmarked_users', updatedBookmarksJson);
      MarketCard.bookmarksNotifier.value++;

      if (mounted) {
        setState(() {
          _bookmarkedUsers = resolvedBookmarks;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bookmarks from server, falling back to local: $e');
      // Fallback to local SharedPreferences cache
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
      } catch (err) {
        debugPrint('Fallback failed: $err');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
      value: context.themedStatusBar,
      child: Scaffold(
      backgroundColor: context.pageBg,
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
            color: context.cardBg,
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
                        color: _selectedTab != 0 ? context.cardBg : null,
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
                        color: _selectedTab != 1 ? context.cardBg : null,
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
                                color: context.subTextColor,
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
