import 'package:naseej/auth/login.dart';
import 'package:naseej/auth/register.dart';
import 'package:naseej/pages/MyHomePage.dart';
import 'package:naseej/onboarding/onboarding.dart';
import 'package:get/get.dart';
import 'package:naseej/pages/shop_page.dart';

List<GetPage<dynamic>>? routes = [
  // Onboarding route
  GetPage(name: "/onboarding", page: () => const OnBoarding()),

  // Auth routes
  GetPage(name: "/login", page: () => const login()),
  GetPage(name: "/register", page: () => const register()),

  // Home route
  GetPage(name: "/home", page: () => const MyHomePage()),

  // Direct page access
  GetPage(name: "/shop", page: () => const ShopPage(category: 'All')),

];