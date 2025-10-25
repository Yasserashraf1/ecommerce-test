import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/main.dart';
import 'package:naseej/pages/settings_page.dart';
import 'package:naseej/pages/favorites_page.dart';
import 'package:naseej/pages/about_page.dart';
import 'package:naseej/pages/profile_page.dart';
import 'package:naseej/utils/language_manager.dart';
import 'package:naseej/utils/theme_manager.dart';

import '../l10n/generated/app_localizations.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback? onFavoritesChanged; // Add this callback

  const AppDrawer({Key? key, this.onFavoritesChanged}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Crud crud = Crud();
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  _loadUserProfile() async {
    try {
      var response = await crud.postRequest(getUserProfileLink, {
        "userId": sharedPref.getString("user_id")!
      });

      if (response["status"] == "success") {
        setState(() {
          userProfile = response["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfileImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        OverlayEntry? overlayEntry;
        overlayEntry = OverlayEntry(
          builder: (context) => Material(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(30),
                margin: EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 20),
                    Text(
                      l10n.uploadingImage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        Overlay.of(context).insert(overlayEntry);

        File imageFile = File(pickedFile.path);

        var response = await crud.postRequestWithFile(
          updateProfileImageLink,
          {"userId": sharedPref.getString("user_id")!},
          imageFile,
        );

        overlayEntry.remove();

        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileImageUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          _loadUserProfile(); // Reload profile data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToUploadImage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorSelectingImage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.updateProfileImage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _updateProfileImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            l10n.camera,
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _updateProfileImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library, size: 40, color: Colors.green),
                          SizedBox(height: 8),
                          Text(
                            l10n.gallery,
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        children: [
          // Header Section with User Profile
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                  Color(0xFF2C2C2C),
                  Color(0xFF1E1E1E),
                ]
                    : [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Center(
                      child: GestureDetector(
                        onTap: _showImagePickerDialog,
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? theme.colorScheme.primary
                                      : Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: isLoading
                                    ? Container(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.white.withOpacity(0.9),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                )
                                    : (userProfile != null &&
                                    userProfile!['profile_image'] != null &&
                                    userProfile!['profile_image'].toString().isNotEmpty)
                                    ? Image.network(
                                  profileImageBaseUrl + userProfile!['profile_image'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : Colors.white.withOpacity(0.9),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                    : _buildDefaultAvatar(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: isDark ? Colors.grey[700]! : Colors.white,
                                      width: 2
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // User Name
                    Center(
                      child: Text(
                        isLoading
                            ? l10n.loading
                            : userProfile?['user_name'] ?? l10n.noName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? theme.colorScheme.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    // User Email
                    Center(
                      child: Text(
                        sharedPref.getString("user_email") ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey[400]
                              : Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: Container(
              color: isDark ? Color(0xFF1E1E1E) : Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: 10),

                  // Profile
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: l10n.profile,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(userProfile: userProfile),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _loadUserProfile();
                        }
                      });
                    },
                  ),

                  // Divider
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      thickness: 1,
                    ),
                  ),

                  // Favorites - Updated with navigation result handling
                  _buildMenuItem(
                    icon: Icons.favorite_outline,
                    title: l10n.favorites,
                    onTap: () async {
                      Navigator.pop(context); // Close drawer

                      // Navigate to favorites page and wait for result
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FavoritesPage(),
                        ),
                      );

                      // If anything changed in favorites, notify parent (home page)
                      if (result == true && widget.onFavoritesChanged != null) {
                        widget.onFavoritesChanged!();
                      }
                    },
                  ),

                  // Settings
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    },
                  ),

                  // About Creator
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: l10n.aboutCreator,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  // Divider
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      thickness: 1,
                    ),
                  ),

                  // Logout
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: l10n.logout,
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      _showLogoutDialog();
                    },
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final l10n = AppLocalizations.of(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.grey[800]
            : Colors.white,
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? (isDark ? Colors.grey[200] : Colors.grey[800]),
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: isDark
            ? Colors.grey[800]?.withOpacity(0.3)
            : Colors.grey[100],
      ),
    );
  }

  void _showLogoutDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    showDialog(

      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          l10n.logout,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          l10n.confirmLogout,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear user-specific preferences
              LanguageManager.clearUserPreferences();
              ThemeManager.clearUserPreferences();
              sharedPref.clear();
              Navigator.of(context).pushNamedAndRemoveUntil(
                "/login",
                    (route) => false,
              );
            },
            child: Text(
              l10n.logout,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}