import 'package:tm/fast_page_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/login/login_screen.dart';
import 'package:tm/login/smart_matching.dart';
import 'package:tm/theme_manager.dart';

class OnboardingScreen extends StatefulWidget {
  final int initialPage;
  const OnboardingScreen({super.key, this.initialPage = 0});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  // Reusable slides content
  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      imagePath: 'assets/login/Illustration Section.png',
      title: 'Need a Loan?',
      description:
          'Find verified lenders instantly and get\nthe financial support you deserve with\nzero hidden fees.',
    ),
    const OnboardingSlide(
      imagePath: 'assets/login/Financial Investment Growth.png',
      title: 'Provide Loans',
      description:
          'Connect with verified borrowers and\ngrow your wealth with precision and\nsecurity.',
    ),
  ];

  void _onSkip() {
    Navigator.of(context).pushReplacement(
      FastPageRoute(child: const LoginScreen()),
    );
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        FastPageRoute(child: const SmartMatchingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.015,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TRUE LOAN Title logo
                  Text(
                    'TRUE LOAN',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.0615,
                      fontWeight: FontWeight.w700,
                      height: 32 / 24,
                      letterSpacing: -screenWidth * 0.001538,
                      color: context.isDarkMode ? Colors.white : const Color(0xFF004AC6),
                    ),
                  ),
                  // Skip button
                  GestureDetector(
                    onTap: _onSkip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: screenWidth * 0.041,
                        fontWeight: FontWeight.w400,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: context.subTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Reusable Page Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    slide: _slides[index],
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  );
                },
              ),
            ),

            // Bottom Actions (Page Indicators & Swipe Button)
            Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.05, // Positioned lower on the screen
                top: screenHeight * 0.005,
              ),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3, // Hardcoded to 3 dots
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (context.isDarkMode ? Colors.blueAccent : const Color(0xFF0053DB))
                              : (context.isDarkMode ? Colors.white30 : const Color(0xFFDBE1FF)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight * 0.035,
                  ), // Increased from 0.025 to lift indicators higher relative to SwipeButton
                  // Normal Next Button
                  NextButton(onPressed: _onNext, text: 'Next'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Onboarding Page class to easily support multiple screens at a time
class OnboardingPage extends StatelessWidget {
  final OnboardingSlide slide;
  final double screenWidth;
  final double screenHeight;

  const OnboardingPage({
    super.key,
    required this.slide,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration Card
        // Illustration Card (Responsive width: screenWidth * 0.92, height: screenWidth * 0.92)
        SizedBox(
          width: screenWidth * 0.92,
          height: screenWidth * 0.92,
          child: Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: context.isDarkMode ? Colors.black45 : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: slide.imagePath.contains('Financial Investment Growth')
                    ? const EdgeInsets.all(24.0)
                    : EdgeInsets.zero,
                child: Image.asset(
                  slide.imagePath,
                  fit: slide.imagePath.contains('Financial Investment Growth')
                      ? BoxFit.contain
                      : BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue.shade50,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Image.asset(
                          'assets/login/Logo Section.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.025),

        // Slide Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize:
                  screenWidth *
                  0.05128, // Reduced from screenWidth * 0.0615 (~20px responsive)
              fontWeight: FontWeight.w700,
              height: 32 / 24,
              letterSpacing: 0,
              color: context.textColor,
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        // Slide Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Text(
            slide.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize:
                  screenWidth *
                  0.036, // Set back to 18px responsive to match design specifications
              fontWeight: FontWeight.w400,
              height: 28 / 18,
              letterSpacing: 0,
              color: context.subTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingSlide {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

// Custom Next Button Widget
class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const NextButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final buttonWidth =
        screenWidth * 0.80; // Increased width (approx 331px on 390px display)
    final buttonHeight =
        screenWidth * 0.130; // Increased height (approx 54px on 390px display)

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF2563EB), Color(0xFF004AC6)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black45 : const Color(0xFF004AC6).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.046, // ~18px responsive to fit nicely
            fontWeight: FontWeight.w500,
            height: 24 / 18,
            letterSpacing: 0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
