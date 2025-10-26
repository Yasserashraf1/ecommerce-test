import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:naseej/core/constant/imgaeasset.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/pages/MyHomePage.dart' hide Text;
import 'package:naseej/pages/explore_page.dart';
import 'package:naseej/pages/cart_page.dart';
import 'package:naseej/pages/favorites_page.dart';
import 'package:naseej/pages/settings_page.dart';
import 'package:naseej/component/custom_bottom_nav.dart';
import 'package:naseej/component/app_drawer.dart';

class MainContainer extends StatefulWidget {
  final int initialIndex;

  const MainContainer({Key? key, this.initialIndex = 2}) : super(key: key); // Default to Home (index 2)

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late int _currentIndex;
  bool _isLoading = false;

  // New order: Explore (0), Favorites (1), Home (2), Cart (3), Settings (4)
  final List<Widget> _pages = [
    ExplorePage(),
    FavoritesPage(),
    MyHomePage(),
    CartPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _isLoading = true;
    });

    // Show beautiful loading animation
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _currentIndex = index;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onFavoritesChanged: () {
          // This will trigger a refresh in the current page if needed
          setState(() {});
        },
      ),
      body: Stack(
        children: [
          // Current Page
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // Beautiful Lottie Loading Overlay
          if (_isLoading)
            Container(
              color: AppColor.backgroundcolor.withOpacity(0.95),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      AppImageAsset.animationLoading,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}