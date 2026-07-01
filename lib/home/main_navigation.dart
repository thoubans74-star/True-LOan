import 'package:tm/fast_page_route.dart';
import 'package:flutter/material.dart';
import 'marketplace_screen.dart';
import 'ads_screen.dart';
import 'bottom_nav_bar.dart';
import 'create_ad_screen.dart';
import '../profile/profile.dart';
import 'home_screen.dart';
import 'request_screen.dart';


class MainNavigationScreen extends StatefulWidget {
  final bool openCreateAd;
  final int initialSelectedType;

  const MainNavigationScreen({
    super.key,
    this.openCreateAd = false,
    this.initialSelectedType = -1,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.openCreateAd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => CreateAdScreen(
              initialSelectedType: widget.initialSelectedType,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      });
    }
  }


  void _onNavTap(int index) {
    if (index == 2) return; // FAB handled separately
    setState(() => _currentIndex = index);
  }

  void _onFabTap() {
    Navigator.of(context).push(
      FastPageRoute(child: const CreateAdScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        key: ValueKey(_currentIndex == 0),
        onProfileTap: () => _onNavTap(4),
        onRequestTap: () => _onNavTap(5),
        onBookmarksTap: () => _onNavTap(3),
        onMarketCardTap: (name, role) {
          MarketplaceScreen.detailsTrigger.value = {
            'name': name,
            'role': role,
          };
          _onNavTap(1);
        },
      ),
      const MarketplaceScreen(),
      const SizedBox.shrink(), // placeholder index 2 (FAB)
      AdsScreen(
        key: ValueKey(_currentIndex),
        onBackTap: () => _onNavTap(0),
      ),
      ProfileScreen(
        showBackButton: false,
        key: ValueKey(_currentIndex),
        onBookmarksTap: () => _onNavTap(3),
      ),
      RequestScreen(onBackTap: () => _onNavTap(0)),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onFabTap: _onFabTap,
      ),
    );
  }
}

