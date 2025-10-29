import 'package:flutter/material.dart';
import 'package:naseej/main.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';

import 'payment/payment_methods_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool autoSaveEnabled = true;
  String currentLanguage = LanguageManager.getCurrentLanguageCode();
  ThemeMode currentThemeMode = ThemeManager.getThemeMode();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() {
    setState(() {
      notificationsEnabled = sharedPref.getBool("notifications_enabled") ?? true;
      autoSaveEnabled = sharedPref.getBool("auto_save_enabled") ?? true;
      currentLanguage = LanguageManager.getCurrentLanguageCode();
      currentThemeMode = ThemeManager.getThemeMode();
      darkModeEnabled = currentThemeMode == ThemeMode.dark;
    });
  }

  _saveSettings() {
    sharedPref.setBool("notifications_enabled", notificationsEnabled);
    sharedPref.setBool("auto_save_enabled", autoSaveEnabled);
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context);
    final languages = LanguageManager.getSupportedLanguages();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n.selectLanguage,
            style: TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: currentLanguage == language['code']
                      ? AppColor.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentLanguage == language['code']
                        ? AppColor.primaryColor
                        : AppColor.borderGray,
                    width: 1.5,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    language['nativeName']!,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(language['name']!),
                  value: language['code']!,
                  groupValue: currentLanguage,
                  activeColor: AppColor.primaryColor,
                  onChanged: (String? value) {
                    if (value != null) {
                      Navigator.of(context).pop();
                      _changeLanguage(value);
                    }
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel, style: TextStyle(color: AppColor.grey)),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n.themMode_s,
            style: TextStyle(color: AppColor.primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(ThemeMode.light, l10n.light_s, l10n.alwaysUseLight, Icons.light_mode),
              _buildThemeOption(ThemeMode.dark, l10n.dark_s, l10n.alwaysUseDark, Icons.dark_mode),
              _buildThemeOption(ThemeMode.system, l10n.system_s, l10n.followSystemTheme, Icons.brightness_auto),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel, style: TextStyle(color: AppColor.grey)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String title, String subtitle, IconData icon) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: currentThemeMode == mode
            ? AppColor.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentThemeMode == mode
              ? AppColor.primaryColor
              : AppColor.borderGray,
          width: 1.5,
        ),
      ),
      child: RadioListTile<ThemeMode>(
        title: Row(
          children: [
            Icon(icon, size: 20, color: AppColor.primaryColor),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        subtitle: Text(subtitle),
        value: mode,
        groupValue: currentThemeMode,
        activeColor: AppColor.primaryColor,
        onChanged: (ThemeMode? value) {
          if (value != null) {
            Navigator.of(context).pop();
            _changeTheme(value);
          }
        },
      ),
    );
  }

  void _changeLanguage(String languageCode) async {
    setState(() {
      currentLanguage = languageCode;
    });

    MyApp.of(context)?.changeLanguage(languageCode);

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.languageChangedSuccessfully),
        backgroundColor: AppColor.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _changeTheme(ThemeMode themeMode) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      currentThemeMode = themeMode;
      darkModeEnabled = themeMode == ThemeMode.dark;
    });

    MyApp.of(context)?.changeTheme(themeMode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.themeChangedSuccessfully),
        backgroundColor: AppColor.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getLanguageName(String code) {
    final languages = LanguageManager.getSupportedLanguages();
    final language = languages.firstWhere(
          (lang) => lang['code'] == code,
      orElse: () => {'nativeName': 'English'},
    );
    return language['nativeName']!;
  }

  String _getThemeName(ThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case ThemeMode.light:
        return l10n.light_s;
      case ThemeMode.dark:
        return l10n.dark_s;
      case ThemeMode.system:
        return l10n.system_s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // App Settings Section
          _buildSectionHeader(l10n.appSettings, Icons.tune),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.language,
            title: l10n.language,
            subtitle: _getLanguageName(currentLanguage),
            onTap: _showLanguageDialog,
            color: AppColor.primaryColor,
          ),

          _buildListTile(
            icon: Icons.palette_outlined,
            title: l10n.them_s,
            subtitle: _getThemeName(currentThemeMode),
            onTap: _showThemeDialog,
            color: AppColor.goldAccent,
          ),

          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.darkMode,
            subtitle: l10n.quickToggleFor,
            value: darkModeEnabled,
            onChanged: (value) {
              ThemeMode newMode = value ? ThemeMode.dark : ThemeMode.light;
              _changeTheme(newMode);
            },
            color: AppColor.earthBrown,
          ),

          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: l10n.pushNotifications,
            subtitle: l10n.receiveNotifications,
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
              _saveSettings();
            },
            color: AppColor.secondColor,
          ),

          _buildSwitchTile(
            icon: Icons.save_outlined,
            title: l10n.autoSave,
            subtitle: l10n.autoSaveDescription,
            value: autoSaveEnabled,
            onChanged: (value) {
              setState(() {
                autoSaveEnabled = value;
              });
              _saveSettings();
            },
            color: AppColor.goldAccent,
          ),

          SizedBox(height: 32),

          // Account Settings Section
          _buildSectionHeader(l10n.account, Icons.person_outline),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.lock_outline,
            title: l10n.changePassword,
            subtitle: l10n.updateAccountPassword,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureComingSoon),
                  backgroundColor: AppColor.goldAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            color: AppColor.primaryColor,
          ),

          _buildListTile(
            icon: Icons.payment_outlined,
            title: "Payment Methods",
            subtitle: "Manage Your Payment Methods",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
              );
            },
            color: AppColor.earthBrown,
          ),

          _buildListTile(
            icon: Icons.delete_outline,
            title: l10n.deleteAccount,
            subtitle: l10n.deleteAccountPermanently,
            textColor: AppColor.warningColor,
            onTap: () {
              _showDeleteAccountDialog();
            },
            color: AppColor.warningColor,
          ),

          SizedBox(height: 32),

          // Support Section
          _buildSectionHeader(l10n.support, Icons.help_outline),
          SizedBox(height: 12),

          _buildListTile(
            icon: Icons.help_outline,
            title: l10n.helpFAQ,
            subtitle: l10n.getHelpAnswers,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureComingSoon),
                  backgroundColor: AppColor.goldAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            color: AppColor.goldAccent,
          ),

          _buildListTile(
            icon: Icons.bug_report_outlined,
            title: l10n.reportBug,
            subtitle: l10n.helpImproveApp,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureComingSoon),
                  backgroundColor: AppColor.goldAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            color: AppColor.secondColor,
          ),

          SizedBox(height: 32),

          // App Information
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primaryColor, AppColor.secondColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.shopping_bag, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  "Naseej",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${l10n.version} 1.0.0",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Handcrafted Egyptian Carpets',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColor.primaryColor, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    Color? textColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColor.grey.withOpacity(0.5),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColor.warningColor),
            SizedBox(width: 12),
            Text(
              l10n.deleteAccount,
              style: TextStyle(color: AppColor.warningColor),
            ),
          ],
        ),
        content: Text(l10n.confirmDeleteAccount),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureComingSoon),
                  backgroundColor: AppColor.warningColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.warningColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}