import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/theme_manager.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84.h,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          height: 60.h,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Shadow container (underneath)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(29.54.r),
                      topRight: Radius.circular(29.54.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0D000000), // #0000000D
                        blurRadius: 36.92,
                        offset: Offset(0, -9.23),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              // Blurred background and content
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(29.54.r),
                    topRight: Radius.circular(29.54.r),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 36.92, sigmaY: 36.92),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.navBarBg,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(29.54.r),
                          topRight: Radius.circular(29.54.r),
                        ),
                        border: Border.all(
                          color: context.navBarBorder,
                          width: 1.45,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: _NavItem(
                              icon: 'assets/home/home.png',
                              label: 'HOME',
                              index: 0,
                              currentIndex: currentIndex,
                              onTap: onTap,
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: 'assets/home/market.png',
                              label: 'MARKET',
                              index: 1,
                              currentIndex: currentIndex,
                              onTap: onTap,
                            ),
                          ),
                          // Spacer for the center FAB
                          SizedBox(width: 56.w),
                          Expanded(
                            child: _NavItem(
                              icon: isSelected(3)
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              label: 'BOOKMARKS',
                              index: 3,
                              currentIndex: currentIndex,
                              onTap: onTap,
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: 'assets/home/profile.png',
                              label: 'PROFILE',
                              index: 4,
                              currentIndex: currentIndex,
                              onTap: onTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Center FAB using rounded container (like the screenshot mockup)
              Positioned(
                top: -20.h,
                child: GestureDetector(
                  onTap: onFabTap,
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF004AC6),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white, width: 2.5.w),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF004AC6).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isSelected(int index) => index == currentIndex;
}

class _NavItem extends StatelessWidget {
  final dynamic icon; // Can be String (asset path) or IconData
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;
    final Color activeColor = const Color(0xFF004AC6);
    final Color inactiveColor = context.navInactiveColor;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 60.h,
        child: Column(
          children: [
            // Top indicator bar (compact width to match the tab icon cleanly)
            Container(
              width: 38.w,
              height: 4.5.h,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2.2.r),
              ),
            ),
            Spacer(),
            // Custom Icon wrapper to support dynamic Image or IconData (with adjusted compact size)
            icon is IconData
                ? Icon(
                    icon as IconData,
                    size: 24.w,
                    color: isSelected ? activeColor : inactiveColor,
                  )
                : Image.asset(
                    icon as String,
                    width: 20.w,
                    height: 20.h,
                    color: isSelected ? activeColor : inactiveColor,
                    colorBlendMode: BlendMode.srcIn,
                  ),
            SizedBox(height: 4.h),
            // Text label with FittedBox scale-down to prevent text overflow pixels error
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 8.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }
}
