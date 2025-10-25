import 'package:flutter/material.dart';
import 'package:naseej/main.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';
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
    // Load saved settings from SharedPreferences
    setState(() {
      notificationsEnabled = sharedPref.getBool("notifications_enabled") ?? true;
      autoSaveEnabled = sharedPref.getBool("auto_save_enabled") ?? true;
      currentLanguage = LanguageManager.getCurrentLanguageCode();
      currentThemeMode = ThemeManager.getThemeMode();

      // Update darkModeEnabled based on current theme mode
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
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return RadioListTile<String>(
                title: Text(language['nativeName']!),
                subtitle: Text(language['name']!),
                value: language['code']!,
                groupValue: currentLanguage,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (String? value) {
                  if (value != null) {
                    Navigator.of(context).pop();
                    _changeLanguage(value);
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
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
          title: Text(l10n.themMode_s),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l10n.light_s),
                subtitle: Text(l10n.alwaysUseLight),
                value: ThemeMode.light,
                groupValue: currentThemeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    Navigator.of(context).pop();
                    _changeTheme(value);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.dark_s),
                subtitle: Text(l10n.alwaysUseDark),
                value: ThemeMode.dark,
                groupValue: currentThemeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    Navigator.of(context).pop();
                    _changeTheme(value);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.system_s),
                subtitle: Text(l10n.followSystemTheme),
                value: ThemeMode.system,
                groupValue: currentThemeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    Navigator.of(context).pop();
                    _changeTheme(value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(String languageCode) async {
    setState(() {
      currentLanguage = languageCode;
    });

    // Change app language
    MyApp.of(context)?.changeLanguage(languageCode);

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.languageChangedSuccessfully),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _changeTheme(ThemeMode themeMode) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      currentThemeMode = themeMode;
      darkModeEnabled = themeMode == ThemeMode.dark;
    });

    // Change app theme
    MyApp.of(context)?.changeTheme(themeMode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.themeChangedSuccessfully),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
    switch (mode) {
      case ThemeMode.light:
        return "Light";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.system:
        return "System";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // App Settings Section
          _buildSectionHeader(l10n.appSettings),
          SizedBox(height: 10),

          // Language Selection
          _buildListTile(
            icon: Icons.language,
            title: l10n.language,
            subtitle: _getLanguageName(currentLanguage),
            onTap: _showLanguageDialog,
          ),

          // Theme Selection
          _buildListTile(
            icon: Icons.palette_outlined,
            title: l10n.them_s,
            subtitle: _getThemeName(currentThemeMode),
            onTap: _showThemeDialog,
          ),

          // Quick Dark Mode Toggle
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.darkMode,
            subtitle: l10n.quickToggleFor,
            value: darkModeEnabled,
            onChanged: (value) {
              ThemeMode newMode = value ? ThemeMode.dark : ThemeMode.light;
              _changeTheme(newMode);
            },
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
          ),

          SizedBox(height: 30),

          // Account Settings Section
          _buildSectionHeader(l10n.account),
          SizedBox(height: 10),

          _buildListTile(
            icon: Icons.lock_outline,
            title: l10n.changePassword,
            subtitle: l10n.updateAccountPassword,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon)),
              );
            },
          ),

          _buildListTile(
            icon: Icons.backup_outlined,
            title: l10n.backupSync,
            subtitle: l10n.backupToCloud,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon)),
              );
            },
          ),

          _buildListTile(
            icon: Icons.delete_outline,
            title: l10n.deleteAccount,
            subtitle: l10n.deleteAccountPermanently,
            textColor: Colors.red,
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),

          SizedBox(height: 30),

          // Support Section
          _buildSectionHeader(l10n.support),
          SizedBox(height: 10),

          _buildListTile(
            icon: Icons.help_outline,
            title: l10n.helpFAQ,
            subtitle: l10n.getHelpAnswers,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon)),
              );
            },
          ),

          _buildListTile(
            icon: Icons.bug_report_outlined,
            title: l10n.reportBug,
            subtitle: l10n.helpImproveApp,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon)),
              );
            },
          ),

          SizedBox(height: 30),

          // App Information
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.grey[200]!
              ),
            ),
            child: Column(
              children: [
                Text(
                  l10n.appTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "${l10n.version} 1.0.0",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[200]!
        ),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[200]!
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (textColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: textColor ?? Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: textColor ?? Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[500]
              : Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.confirmDeleteAccount),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureComingSoon),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}