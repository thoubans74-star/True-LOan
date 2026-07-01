import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tm/fast_page_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/profile_api_service.dart';
import 'package:tm/theme_manager.dart';
import 'package:flutter/services.dart';
import 'help_center.dart';
import 'kyc_verification.dart';
import 'terms_of_service.dart';
import 'personal_info.dart';
import 'subscription_plan.dart';
import '../login/login_screen.dart';
import '../home/my_ads.dart';
import '../api_services/marketplace_api_service.dart';
import 'package:tm/api_services/kyc_pending_verify_api_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onBookmarksTap;

  const ProfileScreen({
    super.key,
    this.showBackButton = true,
    this.onBookmarksTap,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _isDarkMode = false;
  int _bookmarkCount = 0;
  int _myAdsCount = 0;
  String _kycStatus = 'Unverified';

  @override
  void initState() {
    super.initState();
    _isDarkMode = ThemeManager.isDark;
    _loadCachedProfileData();
    _loadProfile();
  }

  Future<void> _loadCachedProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('bookmarked_users') ?? [];
      final cachedMyAdsCount = prefs.getInt('cached_my_ads_count') ?? 0;
      final cachedKycStatus = prefs.getString('cached_kyc_status') ?? 'Unverified';

      if (mounted) {
        setState(() {
          _bookmarkCount = bookmarks.length;
          _myAdsCount = cachedMyAdsCount;
          _kycStatus = cachedKycStatus;
        });
      }
    } catch (e) {
      debugPrint('Error loading cached profile data: $e');
    }
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('bookmarked_users') ?? [];
      final String currentUserId = prefs.getString('user_id') ?? '';
      
      // Load initial profile data from cache instantly
      await ProfileApiService.loadFromPrefs();
      if (mounted) {
        setState(() {
          _bookmarkCount = bookmarks.length;
        });
      }

      // Run all network calls in parallel
      final results = await Future.wait([
        MarketplaceApiService.fetchLenders(),
        MarketplaceApiService.fetchBorrowers(),
        KycPendingVerifyApiService.checkKycStatus(),
        ProfileApiService.fetchProfile(),
      ]);

      final List<dynamic>? lenders = results[0] as List<dynamic>?;
      final List<dynamic>? borrowers = results[1] as List<dynamic>?;
      final Map<String, dynamic>? kycRes = results[2] as Map<String, dynamic>?;

      int adsCount = 0;
      if (lenders != null) {
        adsCount += lenders.where((l) => l['ledger_name']?.toString() == currentUserId).length;
      }
      if (borrowers != null) {
        adsCount += borrowers.where((b) => b['ledger_name']?.toString() == currentUserId).length;
      }

      String kycText = 'Unverified';
      if (kycRes != null) {
        final dynamic statusVal = kycRes['status'];
        final int status = int.tryParse(statusVal?.toString() ?? '') ?? 0;

        if (status == 2) {
          kycText = 'Verified';
        } else if (status == 3) {
          kycText = 'Pending';
        }
      }

      if (mounted) {
        setState(() {
          _myAdsCount = adsCount;
          _kycStatus = kycText;
        });
      }

      // Cache the updated values
      await prefs.setInt('cached_my_ads_count', adsCount);
      await prefs.setString('cached_kyc_status', kycText);
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1E3A8A),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Stack ────────────────────────────────────────────────
            SizedBox(
              height: 300.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Blue Gradient Header Background
                  Container(
                    height: 250.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF1644C8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32.r),
                        bottomRight: Radius.circular(32.r),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          // Back Arrow and Action Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (widget.showBackButton)
                                GestureDetector(
                                  onTap: () => Navigator.maybePop(context),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24.w,
                                  ),
                                )
                              else
                                SizedBox(width: 24.w),
                              SizedBox(width: 24.w), // Spacer to balance
                            ],
                          ),
                          SizedBox(height: 6.h),
                          // Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ValueListenableBuilder<String?>(
                                valueListenable: ProfileApiService.profileImageNotifier,
                                builder: (context, profileImg, _) {
                                  return Container(
                                    width: 90.w,
                                    height: 90.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3.0.w,
                                      ),
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
                              // Verified Checkmark / Pending / Danger Badge
                              if (_kycStatus == 'Verified')
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 20.w,
                                  ),
                                )
                              else if (_kycStatus == 'Pending')
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF59E0B), // Amber/Orange
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.pending_rounded,
                                    color: Colors.white,
                                    size: 20.w,
                                  ),
                                )
                              else
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.error_rounded,
                                    color: Colors.white,
                                    size: 20.w,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          // Name
                          ValueListenableBuilder<String>(
                            valueListenable: ProfileApiService.nameNotifier,
                            builder: (context, name, _) {
                              return Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              );
                            }
                          ),
                          SizedBox(height: 8.h),
                          // Premium Buyer Badge
                          Container(
                            width: 220.w,
                            height: 28.h,
                            decoration: BoxDecoration(
                              color:  Color(0x33D9D9D9),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            padding: EdgeInsets.only(
                              top: 7.h,
                              right: 13.w,
                              bottom: 7.h,
                              left: 13.w,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Premium Buyer - Borrower',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFFFFF),
                                height: 1.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlay Stats Card
                  Positioned(
                    top: 220.h,
                    left: 20.w,
                    right: 20.w,
                    child: Container(
                      height: 70.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                FastPageRoute(
                                  child: const MyAdsScreen(),
                                ),
                              );
                            },
                            behavior: HitTestBehavior.opaque,
                            child: _buildStatColumn(_myAdsCount.toString(), 'My Ads'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                FastPageRoute(
                                  child: const KycVerificationScreen(),
                                ),
                              );
                            },
                            behavior: HitTestBehavior.opaque,
                            child: _buildStatColumn(_kycStatus, 'KYC Status'),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (widget.onBookmarksTap != null) {
                                widget.onBookmarksTap!();
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: _buildStatColumn(_bookmarkCount.toString(), 'Bookmarks'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Settings List ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color:  Color(0xFF7C3AED), // Violet theme
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Account Settings Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          imagePath: 'assets/profile/person_kyc.png',
                          title: 'Personal Information',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF475569),
                            size: 26.w,
                          ),
                          onTap: () async {
                            final updated = await Navigator.of(context).push(
                              FastPageRoute(
                                child: const PersonalInfoScreen(),
                              ),
                            );
                            if (updated == true) {
                              _loadProfile();
                            }
                          },
                        ),
                        const _Divider(),
                        _buildSettingsTile(
                          imagePath: 'assets/profile/person_kyc.png',
                          title: 'KYC verification',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF475569),
                            size: 26.w,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              FastPageRoute(
                                child: const KycVerificationScreen(),
                              ),
                            );
                          },
                        ),
                        const _Divider(),
                        _buildSettingsTile(
                          imagePath: 'assets/profile/push_notifi.png',
                          title: 'Push Notifications',
                          trailing: Transform.translate(
                            offset:  Offset(6, 0),
                            child: SizedBox(
                              height: 32.h,
                              child: Switch(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: _pushNotifications,
                                onChanged: (val) =>
                                    setState(() => _pushNotifications = val),
                                activeThumbColor: Colors.white,
                                activeTrackColor: const Color(0xFF22C55E),
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                        const _Divider(),
                        _buildSettingsTile(
                          imagePath: 'assets/profile/email_notifi.png',
                          title: 'Email Notifications',
                          trailing: Transform.translate(
                            offset:  Offset(6, 0),
                            child: SizedBox(
                              height: 32.h,
                              child: Switch(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: _emailNotifications,
                                onChanged: (val) =>
                                    setState(() => _emailNotifications = val),
                                activeThumbColor: Colors.white,
                                activeTrackColor: const Color(0xFF22C55E),
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                        const _Divider(),
                        _buildSettingsTile(
                          imagePath: 'assets/profile/dark_mode.png',
                          title: 'Dark Mode',
                          trailing: Transform.translate(
                            offset: const Offset(6, 0),
                            child: SizedBox(
                              height: 32.h,
                              child: Switch(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: _isDarkMode,
                                onChanged: (val) async {
                                  setState(() {
                                    _isDarkMode = val;
                                  });
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool('is_dark_mode', val);
                                  ThemeManager.isDarkNotifier.value = val;
                                },
                                activeThumbColor: Colors.white,
                                activeTrackColor: const Color(0xFF22C55E),
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                        const _Divider(),
                        _buildSettingsTile(
                          imagePath: 'assets/profile/subscription.png',
                          title: 'Subcription plan',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF475569),
                            size: 26.w,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              FastPageRoute(
                                child: const SubscriptionPlanScreen(),
                              ),
                            );
                          },
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    'Support',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color:  Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Support Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSupportTile(
                          imagePath: 'assets/profile/help_center.png',
                          title: 'Help Center',
                          isRed: false,
                          onTap: () {
                            Navigator.of(context).push(
                              FastPageRoute(
                                child: const HelpCenterScreen(),
                              ),
                            );
                          },
                        ),
                        const _Divider(),
                        _buildSupportTile(
                          imagePath: 'assets/profile/terms_and _service.png',
                          title: 'Terms of Service',
                          isRed: false,
                          onTap: () {
                            Navigator.of(context).push(
                              FastPageRoute(
                                child: const TermsOfServiceScreen(),
                              ),
                            );
                          },
                        ),
                        const _Divider(),
                        _buildSupportTile(
                          imagePath: 'assets/profile/logout.png',
                          title: 'Log Out',
                          isRed: true,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.all(24.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1F000000),
                                        blurRadius: 24,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Warning/Logout Icon Container
                                      Container(
                                        padding: EdgeInsets.all(16.w),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFEE2E2), // Light red bg
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.logout_rounded,
                                          color: const Color(0xFFEF4444), // Primary red
                                          size: 32.w,
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      // Title
                                      Text(
                                        'Log Out',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      // Subtitle
                                      Text(
                                        'Are you sure want to logout?',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5.sp,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      SizedBox(height: 24.h),
                                      // Actions Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF64748B),
                                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.r),
                                                ),
                                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                              ),
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: Text(
                                                'No',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF004AC6), // App Theme Primary Blue
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.r),
                                                ),
                                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context).pop(); // Dismiss dialog
                                                final navigator = Navigator.of(context);
                                                final prefs = await SharedPreferences.getInstance();
                                                await prefs.clear();
                                                navigator.pushAndRemoveUntil(
                                                  FastPageRoute(
                                                    child: const LoginScreen(),
                                                  ),
                                                  (route) => false,
                                                );
                                              },
                                              child: Text(
                                                'Yes',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100.h), // Spacing for bottom nav bar
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatColumn(String val, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          val,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color:  Color(0xFF1B8A3D), // Green stats
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: const Color(0xFF525656),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String imagePath,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            Image.asset(imagePath, width: 32.w, height: 32.h, fit: BoxFit.contain),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
            Spacer(),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile({
    required String imagePath,
    required String title,
    required bool isRed,
    VoidCallback? onTap,
  }) {
    final Color itemColor = isRed
        ? const Color(0xFFEF4444)
        : const Color(0xFF1E293B);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Image.asset(imagePath, width: 24.w, height: 24.h, fit: BoxFit.contain),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14.64.sp,
                fontWeight: FontWeight.w400,
                color: itemColor,
                height: 1.5,
                letterSpacing: 0.0,
              ),
            ),
            Spacer(),
            if (!isRed)
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF475569),
                size: 26.w,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }
}


