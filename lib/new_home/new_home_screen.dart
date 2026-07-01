import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_loan.dart';
import 'personal_loan.dart';
import 'vehicle_loan.dart';
import 'bussiness_loan.dart';

class NewHomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const NewHomeScreen({super.key, this.onProfileTap});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  // Currently selected loan type: 'home', 'personal', 'vehicle', 'business'
  String _selectedLoan = 'personal';

  // Carousel Controller and Timer
  late final PageController _pageController;
  int _currentAdIndex = 0;
  Timer? _adTimer;

  // API Banner Ads state
  List<String> _adImages = [];
  bool _isLoadingAds = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fetchAds();
    _startAdTimer();
  }

  Future<void> _fetchAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '31';
      final String lt = prefs.getString('lt') ?? '11';
      final String ln = prefs.getString('ln') ?? '11';

      debugPrint('Fetching ads with: device_id=$deviceId, lt=$lt, ln=$ln');

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
        debugPrint('Ads response: $responseData');
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

          // If they only have 3 images, add 3rd image to 3rd and 4th slide
          if (urls.length == 3) {
            urls.add(urls[2]);
          }

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
          duration: const Duration(milliseconds: 300), // 0.3 seconds transition
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Section ───────────────────────────────────────────
              _buildHeader(),

              // ── Hero Ad Banner ──────────────────────────────────────────
              _buildHeroAdBanner(),

              const SizedBox(height: 4), // Shifted indicators slightly higher
              // ── Ad Indicators ───────────────────────────────────────────
              _buildAdIndicators(),

              const SizedBox(
                height: 20,
              ), // Gap below indicators to push guest banner and subsequent contents down
              // ── Browsing as Guest Banner ────────────────────────────────
              _buildGuestBanner(),

              const SizedBox(height: 12),

              // ── Loans Section ────────────────────────────────────────────
              _buildLoansHeader(),
              const SizedBox(height: 12),
              _buildLoansGrid(),
              const SizedBox(height: 24),

              // ── Featured Lenders Section ─────────────────────────────────
              _buildLendersHeader(),
              const SizedBox(height: 12),
              _buildLendersList(),

              const SizedBox(height: 110), // Bottom padding for navbar clear
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Widget ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF061A5C), // Dark blue header
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(3),
            child: ClipOval(
              child: Image.asset(
                'assets/login/trueloan_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shield,
                  color: Color(0xFF061A5C),
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'TRUE LOAN',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
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
      height:
          185, // Total height of the ad banner area including hanging offset
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Full-width blue background block at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160, // Blue background block height
            child: Container(
              color: const Color(0xFF061A5C), // Matches dark blue header
            ),
          ),

          // 2. Ad banner card hanging down from the blue block
          Positioned(
            top: 12, // Offset down slightly inside the blue block
            left: 20,
            right: 20,
            height: 160, // Card height
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
                borderRadius: BorderRadius.circular(
                  12,
                ), // Rounded corners like the mockup card
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentAdIndex = index;
                    });
                    _startAdTimer(); // Reset autoplay timer on page change
                  },
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (_isLoadingAds) {
                      return _buildShimmerPlaceholder(index);
                    }
                    if (_adImages.isEmpty) {
                      return Image.asset(
                        'assets/new_home/trueloan_ad${index + 1}.png',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackPlaceholder(index),
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
                              _buildFallbackPlaceholder(index),
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

  Widget _buildShimmerPlaceholder(int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E6B),
        borderRadius: BorderRadius.circular(12),
      ),
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

  Widget _buildFallbackPlaceholder(int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        'Ad Banner ${index + 1}',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
          duration: const Duration(
            milliseconds: 200,
          ), // 0.3s transition duration
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

  // ── Guest Banner Widget ────────────────────────────────────────────────────
  Widget _buildGuestBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        8,
      ), // Matches 20px horizontal margin of other containers
      child: Container(
        height: 90, // Fixed height of 90px
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FFFD), // Background color #F8FFFD
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF009668),
            width: 1.5,
          ), // Green border color #009668
        ),
        child: Row(
          children: [
            // Globe icon inside #009668 circular background
            Container(
              width: 40, // Increased size to 40x40
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF009668), // Green background color #009668
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(
                5,
              ), // Inner padding to fit icon nicely
              child: Image.asset(
                'assets/new_home/globe.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.public, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(
              width: 14,
            ), // Spacing increased from 10 to 14 to shift text slightly right
            // Text column containing header, button, and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center text vertically
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Browsing as Guest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (widget.onProfileTap != null) {
                            widget.onProfileTap!();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF009668,
                            ), // Green color #009668
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Join Free',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Register to post requirements, connect\nwith lenders, and receive loan offers.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 9, // Fit text nicely
                      color: const Color(0xFF000000),
                      height: 1.2,
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

  // ── Loans Header Widget ────────────────────────────────────────────────────
  Widget _buildLoansHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Loans',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF525656),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Action for See All
            },
            child: Text(
              'See All',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF060C62),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loans Grid Widget ──────────────────────────────────────────────────────
  Widget _buildLoansGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: HomeLoanCard(
                  isSelected: _selectedLoan == 'home',
                  onTap: () {
                    setState(() => _selectedLoan = 'home');
                    showHomeLoanBottomSheet(context);
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: PersonalLoanCard(
                  isSelected: _selectedLoan == 'personal',
                  onTap: () {
                    setState(() => _selectedLoan = 'personal');
                    showPersonalLoanBottomSheet(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: VehicleLoanCard(
                  isSelected: _selectedLoan == 'vehicle',
                  onTap: () {
                    setState(() => _selectedLoan = 'vehicle');
                    showVehicleLoanBottomSheet(context);
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: BusinessLoanCard(
                  isSelected: _selectedLoan == 'business',
                  onTap: () {
                    setState(() => _selectedLoan = 'business');
                    showBusinessLoanBottomSheet(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Featured Lenders Header Widget ─────────────────────────────────────────
  Widget _buildLendersHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Featured Lenders',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF525656),
        ),
      ),
    );
  }

  // ── Featured Lenders Widget (Switches between categories) ──────────────────
  Widget _buildLendersList() {
    switch (_selectedLoan) {
      case 'home':
        return const HomeLoanBottomCard();
      case 'personal':
        return const PersonalLoanBottomCard();
      case 'vehicle':
        return const VehicleLoanBottomCard();
      case 'business':
        return const BusinessLoanBottomCard();
      default:
        return const SizedBox(
          height: 154,
          child: Center(
            child: Text('No featured lenders available for this type.'),
          ),
        );
    }
  }
}
