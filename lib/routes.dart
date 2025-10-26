import 'package:naseej/auth/login.dart';
import 'package:naseej/auth/register.dart';
import 'package:naseej/pages/main_container.dart';
import 'package:naseej/onboarding/onboarding.dart';
import 'package:get/get.dart';
import 'package:naseej/pages/shop_page.dart';
import 'package:naseej/pages/main_container.dart';
List<GetPage<dynamic>>? routes = [
  // Onboarding route
  GetPage(name: "/onboarding", page: () => const OnBoarding()),

  // Auth routes
  GetPage(name: "/login", page: () => const login()),
  GetPage(name: "/register", page: () => const register()),

  // Main container with bottom navigation - starts at Home (index 2)
  GetPage(name: "/main", page: () => const MainContainer(initialIndex: 2)),

  // Direct page access
  GetPage(name: "/shop", page: () => const ShopPage(category: 'All')),
];