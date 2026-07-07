import 'dart:async';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tm/fast_page_route.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'my_ads.dart';
import 'notification.dart';
import 'ads_screen.dart';
import '../profile/profile.dart';
import '../profile/subscription_plan.dart';
import '../api_services/profile_api_service.dart';
import '../api_services/marketplace_api_service.dart';
import 'package:flutter/services.dart';
import 'package:tm/theme_manager.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onRequestTap;
  final VoidCallback? onBookmarksTap;
  final Function(String name, String role)? onMarketCardTap;

  const HomeScreen({
    super.key,
    this.onProfileTap,
    this.onRequestTap,
    this.onBookmarksTap,
    this.onMarketCardTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Ad banner state
  late final PageController _pageController;
  int _currentAdIndex = 0;
  Timer? _adTimer;
  List<String> _adImages = [];
  bool _isLoadingAds = true;
  int _bookmarkCount = 0;
  List<Map<String, dynamic>> _topAds = [];
  bool _isLoadingTopAds = true;
  int _myAdsCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadCachedHomeData();
    _fetchAds();
    _startAdTimer();
    _fetchBookmarkCount();
    _loadProfile();
    _loadTopAds();
  }

  Future<void> _loadCachedHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedAdImages = prefs.getStringList('cached_ad_images') ?? [];
      final cachedTopAdsStr = prefs.getString('cached_top_ads') ?? '';
      final cachedMyAdsCount = prefs.getInt('cached_my_ads_count') ?? 0;

      List<Map<String, dynamic>> cachedTopAds = [];
      if (cachedTopAdsStr.isNotEmpty) {
        final List decoded = jsonDecode(cachedTopAdsStr);
        cachedTopAds = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      if (mounted) {
        setState(() {
          if (cachedAdImages.isNotEmpty) {
            _adImages = cachedAdImages;
            _isLoadingAds = false;
          }
          if (cachedTopAds.isNotEmpty) {
            _topAds = cachedTopAds;
            _isLoadingTopAds = false;
          }
          _myAdsCount = cachedMyAdsCount;
        });
      }
    } catch (e) {
      debugPrint('Error loading cached home data: $e');
    }
  }

  Future<void> _fetchBookmarkCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> bookmarkedJsonList = prefs.getStringList('bookmarked_users') ?? [];
      final int count = bookmarkedJsonList.length;
      if (count != _bookmarkCount && mounted) {
        setState(() {
          _bookmarkCount = count;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProfile() async {
    try {
      await ProfileApiService.loadFromPrefs();
      await ProfileApiService.fetchProfile();
    } catch (e) {
      debugPrint('Error loading profile in HomeScreen: $e');
    }
  }

  Future<void> _loadTopAds() async {
    try {
      final results = await Future.wait([
        MarketplaceApiService.fetchLenders(),
        MarketplaceApiService.fetchBorrowers(),
        MarketplaceApiService.fetchProfiles(),
      ]);

      final lendersData = results[0] as List<dynamic>?;
      final borrowersData = results[1] as List<dynamic>?;
      final profilesData = results[2] as List<dynamic>?;

      final Map<String, Map<String, dynamic>> profilesMap = {};
      if (profilesData != null) {
        for (var prof in profilesData) {
          final String idStr = prof['id']?.toString() ?? '';
          final String nameStr = prof['ledger_Name']?.toString().toLowerCase() ?? '';
          if (idStr.isNotEmpty) profilesMap[idStr] = prof;
          if (nameStr.isNotEmpty) profilesMap[nameStr] = prof;
        }
      }

      final List<Map<String, dynamic>> tempAds = [];

      // Add lenders
      if (lendersData != null) {
        for (var item in lendersData.take(3)) {
          final ledgerName = item['ledger_name']?.toString() ?? 'Unknown';
          final uidStr = item['uid']?.toString() ?? '';
          final profile = profilesMap[uidStr] ?? profilesMap[ledgerName.toLowerCase()];

          final String name = profile?['ledger_Name']?.toString() ?? ledgerName;
          final dynamic rawAmt = item['loan_amt'];
          final dynamic rawTenure = item['loan_tenure'];
          final String amount = rawAmt != null ? '₹$rawAmt' : '₹0';
          final String tenure = rawTenure != null ? '$rawTenure Months' : '12 Months';
          final String rawPhoto = profile?['photo']?.toString() ?? profile?['Image']?.toString() ?? '';
          final String profileImage = rawPhoto.startsWith('http') ? rawPhoto : 'assets/home/mohan_profile.png';

          tempAds.add({
            'name': name,
            'role': 'Lender',
            'amount': amount,
            'tenure': tenure,
            'profileImage': profileImage,
          });
        }
      }

      // Add borrowers
      if (borrowersData != null) {
        for (var item in borrowersData.take(3)) {
          final ledgerName = item['ledger_name']?.toString() ?? 'Unknown';
          final uidStr = item['uid']?.toString() ?? '';
          final profile = profilesMap[uidStr] ?? profilesMap[ledgerName.toLowerCase()];

          final String name = profile?['ledger_Name']?.toString() ?? ledgerName;
          final dynamic rawAmt = item['loan_amt'];
          final dynamic rawTenure = item['loan_tenure'];
          final String amount = rawAmt != null ? '₹$rawAmt' : '₹0';
          final String tenure = rawTenure != null ? '$rawTenure Months' : '12 Months';
          final String rawPhoto = profile?['photo']?.toString() ?? profile?['Image']?.toString() ?? '';
          final String profileImage = rawPhoto.startsWith('http') ? rawPhoto : 'assets/home/mohan_profile.png';

          tempAds.add({
            'name': name,
            'role': 'Borrower',
            'amount': amount,
            'tenure': tenure,
            'profileImage': profileImage,
          });
        }
      }

      if (tempAds.isEmpty) {
        tempAds.addAll([
          {
            'name': 'Sowmiya',
            'role': 'Lender',
            'amount': '₹50,00,000',
            'tenure': '12-48M',
            'profileImage': 'assets/home/priya_profile.png',
          },
          {
            'name': 'Arjun Kumar',
            'role': 'Borrower',
            'amount': '₹30,00,000',
            'tenure': '24-60M',
            'profileImage': 'assets/home/arjun_profile.png',
          },
          {
            'name': 'Priya Nair',
            'role': 'Lender',
            'amount': '₹20,00,000',
            'tenure': '12-36M',
            'profileImage': 'assets/home/priya_profile.png',
          },
        ]);
      }

      final prefs = await SharedPreferences.getInstance();
      final String currentUserId = prefs.getString('user_id') ?? '';
      int adsCount = 0;
      if (lendersData != null) {
        adsCount += lendersData.where((l) => l['ledger_name']?.toString() == currentUserId).length;
      }
      if (borrowersData != null) {
        adsCount += borrowersData.where((b) => b['ledger_name']?.toString() == currentUserId).length;
      }

      if (mounted) {
        setState(() {
          _topAds = tempAds;
          _isLoadingTopAds = false;
          _myAdsCount = adsCount;
        });
      }
      await prefs.setString('cached_top_ads', jsonEncode(tempAds));
      await prefs.setInt('cached_my_ads_count', adsCount);
    } catch (e) {
      debugPrint('Error loading top ads in HomeScreen: $e');
      if (mounted) {
        setState(() {
          _isLoadingTopAds = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '31';
      final String lt = prefs.getString('lt') ?? '11';
      final String ln = prefs.getString('ln') ?? '11';

      final response = await http.post(
        Uri.parse('https://trueloan.ai.in/ai/api/m_api/'),
        body: {
          'cid': '21472147',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'type': '1106',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['error'] == false && responseData['data'] != null) {
          final data = responseData['data'];
          final List<String> urls = [];
          if (data is List) {
            for (var item in data) {
              if (item is Map && item['img'] != null) {
                urls.add(item['img'].toString());
              }
            }
          }
          await prefs.setStringList('cached_ad_images', urls);
          if (mounted) {
            setState(() {
              _adImages = urls;
              _isLoadingAds = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _fetchAds: $e');
    }
    if (mounted) {
      setState(() {
        _isLoadingAds = false;
      });
    }
  }

  void _startAdTimer() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentAdIndex + 1;
        int maxPages = _isLoadingAds
            ? 4
            : (_adImages.isEmpty ? 4 : _adImages.length);
        if (nextPage >= maxPages) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _fetchBookmarkCount();
    final sw = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.themedStatusBar,
      child: Scaffold(
      backgroundColor: context.pageBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Blue Header Section ───────────────────────────────────
              _buildHeader(sw),

              // ── Slide Ad Banner ────────────────────────────────────────
              _buildHeroAdBanner(),
              const SizedBox(height: 4),
              _buildAdIndicators(),

              SizedBox(height: 16.h),

              // ── Stats Row ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            FastPageRoute(
                              child: const MyAdsScreen(),
                            ),
                          );
                        },
                        child: _buildStatCard(
                          label: 'My Ads',
                          value: _myAdsCount.toString(),
                          imagePath: 'assets/home/request.png',
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onBookmarksTap != null) {
                            widget.onBookmarksTap!();
                          } else {
                            Navigator.of(context).push(
                              FastPageRoute(
                                child: const AdsScreen(),
                              ),
                            );
                          }
                        },
                        child: _buildStatCard(
                          label: 'Bookmarks',
                          value: _bookmarkCount.toString(),
                          imagePath: 'assets/home/total_loan.png',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),



              // ── Top Matches ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Ads',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: context.textColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ── Horizontal Match Cards ────────────────────────────────
              SizedBox(
                height: 180.h,
                child: _isLoadingTopAds
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF004AC6),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: 20.w, right: 20.w),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _topAds.length,
                        itemBuilder: (context, index) {
                          final ad = _topAds[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: GestureDetector(
                              onTap: () {
                                if (widget.onMarketCardTap != null) {
                                  widget.onMarketCardTap!(
                                    ad['name'] ?? '',
                                    ad['role'] ?? '',
                                  );
                                }
                              },
                              child: _MatchCard(
                                name: ad['name'] ?? 'Sowmiya',
                                role: ad['role'] ?? 'Lender',
                                amount: ad['amount'] ?? '₹0',
                                tenure: ad['tenure'] ?? '12 Months',
                                profileImage: ad['profileImage'] ?? 'assets/home/mohan_profile.png',
                              ),
                            ),
                          );
                        },
                      ),
              ),

              SizedBox(height: 24.h),

              // ── Premium Banner ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildPremiumBanner(),
              ),

              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(double sw) {
    return Container(
      color: const Color(0xFF004AC6),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: avatar + name + bell ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular avatar with white border
              GestureDetector(
                onTap: () {
                  if (widget.onProfileTap != null) {
                    widget.onProfileTap!();
                  } else {
                    Navigator.of(context).push(
                      FastPageRoute(
                        child: const ProfileScreen(showBackButton: true),
                      ),
                    );
                  }
                },
                child: ValueListenableBuilder<String?>(
                  valueListenable: ProfileApiService.profileImageNotifier,
                  builder: (context, profileImg, _) {
                    return Container(
                      width: 52.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5.w),
                      ),
                      child: ClipOval(
                        child: (profileImg != null && profileImg.startsWith('http'))
                            ? Image.network(
                                profileImg,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/home/mohan_profile.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/home/mohan_profile.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  }
                ),
              ),
              SizedBox(width: 14.w),
              // Welcome text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: const Color(
                        0xCCFFFFFF,
                      ), // #FFFFFFCC → alpha first in Flutter
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: ProfileApiService.nameNotifier,
                    builder: (context, name, _) {
                      return Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      );
                    }
                  ),
                ],
              ),
              Spacer(),
              // Bell icon — blur + #FFFFFF33 border
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    FastPageRoute(child: const NotificationScreen()),
                  );
                },
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B82BF).withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0x33FFFFFF), // #FFFFFF33
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  // ── Stat Card ─────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String label,
    required String value,
    required String imagePath,
  }) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 0.92),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black26 : const Color(0x0D000000), // #0000000D
            offset: const Offset(0, 3.67),
            blurRadius: 11.01,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Column containing Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: context.subTextColor,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  value,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: context.isDarkMode ? Colors.white : const Color(0xFF003178),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Right side Image (straight to count/value!)
          Image.asset(
            imagePath,
            width: 40.w,
            height: 40.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  // ── Hero Ad Banner Widget ──────────────────────────────────────────────────
  Widget _buildHeroAdBanner() {
    final int itemCount = _isLoadingAds
        ? 4
        : (_adImages.isEmpty ? 4 : _adImages.length);
    return SizedBox(
      height: 185,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Full-width blue background block at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF004AC6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
              ),
            ),
          ),
          // Ad banner card
          Positioned(
            top: 12,
            left: 20,
            right: 20,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentAdIndex = index;
                    });
                    _startAdTimer();
                  },
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (_isLoadingAds) {
                      return Container(
                        color: const Color(0xFF1E2E6B),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF31378D)),
                          ),
                        ),
                      );
                    }
                    if (_adImages.isEmpty) {
                      return Image.asset(
                        'assets/new_home/trueloan_ad${index + 1}.png',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              alignment: Alignment.center,
                              child: Text('Ad ${index + 1}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                      );
                    }
                    return Image.network(
                      _adImages[index],
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/new_home/trueloan_ad${(index % 4) + 1}.png',
                          fit: BoxFit.fill,
                          errorBuilder: (context, err, st) =>
                              Container(
                                color: Colors.blueAccent.withValues(alpha: 0.1),
                                alignment: Alignment.center,
                                child: Text('Ad ${index + 1}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFF1E2E6B),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF31378D),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ad Indicators Widget ──────────────────────────────────────────────────
  Widget _buildAdIndicators() {
    final int maxPages = _isLoadingAds
        ? 4
        : (_adImages.isEmpty ? 4 : _adImages.length);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(maxPages, (index) {
        final isCurrent = _currentAdIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 24 : 12,
          height: isCurrent ? 5 : 2.5,
          decoration: BoxDecoration(
            color: isCurrent
                ? const Color(0xFF31378D)
                : const Color(0xFFADADAD),
            borderRadius: BorderRadius.circular(isCurrent ? 2.5 : 1.5),
          ),
        );
      }),
    );
  }

  // ── Premium Banner ────────────────────────────────────────────────────────
  Widget _buildPremiumBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF005BDE), Color(0xFF003178)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 22.w),
          SizedBox(height: 10.h),
          Text(
            'Unlock specialized rates\nbased on your industry\ntrends.',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                FastPageRoute(
                  child: const SubscriptionPlanScreen(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.77.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      foreground: Paint()
                        ..shader =
                            LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF005BDE), Color(0xFF003178)],
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF005BDE), Color(0xFF003178)],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Icon(
                      Icons.diamond_outlined,
                      color: Colors.white, // Color is masked by ShaderMask
                      size: 24.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Match Card ───────────────────────────────────────────────────────────────
class _MatchCard extends StatelessWidget {
  final String name;
  final String role;
  final String amount;
  final String tenure;
  final String profileImage;

  const _MatchCard({
    required this.name,
    required this.role,
    required this.amount,
    required this.tenure,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = profileImage.startsWith('http') || profileImage.startsWith('https');
    String resolvedImage = 'assets/home/mohan_profile.png';
    if (profileImage.isNotEmpty && !isNetwork) {
      resolvedImage = profileImage;
    } else {
      if (name == 'Sowmiya') {
        resolvedImage = 'assets/home/priya_profile.png';
      } else if (name == 'Arjun Kumar') {
        resolvedImage = 'assets/home/arjun_profile.png';
      }
    }

    return Container(
      width: 290.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black26 : const Color(0x0D000000), // #0000000D
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header Row: Avatar + Name/Role
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: isNetwork
                    ? Image.network(
                        profileImage,
                        width: 46.w,
                        height: 46.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 46.w,
                          height: 46.w,
                          color: context.inputBg,
                          child: Icon(
                            Icons.person,
                            color: context.subTextColor,
                            size: 24.w,
                          ),
                        ),
                      )
                    : Image.asset(
                        resolvedImage,
                        width: 46.w,
                        height: 46.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 46.w,
                          height: 46.w,
                          color: context.inputBg,
                          child: Icon(
                            Icons.person,
                            color: context.subTextColor,
                            size: 24.w,
                          ),
                        ),
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
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      role,
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

          // Divider Line
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Container(
              height: 1,
              color: context.dividerColor,
            ),
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
                    amount,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: context.isDarkMode ? Colors.white : const Color(0xFF003178),
                    ),
                  ),
                  Text(
                    tenure,
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
        ],
      ),
    );
  }
}
