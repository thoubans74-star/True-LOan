import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/marketplace_api_service.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  List<Map<String, dynamic>> _myAds = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadMyAds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMyAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String currentUserId = prefs.getString('user_id') ?? '';
      final String cachedName = prefs.getString('name') ?? 'Profile';

      final lenders = await MarketplaceApiService.fetchLenders();
      final borrowers = await MarketplaceApiService.fetchBorrowers();

      final List<Map<String, dynamic>> combined = [];

      if (lenders != null) {
        final filteredLenders = lenders
            .where((l) => l['ledger_name']?.toString() == currentUserId)
            .map((l) {
              final amt = l['loan_amt'];
              final tenure = l['loan_tenure'];
              final id = int.tryParse(l['id']?.toString() ?? '') ?? 0;
              return {
                'id': id,
                'name': cachedName,
                'role': 'Individual Lender',
                'requiredAmount': amt != null ? '₹$amt' : '₹0',
                'tenure': tenure != null ? '$tenure Months' : '12 Months',
              };
            })
            .toList();
        combined.addAll(filteredLenders);
      }

      if (borrowers != null) {
        final filteredBorrowers = borrowers
            .where((b) => b['ledger_name']?.toString() == currentUserId)
            .map((b) {
              final amt = b['loan_amt'];
              final tenure = b['loan_tenure'];
              final id = int.tryParse(b['id']?.toString() ?? '') ?? 0;
              return {
                'id': id,
                'name': cachedName,
                'role': 'Individual Borrower',
                'requiredAmount': amt != null ? '₹$amt' : '₹0',
                'tenure': tenure != null ? '$tenure Months' : '12 Months',
              };
            })
            .toList();
        combined.addAll(filteredBorrowers);
      }

      // Sort by ID descending to put the last filled form on top
      combined.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));

      // Take only the last 20 forms
      final limitedList = combined.take(20).toList();

      if (mounted) {
        setState(() {
          _myAds = limitedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user ads: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAds = _myAds.where((ad) {
      if (_searchQuery.isEmpty) return true;
      final name = (ad['name'] ?? '').toString().toLowerCase();
      final role = (ad['role'] ?? '').toString().toLowerCase();
      final amount = (ad['requiredAmount'] ?? '').toString().toLowerCase();
      final tenure = (ad['tenure'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) ||
          role.contains(_searchQuery) ||
          amount.contains(_searchQuery) ||
          tenure.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Blue AppBar ──────────────────────────────────────────────────
          Container(
            color: const Color(0xFF004AC6),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                    Text(
                      'My Ads',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search Bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDF5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF727785),
                    size: 23.w,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search my ads...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF727785),
                          fontSize: 13.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                      child: Icon(
                        Icons.clear_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 18.w,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Ads List ──────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF004AC6),
                      ),
                    ),
                  )
                : filteredAds.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'No ads submitted yet.' : 'No matching ads found.',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                    physics: const ClampingScrollPhysics(),
                    itemCount: filteredAds.length,
                    itemBuilder: (context, index) {
                      final ad = filteredAds[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: _MyAdListCard(
                          name: ad['name'] ?? 'Profile',
                          role: ad['role'] ?? '',
                          requiredAmount: ad['requiredAmount'] ?? '',
                          tenure: ad['tenure'] ?? '',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MyAdListCard extends StatelessWidget {
  final String name;
  final String role;
  final String requiredAmount;
  final String tenure;

  const _MyAdListCard({
    required this.name,
    required this.role,
    required this.requiredAmount,
    required this.tenure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // #0000000D
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Avatar + Name/Role
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  'assets/home/mohan_profile.png',
                  width: 46.w,
                  height: 46.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 46.w,
                      height: 46.w,
                      color: const Color(0xFFF1F5F9),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF64748B),
                        size: 24.w,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Divider Line
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Container(height: 1, color: const Color(0xFFEEF2F6)),
          ),

          // Required Amount & Tenure Row (Exactly like Marketplace Card)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Required Amount',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    'Tenure',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    requiredAmount,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF003178),
                    ),
                  ),
                  Text(
                    tenure,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
