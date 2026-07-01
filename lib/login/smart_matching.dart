import 'package:tm/fast_page_route.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/login/login_screen.dart';
import 'package:tm/login/onboarding.dart';
import 'package:tm/profile/terms_of_service.dart';

class SmartMatchingScreen extends StatelessWidget {
  const SmartMatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Sizing adjustments to be responsive but conform to design specifications
    final double cardWidth = screenWidth > 672 ? 322 : screenWidth * 0.88;
    final double cardHeight = screenHeight > 800 ? 657 : screenHeight * 0.76;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F5FC), Color(0xFFEEEFFF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 12),

                        // Main Onboarding Card (Glassmorphism card)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
                              child: Container(
                                width: cardWidth,
                                height: cardHeight,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFFFFF,
                                  ).withValues(alpha: 0.6), // #FFFFFF99 (opacity: 0.6)
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFC3C6D7,
                                    ).withValues(alpha: 0.3), // #C3C6D74D (opacity: 0.3)
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x00000000).withValues(
                                        alpha: 0.05,
                                      ), // #0000000D (opacity: 0.05)
                                      blurRadius: 50,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Top Image Container with particle/concentric circle effect
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Concentric Circular Particle Effect background
                                        ...List.generate(3, (index) {
                                          final radiusMultiplier = (index + 1) * 60.0;
                                          return Container(
                                            width: radiusMultiplier,
                                            height: radiusMultiplier,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF2563EB,
                                                ).withValues(alpha: 0.04 * (3 - index)),
                                                width: 1.0,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                          );
                                        }),

                                        // The Center Asset Image container
                                        Container(
                                          width: 280,
                                          height: (screenHeight * 0.38).clamp(160.0, 300.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F3FE),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/login/AI Engine Visualization.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback UI if asset doesn't load
                                      return Container(
                                        color: const Color(0xFFECEEFF),
                                        child: const Center(
                                          child: Icon(
                                            Icons.psychology_rounded,
                                            size: 64,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Text Content (Title and Subtitle)
                          Column(
                            children: [
                              Text(
                                'Smart Matching',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF191B23),
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Borrower lender\nmatching.',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF434655),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          // 3-dot Page Indicator with the 3rd dot active
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final isActive = index == 2;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 6,
                                width: isActive ? 24 : 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF0053DB)
                                      : const Color(0xFFDBE1FF),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),

                          // Blue "Get Started ->" Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2563EB,
                                  ).withValues(alpha: 0.2), // #2563EB33
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const LoginScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;
                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started     ',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      height: 28 / 18,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Footer section: Previous Step | Terms of Service
              Padding(
                padding: const EdgeInsets.only(bottom: 54),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          FastPageRoute(
                            child: const OnboardingScreen(initialPage: 1),
                          ),
                        );
                      },
                      child: Text(
                        'Previous Step',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF434655),
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '|',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        color: const Color(0xFFC3C6D7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          FastPageRoute(
                            child: const TermsOfServiceScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Terms of Service',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF434655),
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
