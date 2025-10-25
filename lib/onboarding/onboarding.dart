import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/core/constant/imgaeasset.dart';
import 'package:naseej/onboarding/custombutton.dart';
import 'package:naseej/onboarding/customslider.dart';
import 'package:naseej/onboarding/dotcontroller.dart';
import 'package:naseej/main.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with SingleTickerProviderStateMixin {
  late PageController pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int currentPage = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // Initialize fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void nextPage() async {
    currentPage++;

    if (currentPage > 2) { // Last page - navigate to login
      // Start fade animation
      setState(() {
        isLoading = true;
      });

      _animationController.forward();

      // Mark onboarding as completed
      await sharedPref.setString("step", "1");

      // Wait for animation (2.5 seconds total)
      await Future.delayed(const Duration(milliseconds: 2500));

      // Navigate to login page
      if (mounted) {
        Navigator.of(context).pushReplacementNamed("/login");
      }
    } else {
      // Navigate to next onboarding page
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: Stack(
        children: [
          // Main Onboarding Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: CustomSliderOnBoarding(
                    pageController: pageController,
                    onPageChanged: onPageChanged,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      CustomDotControllerOnBoarding(currentPage: currentPage),
                      const Spacer(flex: 2),
                      CustomButtonOnBoarding(
                        onPressed: isLoading ? () {} : nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Animated Loading Overlay
          if (isLoading)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: AppColor.backgroundcolor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lottie Loading Animation
                      Lottie.asset(
                        AppImageAsset.animationLoading,
                        width: 280,
                        height: 280,
                        fit: BoxFit.contain,
                        repeat: true,
                      ),

                      const SizedBox(height: 40),

                      // Animated Loading Text
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            const Text(
                              "Welcome Aboard!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              "Setting up your experience...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColor.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Progress Indicator
                      const SizedBox(
                        width: 35,
                        height: 35,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.primaryColor,
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
    );
  }
}