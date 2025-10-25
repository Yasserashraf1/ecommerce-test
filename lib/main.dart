import 'package:flutter/material.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naseej/routes.dart';
import 'package:get/get.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

late SharedPreferences sharedPref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();

  // Initialize managers
  await LanguageManager.initialize();
  await ThemeManager.initialize();
  await FavoritesManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  void _loadUserPreferences() {
    // Load saved language
    final languageCode = LanguageManager.getCurrentLanguageCode();
    _locale = Locale(languageCode);

    // Load saved theme
    _themeMode = ThemeManager.getThemeMode();

    setState(() {});
  }

  void changeLanguage(String languageCode) async {
    await LanguageManager.setLanguage(languageCode);
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  void changeTheme(ThemeMode themeMode) async {
    await ThemeManager.setThemeMode(themeMode);
    setState(() {
      _themeMode = themeMode;
    });
  }

  // Check if user has completed onboarding
  String _getInitialRoute() {
    String? step = sharedPref.getString("step");
    String? userId = sharedPref.getString("user_id");

    // If user is logged in, go to home
    if (userId != null && userId.isNotEmpty) {
      // Initialize user-specific settings
      LanguageManager.setCurrentUser(userId);
      ThemeManager.setCurrentUser(userId);
      FavoritesManager.setCurrentUser(userId);
      return "/home";
    }

    // If onboarding completed, go to login
    if (step == "1") {
      return "/login";
    }

    // Otherwise, show onboarding
    return "/onboarding";
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Naseej App',
      debugShowCheckedModeBanner: false,

      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Supported locales
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],

      // Current locale
      locale: _locale,

      // Fallback locale
      fallbackLocale: const Locale('en', ''),

      // Theme configuration
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,

      // Routes
      getPages: routes,
      initialRoute: _getInitialRoute(),
    );
  }
}