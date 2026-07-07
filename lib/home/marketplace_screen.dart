import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tm/theme_manager.dart';
import '../api_services/location_api_service.dart';
import '../api_services/marketplace_api_service.dart';
import '../api_services/bookmark_api_service.dart';
import '../utils/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketUser {
  final String name;
  final String role;
  final bool isPopular;
  final String requiredAmount;
  final String tenure;
  final String interestRate;
  final String income;
  final int creditScore;
  final String creditRatingText;
  final List<String> verifiedDocs;
  final String profileImage;
  final String category;
  final String location;
  final String phone;
  final String loanId;
  final String userId;

  const MarketUser({
    required this.name,
    required this.role,
    required this.isPopular,
    required this.requiredAmount,
    required this.tenure,
    required this.interestRate,
    required this.income,
    required this.creditScore,
    required this.creditRatingText,
    required this.verifiedDocs,
    required this.profileImage,
    required this.category,
    required this.location,
    required this.phone,
    required this.loanId,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'isPopular': isPopular,
        'requiredAmount': requiredAmount,
        'tenure': tenure,
        'interestRate': interestRate,
        'income': income,
        'creditScore': creditScore,
        'creditRatingText': creditRatingText,
        'verifiedDocs': verifiedDocs,
        'profileImage': profileImage,
        'category': category,
        'location': location,
        'phone': phone,
        'loanId': loanId,
        'userId': userId,
      };

  factory MarketUser.fromJson(Map<String, dynamic> json) => MarketUser(
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        isPopular: json['isPopular'] ?? false,
        requiredAmount: json['requiredAmount'] ?? '',
        tenure: json['tenure'] ?? '',
        interestRate: json['interestRate'] ?? '',
        income: json['income'] ?? '',
        creditScore: json['creditScore'] ?? 0,
        creditRatingText: json['creditRatingText'] ?? '',
        verifiedDocs: List<String>.from(json['verifiedDocs'] ?? []),
        profileImage: json['profileImage'] ?? '',
        category: json['category'] ?? '',
        location: json['location'] ?? 'Namakkal, Tamil Nadu',
        phone: json['phone'] ?? '9965604117',
        loanId: json['loanId'] ?? '',
        userId: json['userId'] ?? '',
      );
}

class MarketplaceScreen extends StatefulWidget {
  static final ValueNotifier<Map<String, String>?> detailsTrigger = ValueNotifier(null);

  const MarketplaceScreen({super.key});

  static MarketUser mapToMarketUser(Map<String, dynamic> item, String role, Map<String, Map<String, dynamic>> profilesMap) {
    final ledgerName = item['ledger_name']?.toString() ?? 'Unknown';
    final uidStr = item['uid']?.toString() ?? '';

    final profile = profilesMap[uidStr] ?? profilesMap[ledgerName.toLowerCase()];

    final String name = profile?['ledger_Name']?.toString() ?? ledgerName;
    final String rawPhone = profile?['mobile']?.toString() ?? profile?['phone']?.toString() ?? '9965604117';
    final String phone = rawPhone.trim();

    final dynamic rawAmt = item['loan_amt'];
    final dynamic rawTenure = item['loan_tenure'];
    final dynamic rawInterest = item['interest'];

    final String amount = rawAmt != null ? '₹$rawAmt' : '₹0';
    final String tenure = rawTenure != null ? '$rawTenure Months' : '12 Months';
    final String interest = rawInterest != null ? '$rawInterest% p.a.' : '12% p.a.';

    final String category = item['loan_type']?.toString().toUpperCase() ?? 'PERSONAL';

    String getStateName(String? state) {
      if (state == null || state.isEmpty) return 'Tamil Nadu';
      final s = state.trim().toLowerCase();
      if (s == '33' || s.contains('tamil')) return 'Tamil Nadu';
      if (s == '29' || s.contains('karnataka')) return 'Karnataka';
      if (s == '32' || s.contains('kerala')) return 'Kerala';
      if (s == '27' || s.contains('maharashtra')) return 'Maharashtra';
      if (s == '30' || s.contains('goa')) return 'Goa';
      if (s == '7' || s.contains('delhi')) return 'Delhi';
      if (s == '37' || s.contains('andhra')) return 'Andhra Pradesh';
      if (s == '36' || s.contains('telangana')) return 'Telangana';
      if (s == '8' || s.contains('rajasthan')) return 'Rajasthan';
      if (s == '9' || s.contains('uttar')) return 'Uttar Pradesh';
      if (s == '24' || s.contains('gujarat')) return 'Gujarat';
      if (s == '19' || s.contains('bengal')) return 'West Bengal';
      if (s == '3' || s.contains('punjab')) return 'Punjab';
      if (s == '6' || s.contains('haryana')) return 'Haryana';
      if (s == '10' || s.contains('bihar')) return 'Bihar';
      if (s == '1' || s.contains('jammu')) return 'Jammu & Kashmir';
      if (s == '5' || s.contains('uttarakhand')) return 'Uttarakhand';
      if (s == '2' || s.contains('himachal')) return 'Himachal Pradesh';
      if (s == '20' || s.contains('jharkhand')) return 'Jharkhand';
      if (s == '21' || s.contains('odisha')) return 'Odisha';
      if (s == '22' || s.contains('chhattisgarh')) return 'Chhattisgarh';
      if (s == '23' || s.contains('madhya')) return 'Madhya Pradesh';
      return '${state[0].toUpperCase()}${state.substring(1).toLowerCase()}';
    }

    String getDistrictName(String? district) {
      if (district == null || district.isEmpty) return 'Namakkal';
      final d = district.trim().toLowerCase();
      if (d == '1' || d.contains('chennai')) return 'Chennai';
      if (d == '2' || d.contains('coimbatore')) return 'Coimbatore';
      if (d == '3' || d.contains('madurai')) return 'Madurai';
      if (d == '4' || d.contains('tiruchirappalli')) return 'Tiruchirappalli';
      if (d == '5' || d.contains('salem')) return 'Salem';
      if (d == '6' || d.contains('erode')) return 'Erode';
      if (d == '7' || d.contains('vellore')) return 'Vellore';
      if (d == '8' || d.contains('tirunelveli')) return 'Tirunelveli';
      if (d == '122' || d.contains('namakkal')) return 'Namakkal';
      if (RegExp(r'^[a-zA-Z\s_]+$').hasMatch(district)) {
        return district.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
      }
      return 'Namakkal';
    }

    String rawState = profile?['state']?.toString() ?? '';
    String rawDistrict = profile?['district']?.toString() ?? '';

    if (rawState.isEmpty || rawDistrict.isEmpty) {
      final String address = profile?['address']?.toString() ?? '';
      if (address.isNotEmpty) {
        final parts = address.split(',').map((p) => p.trim()).toList();
        if (parts.length >= 2) {
          if (rawState.isEmpty) rawState = parts.last;
          if (rawDistrict.isEmpty) rawDistrict = parts[parts.length - 2];
        } else if (parts.isNotEmpty) {
          if (rawDistrict.isEmpty) rawDistrict = parts.first;
        }
      }
    }

    final String stateName = getStateName(rawState);
    final String districtName = getDistrictName(rawDistrict);
    final String location = '$districtName, $stateName';

    final String rawPhoto = profile?['photo']?.toString() ?? profile?['Image']?.toString() ?? '';
    final String profileImage = rawPhoto.startsWith('http') ? rawPhoto : 'assets/home/mohan_profile.png';

    return MarketUser(
      name: name,
      role: role,
      isPopular: (item['id'] ?? 0) % 3 == 0,
      requiredAmount: amount,
      tenure: tenure,
      interestRate: interest,
      income: amount,
      creditScore: 720,
      creditRatingText: '700+ GOOD',
      verifiedDocs: const ['Identity Verified', 'Income Verified'],
      profileImage: profileImage,
      category: category,
      location: location,
      phone: phone,
      loanId: item['id']?.toString() ?? '',
      userId: uidStr,
    );
  }

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedTab = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  int? _minAmountFilter;
  int? _maxAmountFilter;
  String? _selectedInterestFilter;
  List<String> _selectedLoanTypesFilter = [];
  String? _selectedTenureFilter;
  String? _selectedStateFilterVal;
  String? _selectedStateFilterLabel;
  String? _selectedDistrictFilterVal;
  String? _selectedDistrictFilterLabel;
  String? _selectedDateRangeFilter;

  List<MarketUser> _lenders = [];
  List<MarketUser> _borrowers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarketplaceData();
    MarketplaceScreen.detailsTrigger.addListener(_handleExternalDetailsTrigger);
  }

  Future<void> _loadMarketplaceData() async {
    try {
      final profilesData = await MarketplaceApiService.fetchProfiles();
      final lendersData = await MarketplaceApiService.fetchLenders();
      final borrowersData = await MarketplaceApiService.fetchBorrowers();
      final dbBookmarks = await BookmarkApiService.fetchBookmarks();

      final prefs = await SharedPreferences.getInstance();
      final String currentUserId = prefs.getString('user_id') ?? '';

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
          final String itemUid = item['uid']?.toString() ?? '';
          final String itemLedger = item['ledger_name']?.toString() ?? '';
          if (currentUserId.isNotEmpty && (itemUid == currentUserId || itemLedger == currentUserId)) {
            continue; // Skip own ad in Marketplace
          }
          lendersList.add(MarketplaceScreen.mapToMarketUser(item, 'Individual Lender', profilesMap));
        }
      }

      final List<MarketUser> borrowersList = [];
      if (borrowersData != null) {
        for (var item in borrowersData) {
          final String itemUid = item['uid']?.toString() ?? '';
          final String itemLedger = item['ledger_name']?.toString() ?? '';
          if (currentUserId.isNotEmpty && (itemUid == currentUserId || itemLedger == currentUserId)) {
            continue; // Skip own ad in Marketplace
          }
          borrowersList.add(MarketplaceScreen.mapToMarketUser(item, 'Individual Borrower', profilesMap));
        }
      }

      // Sync local SharedPreferences cache with database bookmarks
      if (dbBookmarks != null) {
        final List<String> updatedBookmarksJson = [];
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
                updatedBookmarksJson.add(jsonEncode(matched.toJson()));
              }
            }
          }
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('bookmarked_users', updatedBookmarksJson);
        MarketCard.bookmarksNotifier.value++;
      }

      if (mounted) {
        setState(() {
          _lenders = lendersList;
          _borrowers = borrowersList;
          _isLoading = false;
        });
        _handleExternalDetailsTrigger();
      }
    } catch (e) {
      debugPrint('Error loading marketplace data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    MarketplaceScreen.detailsTrigger.removeListener(_handleExternalDetailsTrigger);
    super.dispose();
  }

  void _handleExternalDetailsTrigger() {
    if (!mounted) return;
    final trigger = MarketplaceScreen.detailsTrigger.value;
    if (trigger == null) return;
    if (_isLoading) return;
    
    final String targetName = trigger['name'] ?? '';
    final String targetRole = trigger['role'] ?? '';
    
    MarketUser? matchedUser;
    final List<MarketUser> searchList = targetRole.toLowerCase().contains('lender') ? _lenders : _borrowers;
    
    for (var u in searchList) {
      if (u.name.toLowerCase() == targetName.toLowerCase()) {
        matchedUser = u;
        break;
      }
    }
    
    if (matchedUser == null) {
      for (var u in _lenders) {
        if (u.name.toLowerCase() == targetName.toLowerCase()) {
          matchedUser = u;
          break;
        }
      }
    }
    if (matchedUser == null) {
      for (var u in _borrowers) {
        if (u.name.toLowerCase() == targetName.toLowerCase()) {
          matchedUser = u;
          break;
        }
      }
    }
    
    if (matchedUser != null) {
      MarketplaceScreen.detailsTrigger.value = null;
      
      final int targetTab = matchedUser.role.toLowerCase().contains('lender') ? 0 : 1;
      if (_selectedTab != targetTab) {
        setState(() {
          _selectedTab = targetTab;
        });
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDetailsBottomSheet(matchedUser!);
      });
    } else {
      MarketplaceScreen.detailsTrigger.value = null;
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

  void _showFilterOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FilterOptionsBottomSheet(
          initialMinAmount: _minAmountFilter,
          initialMaxAmount: _maxAmountFilter,
          initialInterest: _selectedInterestFilter,
          initialLoanTypes: _selectedLoanTypesFilter,
          initialTenure: _selectedTenureFilter,
          initialStateVal: _selectedStateFilterVal,
          initialStateLabel: _selectedStateFilterLabel,
          initialDistrictVal: _selectedDistrictFilterVal,
          initialDistrictLabel: _selectedDistrictFilterLabel,
          initialDateRange: _selectedDateRangeFilter,
          onApply: (minAmt, maxAmt, interest, types, tenure, stateVal, stateLabel, distVal, distLabel, dateRange) {
            setState(() {
              _minAmountFilter = minAmt;
              _maxAmountFilter = maxAmt;
              _selectedInterestFilter = interest;
              _selectedLoanTypesFilter = types;
              _selectedTenureFilter = tenure;
              _selectedStateFilterVal = stateVal;
              _selectedStateFilterLabel = stateLabel;
              _selectedDistrictFilterVal = distVal;
              _selectedDistrictFilterLabel = distLabel;
              _selectedDateRangeFilter = dateRange;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<MarketUser> rawList = _selectedTab == 0 ? _lenders : _borrowers;
    final List<MarketUser> filteredList = rawList.where((u) {
      if (_searchQuery.isNotEmpty) {
        if (!u.name.toLowerCase().contains(_searchQuery)) return false;
      }
      
      if (_minAmountFilter != null || _maxAmountFilter != null) {
        final amountClean = int.tryParse(u.requiredAmount.replaceAll(RegExp(r'\D'), ''));
        if (amountClean != null) {
          if (_minAmountFilter != null && amountClean < _minAmountFilter!) return false;
          if (_maxAmountFilter != null && amountClean > _maxAmountFilter!) return false;
        }
      }

      if (_selectedInterestFilter != null) {
        final rateMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(u.interestRate);
        if (rateMatch != null) {
          final rate = double.tryParse(rateMatch.group(1) ?? '');
          if (rate != null) {
            if (_selectedInterestFilter == '5%-10 %' && (rate < 5.0 || rate > 10.0)) return false;
            if (_selectedInterestFilter == '10%-25 %' && (rate < 10.0 || rate > 25.0)) return false;
            if (_selectedInterestFilter == '25%-50 %' && (rate < 25.0 || rate > 50.0)) return false;
            if (_selectedInterestFilter == '50%-75 %' && (rate < 50.0 || rate > 75.0)) return false;
            if (_selectedInterestFilter == '75%' && rate < 75.0) return false;
          }
        }
      }

      if (_selectedLoanTypesFilter.isNotEmpty) {
        if (!_selectedLoanTypesFilter.any((type) => u.category.toLowerCase() == type.toLowerCase() || u.role.toLowerCase().contains(type.toLowerCase()))) {
          return false;
        }
      }

      if (_selectedTenureFilter != null) {
        final monthsMatch = RegExp(r'(\d+)').firstMatch(u.tenure);
        if (monthsMatch != null) {
          final months = int.tryParse(monthsMatch.group(1) ?? '');
          if (months != null) {
            if (_selectedTenureFilter == 'Short Term' && months > 18) return false;
            if (_selectedTenureFilter == 'Long Term' && months <= 18) return false;
          }
        }
      }

      return true;
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.themedStatusBar,
      child: Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      body: Column(
        children: [
          Container(
            color: const Color(0xFF004AC6),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  children: [
                    Text(
                      'MarketPlace',
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

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                  Container(
                    color: context.pageBg,
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: context.inputBg,
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
                                      hintText: _selectedTab == 0
                                          ? 'Search lenders...'
                                          : 'Search borrowers...',
                                      hintStyle: GoogleFonts.inter(
                                        color: context.subTextColor,
                                        fontSize: 13.sp,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      color: context.textColor,
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
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: _showFilterOptionsBottomSheet,
                          child: Container(
                            width: 48.h,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF004AC6),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 22.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: context.cardBg,
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                gradient: _selectedTab == 0
                                    ? LinearGradient(
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
                                    ? LinearGradient(
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

                  Divider(height: 1, color: context.dividerColor),

                  Container(
                    color: context.cardBg,
                    child: filteredList.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Center(
                              child: Text(
                                'No profiles found',
                                style: GoogleFonts.inter(
                                  color:  Color(0xFF94A3B8),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(20, 16, 20, 100),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: MarketCard(
                                user: filteredList[index],
                                onViewDetailsTap: () => _showDetailsBottomSheet(
                                  filteredList[index],
                                ),
                              ),
                            ),
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

class MarketCard extends StatefulWidget {
  final MarketUser user;
  final VoidCallback onViewDetailsTap;
  final VoidCallback? onBookmarkToggle;

  static final ValueNotifier<int> bookmarksNotifier = ValueNotifier<int>(0);

  const MarketCard({
    required this.user,
    required this.onViewDetailsTap,
    this.onBookmarkToggle,
  });

  @override
  State<MarketCard> createState() => MarketCardState();
}

class MarketCardState extends State<MarketCard> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    MarketCard.bookmarksNotifier.addListener(_checkBookmarkStatus);
  }

  @override
  void dispose() {
    MarketCard.bookmarksNotifier.removeListener(_checkBookmarkStatus);
    super.dispose();
  }

  bool _isSameUser(Map<String, dynamic> decoded, MarketUser target) {
    if (decoded['loanId'] != null && decoded['loanId'].toString().isNotEmpty && target.loanId.isNotEmpty) {
      return decoded['loanId'].toString() == target.loanId && decoded['role'] == target.role;
    }
    return decoded['name'] == target.name &&
        decoded['role'] == target.role &&
        decoded['requiredAmount'] == target.requiredAmount &&
        decoded['tenure'] == target.tenure &&
        decoded['interestRate'] == target.interestRate &&
        decoded['phone'] == target.phone;
  }

  Future<void> _checkBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarkedJsonList = prefs.getStringList('bookmarked_users') ?? [];
    bool found = false;
    for (var jsonStr in bookmarkedJsonList) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (_isSameUser(decoded, widget.user)) {
          found = true;
          break;
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _isBookmarked = found;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarkedJsonList = prefs.getStringList('bookmarked_users') ?? [];
    
    int index = -1;
    for (int i = 0; i < bookmarkedJsonList.length; i++) {
      try {
        final decoded = jsonDecode(bookmarkedJsonList[i]);
        if (_isSameUser(decoded, widget.user)) {
          index = i;
          break;
        }
      } catch (_) {}
    }

    final bool isLender = widget.user.role.toLowerCase().contains('lender');
    final String loanId = widget.user.loanId;
    final String userId = widget.user.userId;

    int? wishlistStatus;
    try {
      if (isLender) {
        wishlistStatus = await BookmarkApiService.toggleLenderBookmark(loanId: loanId);
      } else {
        wishlistStatus = await BookmarkApiService.toggleBorrowerBookmark(loanId: loanId, userId: userId);
      }
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    }

    if (!mounted) return;

    if (wishlistStatus != null) {
      // API call succeeded. Update state based on wishlistStatus from database
      if (wishlistStatus == 1) {
        if (index == -1) {
          bookmarkedJsonList.add(jsonEncode(widget.user.toJson()));
        }
        setState(() {
          _isBookmarked = true;
        });
        showAppSnackBar(context, '${widget.user.name} added to Bookmarks', isError: false);
      } else {
        if (index != -1) {
          bookmarkedJsonList.removeAt(index);
        }
        setState(() {
          _isBookmarked = false;
        });
        showAppSnackBar(context, '${widget.user.name} removed from Bookmarks', isError: false);
      }
    } else {
      // API call failed/offline. Fallback to local toggle
      showAppSnackBar(context, 'Offline: Bookmark updated locally', isError: false);
      if (index != -1) {
        bookmarkedJsonList.removeAt(index);
        setState(() {
          _isBookmarked = false;
        });
      } else {
        bookmarkedJsonList.add(jsonEncode(widget.user.toJson()));
        setState(() {
          _isBookmarked = true;
        });
      }
    }

    await prefs.setStringList('bookmarked_users', bookmarkedJsonList);
    MarketCard.bookmarksNotifier.value++;
    widget.onBookmarkToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black26 : const Color(0x0D000000),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: context.inputBg,
                  image: DecorationImage(
                    image: widget.user.profileImage.startsWith('http')
                        ? NetworkImage(widget.user.profileImage) as ImageProvider
                        : AssetImage(widget.user.profileImage),
                    fit: BoxFit.cover,
                  ),
                ),
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
                            widget.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textColor,
                            ),
                          ),
                        ),
                        if (widget.user.isPopular)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.white,
                                  size: 11.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Popular',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.user.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: context.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Container(
              height: 1,
              color: context.dividerColor,
            ),
          ),

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
                      color: context.subTextColor,
                    ),
                  ),
                  Text(
                    'Tenure',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: context.subTextColor,
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
                    widget.user.requiredAmount,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: context.isDarkMode ? Colors.white : const Color(0xFF003178),
                    ),
                  ),
                  Text(
                    widget.user.tenure,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: widget.onViewDetailsTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004AC6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Details',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 14.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              GestureDetector(
                onTap: _toggleBookmark,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 44.w,
                  height: 44.h,
                  alignment: Alignment.center,
                  child: Icon(
                    _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: const Color(0xFF004AC6),
                    size: 24.w,
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

class DetailsBottomSheet extends StatelessWidget {
  final MarketUser user;
  final double height;

  const DetailsBottomSheet({required this.user, required this.height});

  @override
  Widget build(BuildContext context) {
    String getLoanTypeLabel(String category) {
      final String cat = category.toLowerCase().trim();
      if (cat == '1' || cat == 'home') {
        return 'Home Loan';
      } else if (cat == '2' || cat == 'vehicle') {
        return 'Vehicle Loan';
      } else if (cat == '3' || cat == 'business' || cat == 'bussiness') {
        return 'Business Loan';
      } else if (cat == '4' || cat == 'education') {
        return 'Education Loan';
      } else if (cat == '5' || cat == 'professional') {
        return 'Professional Loan';
      } else if (cat == 'personal') {
        return 'Personal Loan';
      }
      if (category.isEmpty) return 'General Loan';
      return '${category[0].toUpperCase()}${category.substring(1).toLowerCase()} Loan';
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004AC6), Color(0xFF1D64FF)],
                stops: [0.1105, 0.5385],
                begin: Alignment(-0.8, -0.9),
                end: Alignment(0.8, 0.9),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: ClipOval(
                        child: user.profileImage.startsWith('http')
                            ? Image.network(
                                user.profileImage,
                                width: 52.w,
                                height: 52.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 28.w,
                                  );
                                },
                              )
                            : Image.asset(
                                user.profileImage,
                                width: 52.w,
                                height: 52.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 28.w,
                                  );
                                },
                              ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            user.role,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset:  Offset(0, -8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 12.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              user.creditRatingText,
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  "AMOUNT",
                                  value: user.requiredAmount,
                                  valueColor: const Color(0xFF2664EB),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  "INTEREST RATE",
                                  value: user.interestRate,
                                  valueColor: const Color(0xFF2664EB),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  "LOAN TYPE",
                                  value: getLoanTypeLabel(user.category),
                                  valueColor: const Color(0xFF861E9D),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildMetricCard(
                                  context,
                                  "LOCATION",
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: const Color(0xFF004AC6),
                                          size: 18.w,
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Text(
                                            user.location,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: context.textColor,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      SizedBox(
                        height: 48.h,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () async {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: user.phone,
                            );
                            try {
                              if (await canLaunchUrl(launchUri)) {
                                await launchUrl(launchUri);
                              } else {
                                await launchUrl(launchUri);
                              }
                            } catch (e) {
                              debugPrint('Error launching dialer: $e');
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone_in_talk_rounded,
                                color: Colors.white,
                                size: 18.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Call Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Document Verification',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: context.textColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Column(
                              children: user.verifiedDocs.map((doc) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: const Color(0xFF004AC6),
                                        size: 18.w,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        doc,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: context.subTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, {String? value, Color? valueColor, Widget? child}) {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: context.subTextColor,
            ),
          ),
          SizedBox(height: 4.h),
          if (child != null)
            child
          else
            Text(
              value ?? '',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: context.isDarkMode ? Colors.white : (valueColor ?? context.textColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterOptionsBottomSheet extends StatefulWidget {
  final int? initialMinAmount;
  final int? initialMaxAmount;
  final String? initialInterest;
  final List<String> initialLoanTypes;
  final String? initialTenure;
  final String? initialStateVal;
  final String? initialStateLabel;
  final String? initialDistrictVal;
  final String? initialDistrictLabel;
  final String? initialDateRange;
  
  final Function(
    int? minAmt,
    int? maxAmt,
    String? interest,
    List<String> types,
    String? tenure,
    String? stateVal,
    String? stateLabel,
    String? distVal,
    String? distLabel,
    String? dateRange,
  ) onApply;

  const _FilterOptionsBottomSheet({
    required this.initialMinAmount,
    required this.initialMaxAmount,
    required this.initialInterest,
    required this.initialLoanTypes,
    required this.initialTenure,
    required this.initialStateVal,
    required this.initialStateLabel,
    required this.initialDistrictVal,
    required this.initialDistrictLabel,
    required this.initialDateRange,
    required this.onApply,
  });

  @override
  State<_FilterOptionsBottomSheet> createState() => _FilterOptionsBottomSheetState();
}

class _FilterOptionsBottomSheetState extends State<_FilterOptionsBottomSheet> {
  int _activeMenuIndex = 0;
  final List<String> _menuItems = [
    'Amount',
    'Interest',
    'Loan type',
    'Tenure',
    'Location',
    'Date Range',
  ];

  late double _minAmount;
  late double _maxAmount;
  
  String? _selectedInterest;
  late List<String> _selectedLoanTypes;
  String? _selectedTenure;
  String? _selectedStateVal;
  String? _selectedStateLabel;
  String? _selectedDistrictVal;
  String? _selectedDistrictLabel;
  String? _selectedDateRange;

  final TextEditingController _loanTypeSearchController = TextEditingController();
  String _loanTypeSearchQuery = '';

  late final TextEditingController _minAmountInputController;
  late final TextEditingController _maxAmountInputController;

  List<Map<String, dynamic>> _statesList = [];
  List<Map<String, dynamic>> _districtsList = [];
  bool _isLoadingStates = false;
  bool _isLoadingDistricts = false;

  final List<String> _allLoanTypes = ['Home', 'Bussiness', 'Personal', 'vehicle', 'Education'];

  @override
  void initState() {
    super.initState();
    _minAmount = widget.initialMinAmount?.toDouble() ?? 0.0;
    _maxAmount = widget.initialMaxAmount?.toDouble() ?? 10000000.0;
    if (_minAmount < 0.0) _minAmount = 0.0;
    if (_minAmount > 10000000.0) _minAmount = 10000000.0;
    if (_maxAmount < 0.0) _maxAmount = 0.0;
    if (_maxAmount > 10000000.0) _maxAmount = 10000000.0;
    if (_minAmount > _maxAmount) {
      final temp = _minAmount;
      _minAmount = _maxAmount;
      _maxAmount = temp;
    }

    _minAmountInputController = TextEditingController(text: _minAmount.round().toString());
    _maxAmountInputController = TextEditingController(text: _maxAmount.round().toString());

    _selectedInterest = widget.initialInterest;
    _selectedLoanTypes = List.from(widget.initialLoanTypes);
    _selectedTenure = widget.initialTenure;
    _selectedStateVal = widget.initialStateVal;
    _selectedStateLabel = widget.initialStateLabel;
    _selectedDistrictVal = widget.initialDistrictVal;
    _selectedDistrictLabel = widget.initialDistrictLabel;
    _selectedDateRange = widget.initialDateRange;

    _loadStates();
    if (_selectedStateVal != null) {
      _loadDistricts(_selectedStateVal!);
    }
  }

  @override
  void dispose() {
    _loanTypeSearchController.dispose();
    _minAmountInputController.dispose();
    _maxAmountInputController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    setState(() {
      _isLoadingStates = true;
    });
    final states = await LocationApiService.fetchStates();
    setState(() {
      _statesList = states;
      _isLoadingStates = false;
    });
  }

  Future<void> _loadDistricts(String stateVal) async {
    setState(() {
      _isLoadingDistricts = true;
      _districtsList = [];
    });
    try {
      final districts = await LocationApiService.fetchDistricts(stateVal);
      final bool isTamilNadu = stateVal == '33' || _selectedStateLabel?.toLowerCase().contains('tamil nadu') == true;

      if (districts.isEmpty || (!isTamilNadu && districts.any((d) => d['label'] == 'Salem'))) {
        setState(() {
          _districtsList = _getFallbackDistricts(stateVal);
          _isLoadingDistricts = false;
        });
      } else {
        setState(() {
          _districtsList = districts;
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      setState(() {
        _districtsList = _getFallbackDistricts(stateVal);
        _isLoadingDistricts = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackDistricts(String stateNameOrVal) {
    final lower = stateNameOrVal.toLowerCase();
    List<String> dists = [];
    if (lower.contains('goa') || stateNameOrVal == '30') {
      dists = ['North Goa', 'South Goa'];
    } else if (lower.contains('karnataka') || stateNameOrVal == '29') {
      dists = ['Bengaluru', 'Mysore', 'Hubli-Dharwad', 'Mangalore', 'Belgaum', 'Udupi', 'Dharwad', 'Gulbarga'];
    } else if (lower.contains('kerala') || stateNameOrVal == '32') {
      dists = ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Wayanad', 'Ernakulam', 'Kollam', 'Palakkad'];
    } else if (lower.contains('tamil nadu') || stateNameOrVal == '33') {
      dists = ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli', 'Tirunelveli', 'Erode', 'Vellore', 'Namakkal', 'Thanjavur'];
    } else if (lower.contains('maharashtra') || stateNameOrVal == '27') {
      dists = ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik', 'Aurangabad', 'Solapur', 'Amravati'];
    } else if (lower.contains('delhi') || stateNameOrVal == '7') {
      dists = ['New Delhi', 'North Delhi', 'South Delhi', 'East Delhi', 'West Delhi'];
    } else if (lower.contains('andhra') || stateNameOrVal == '37') {
      dists = ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Anantapur', 'Nellore', 'Kurnool', 'Chittoor', 'Kadapa'];
    } else if (lower.contains('telangana') || stateNameOrVal == '36') {
      dists = ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam', 'Ramagundam'];
    } else if (lower.contains('rajasthan') || stateNameOrVal == '8') {
      dists = ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer', 'Bikaner', 'Alwar', 'Bhilwara'];
    } else if (lower.contains('uttar pradesh') || lower.contains('u.p.') || stateNameOrVal == '9') {
      dists = ['Lucknow', 'Kanpur', 'Noida', 'Ghaziabad', 'Agra', 'Varanasi', 'Meerut', 'Allahabad', 'Bareilly'];
    } else if (lower.contains('gujarat') || stateNameOrVal == '24') {
      dists = ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar', 'Bhavnagar', 'Jamnagar'];
    } else if (lower.contains('west bengal') || stateNameOrVal == '19') {
      dists = ['Kolkata', 'Howrah', 'Darjeeling', 'Durgapur', 'Asansol', 'Siliguri', 'Kharagpur'];
    } else if (lower.contains('punjab') || stateNameOrVal == '3') {
      dists = ['Amritsar', 'Ludhiana', 'Jalandhar', 'Patiala', 'Bathinda', 'Mohali'];
    } else if (lower.contains('haryana') || stateNameOrVal == '6') {
      dists = ['Gurgaon', 'Faridabad', 'Panipat', 'Ambala', 'Rohtak', 'Hisar'];
    } else if (lower.contains('bihar') || stateNameOrVal == '10') {
      dists = ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Darbhanga', 'Purnia'];
    } else if (lower.contains('jammu') || stateNameOrVal == '1') {
      dists = ['Srinagar', 'Jammu', 'Anantnag', 'Baramulla', 'Kathua', 'Udhampur'];
    } else if (lower.contains('uttarakhand') || stateNameOrVal == '5') {
      dists = ['Dehradun', 'Haridwar', 'Haldwani', 'Roorkee', 'Rishikesh'];
    } else if (lower.contains('himachal') || stateNameOrVal == '2') {
      dists = ['Shimla', 'Dharamshala', 'Manali', 'Kullu', 'Solan', 'Mandi'];
    } else if (lower.contains('jharkhand') || stateNameOrVal == '20') {
      dists = ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar'];
    } else if (lower.contains('odisha') || stateNameOrVal == '21') {
      dists = ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri', 'Sambalpur', 'Balasore'];
    } else if (lower.contains('chhattisgarh') || stateNameOrVal == '22') {
      dists = ['Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg'];
    } else if (lower.contains('madhya pradesh') || stateNameOrVal == '23') {
      dists = ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain', 'Sagar'];
    } else {
      dists = ['District 1', 'District 2', 'District 3'];
    }

    return dists.map((d) => {
      'value': d.toLowerCase().replaceAll(' ', '_'),
      'label': d,
    }).toList();
  }

  String _formatRupees(int value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)} Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)} Lakh';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)} K';
    }
    return '₹$value';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomSheetHeight = mediaQuery.size.height * 0.58;

    return Padding(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom > 0
            ? (mediaQuery.viewInsets.bottom - 110.h).clamp(0.0, double.infinity)
            : 0,
      ),
      child: Container(
        height: bottomSheetHeight,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter options',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: context.subTextColor,
                      size: 16.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.dividerColor),

          Expanded(
            child: Row(
              children: [
                Container(
                  width: 125.w,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: context.borderColor, width: 1),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final isActive = index == _activeMenuIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _activeMenuIndex = index),
                        child: Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: isActive ? context.inputBg : context.cardBg,
                            border: isActive
                                ? const Border(
                                    left: BorderSide(color: Color(0xFF004AC6), width: 3.5),
                                  )
                                : null,
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            _menuItems[index],
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? context.textColor : context.subTextColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: _buildRightPanelContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: context.dividerColor),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear filters',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004AC6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Update',
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
        ],
      ),
    ),
    );
  }

  Widget _buildRightPanelContent() {
    switch (_activeMenuIndex) {
      case 0:
        // Premium Groww/CRED-like Amount Filter Screen
        final List<Map<String, dynamic>> presets = [
          {'label': 'Under 1L', 'min': 0, 'max': 100000},
          {'label': '1L - 5L', 'min': 100000, 'max': 500000},
          {'label': '5L - 15L', 'min': 500000, 'max': 1500000},
          {'label': '15L - 50L', 'min': 1500000, 'max': 5000000},
          {'label': '50L+', 'min': 5000000, 'max': 10000000},
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'Select Amount Range',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
            ),
            SizedBox(height: 12.h),

            // Horizontal Presets list
            SizedBox(
              height: 38.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final bool isSelected = _minAmount.round() == preset['min'] && _maxAmount.round() == preset['max'];
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(
                        preset['label'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : context.textColor,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF004AC6),
                      backgroundColor: context.isDarkMode ? const Color(0xFF1E2B4A) : const Color(0xFFF1F5F9),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : context.borderColor,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _minAmount = (preset['min'] as int).toDouble();
                            _maxAmount = (preset['max'] as int).toDouble();
                            _minAmountInputController.text = preset['min'].toString();
                            _maxAmountInputController.text = preset['max'].toString();
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),

            // Minimum & Maximum Inputs
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: context.isDarkMode ? const Color(0xFF151525) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.borderColor,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Min Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: context.subTextColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '₹',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF004AC6),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: TextField(
                                controller: _minAmountInputController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (text) {
                                  final val = double.tryParse(text) ?? 0.0;
                                  setState(() {
                                    _minAmount = val.clamp(0.0, _maxAmount);
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: context.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: context.isDarkMode ? const Color(0xFF151525) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.borderColor,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: context.subTextColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '₹',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF004AC6),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: TextField(
                                controller: _maxAmountInputController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (text) {
                                  final val = double.tryParse(text) ?? 0.0;
                                  setState(() {
                                    _maxAmount = val.clamp(_minAmount, 10000000.0);
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: context.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Premium Custom SliderTheme RangeSlider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF004AC6),
                inactiveTrackColor: context.isDarkMode ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0),
                trackHeight: 4.h,
                thumbColor: Colors.white,
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 9.r,
                  pressedElevation: 6,
                ),
                rangeThumbShape: RoundRangeSliderThumbShape(
                  enabledThumbRadius: 9.r,
                  pressedElevation: 6,
                ),
                overlayColor: const Color(0xFF004AC6).withValues(alpha: 0.12),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 18.r),
              ),
              child: RangeSlider(
                values: RangeValues(_minAmount, _maxAmount),
                min: 0.0,
                max: 10000000.0,
                divisions: 1000,
                onChanged: (RangeValues vals) {
                  setState(() {
                    _minAmount = vals.start;
                    _maxAmount = vals.end;
                    _minAmountInputController.text = vals.start.round().toString();
                    _maxAmountInputController.text = vals.end.round().toString();
                  });
                },
              ),
            ),
            SizedBox(height: 6.h),

            // Slider labels and dynamic range display
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹0',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: context.subTextColor,
                        ),
                      ),
                      Text(
                        '₹1 Cr',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: context.subTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004AC6).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Selected: ',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: context.textColor,
                            ),
                          ),
                          TextSpan(
                            text: '${_formatRupees(_minAmount.round())} - ${_formatRupees(_maxAmount.round())}',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF004AC6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        final List<String> interestOptions = [
          '5%-10 %',
          '10%-25 %',
          '25%-50 %',
          '50%-75 %',
          '75%',
          'Above 1 crore',
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your Interest range',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 12.h),
            ...interestOptions.map((opt) {
              final isSel = _selectedInterest == opt;
              return RadioListTile<String>(
                value: opt,
                groupValue: _selectedInterest,
                onChanged: (val) {
                  setState(() => _selectedInterest = val);
                },
                activeColor: const Color(0xFF004AC6),
                title: Text(
                  opt,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                    color: isSel ? context.textColor : context.subTextColor,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
          ],
        );
      case 2:
        final List<String> filteredTypes = _allLoanTypes
            .where((t) => t.toLowerCase().contains(_loanTypeSearchQuery.toLowerCase()))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search & select Loan Type',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: context.borderColor),
                borderRadius: BorderRadius.circular(8.r),
                color: context.inputBg,
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: const Color(0xFF94A3B8), size: 18.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _loanTypeSearchController,
                      onChanged: (val) => setState(() => _loanTypeSearchQuery = val),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                        isDense: true,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: context.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            ...filteredTypes.map((type) {
              final isChecked = _selectedLoanTypes.contains(type);
              return CheckboxListTile(
                value: isChecked,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedLoanTypes.add(type);
                    } else {
                      _selectedLoanTypes.remove(type);
                    }
                  });
                },
                activeColor: const Color(0xFF004AC6),
                title: Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: context.textColor,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
            SizedBox(height: 16.h),
            if (_selectedLoanTypes.isNotEmpty)
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _selectedLoanTypes.map((type) {
                  return Chip(
                    label: Text(
                      type,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF004AC6),
                      ),
                    ),
                    backgroundColor: const Color(0xFFEFF6FF),
                    deleteIcon: Icon(Icons.close, size: 12.w, color: const Color(0xFF004AC6)),
                    onDeleted: () {
                      setState(() {
                        _selectedLoanTypes.remove(type);
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your Tenure range',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 12.h),
            RadioListTile<String>(
              value: 'Short Term',
              groupValue: _selectedTenure,
              onChanged: (val) => setState(() => _selectedTenure = val),
              activeColor: const Color(0xFF004AC6),
              title: Text('Short Term', style: GoogleFonts.poppins(fontSize: 13.sp, color: context.textColor)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            RadioListTile<String>(
              value: 'Long Term',
              groupValue: _selectedTenure,
              onChanged: (val) => setState(() => _selectedTenure = val),
              activeColor: const Color(0xFF004AC6),
              title: Text('Long Term', style: GoogleFonts.poppins(fontSize: 13.sp, color: context.textColor)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Location',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'State',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: context.borderColor),
                borderRadius: BorderRadius.circular(8.r),
                color: context.inputBg,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.center,
              child: _isLoadingStates
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Loading...', style: GoogleFonts.poppins(fontSize: 13.sp, color: context.subTextColor)),
                        SizedBox(
                          width: 14.w,
                          height: 14.h,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF004AC6)),
                        ),
                      ],
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStateVal,
                        hint: Text(
                          'Select State',
                          style: GoogleFonts.poppins(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                        ),
                        isExpanded: true,
                        dropdownColor: context.cardBg,
                        icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF64748B), size: 20.w),
                        items: _statesList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['value']?.toString(),
                            child: Text(item['label']?.toString() ?? '', style: GoogleFonts.poppins(fontSize: 13.sp, color: context.textColor)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final chosen = _statesList.firstWhere((s) => s['value']?.toString() == val);
                            setState(() {
                              _selectedStateVal = chosen['value'];
                              _selectedStateLabel = chosen['label'];
                              _selectedDistrictVal = null;
                              _selectedDistrictLabel = null;
                            });
                            _loadDistricts(chosen['value']);
                          }
                        },
                      ),
                    ),
            ),
            SizedBox(height: 16.h),
            Text(
              'District',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: context.borderColor),
                borderRadius: BorderRadius.circular(8.r),
                color: context.inputBg,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.center,
              child: _isLoadingDistricts
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Loading...', style: GoogleFonts.poppins(fontSize: 13.sp, color: context.subTextColor)),
                        SizedBox(
                          width: 14.w,
                          height: 14.h,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF004AC6)),
                        ),
                      ],
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDistrictVal,
                        hint: Text(
                          'Select District',
                          style: GoogleFonts.poppins(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                        ),
                        isExpanded: true,
                        dropdownColor: context.cardBg,
                        icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF64748B), size: 20.w),
                        items: _districtsList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['value']?.toString(),
                            child: Text(item['label']?.toString() ?? '', style: GoogleFonts.poppins(fontSize: 13.sp, color: context.textColor)),
                          );
                        }).toList(),
                        onChanged: _selectedStateVal == null
                            ? null
                            : (val) {
                                if (val != null) {
                                  final chosen = _districtsList.firstWhere((d) => d['value']?.toString() == val);
                                  setState(() {
                                    _selectedDistrictVal = chosen['value'];
                                    _selectedDistrictLabel = chosen['label'];
                                  });
                                }
                              },
                      ),
                    ),
            ),
          ],
        );
      case 5:
        final List<String> dateRangeOptions = ['0-10', '10-20', '20-31'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your Date range',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: context.subTextColor,
              ),
            ),
            SizedBox(height: 12.h),
            ...dateRangeOptions.map((opt) {
              final isSel = _selectedDateRange == opt;
              return RadioListTile<String>(
                value: opt,
                groupValue: _selectedDateRange,
                onChanged: (val) {
                  setState(() => _selectedDateRange = val);
                },
                activeColor: const Color(0xFF004AC6),
                title: Text(
                  opt,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                    color: isSel ? const Color(0xFF0F172A) : const Color(0xFF475569),
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  void _clearFilters() {
    setState(() {
      _minAmount = 0.0;
      _maxAmount = 10000000.0;
      _minAmountInputController.text = '0';
      _maxAmountInputController.text = '10000000';
      _selectedInterest = null;
      _selectedLoanTypes = [];
      _selectedTenure = null;
      _selectedStateVal = null;
      _selectedStateLabel = null;
      _selectedDistrictVal = null;
      _selectedDistrictLabel = null;
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    widget.onApply(
      _minAmount.round(),
      _maxAmount.round(),
      _selectedInterest,
      _selectedLoanTypes,
      _selectedTenure,
      _selectedStateVal,
      _selectedStateLabel,
      _selectedDistrictVal,
      _selectedDistrictLabel,
      _selectedDateRange,
    );
    Navigator.of(context).pop();
  }
}
