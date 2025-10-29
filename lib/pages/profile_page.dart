import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/main.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/component/textformfield.dart';
import '../l10n/generated/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userProfile;

  const ProfilePage({Key? key, this.userProfile}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  Crud crud = Crud();
  bool isLoading = false;
  bool isLoadingImage = false;
  Map<String, dynamic>? currentProfile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await crud.postRequest(getUserProfileLink, {
        "userId": sharedPref.getString("user_id")!
      });

      if (response["status"] == "success") {
        setState(() {
          currentProfile = response["data"];
          nameController.text = currentProfile?['user_name'] ?? '';
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
        setState(() {
          isLoadingImage = true;
        });

        File imageFile = File(pickedFile.path);

        var response = await crud.postRequestWithFile(
          updateProfileImageLink,
          {"userId": sharedPref.getString("user_id")!},
          imageFile,
        );

        setState(() {
          isLoadingImage = false;
        });

        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileImageUpdatedSuccessfully),
              backgroundColor: AppColor.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadUserProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToUpdateProfileImage),
              backgroundColor: AppColor.warningColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorPickingImage),
          backgroundColor: AppColor.warningColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.borderGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                l10n.updateProfileImage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: l10n.camera,
                    color: AppColor.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      _updateProfileImage(ImageSource.camera);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: l10n.gallery,
                    color: AppColor.goldAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _updateProfileImage(ImageSource.gallery);
                    },
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

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateProfile() async {
    final l10n = AppLocalizations.of(context);
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.nameCannotBeEmpty),
          backgroundColor: AppColor.warningColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var response = await crud.postRequest(updateProfileLink, {
      "userId": sharedPref.getString("user_id")!,
      "userName": nameController.text.trim(),
    });

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      setState(() {
        if (currentProfile != null) {
          currentProfile!['user_name'] = nameController.text.trim();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdatedSuccessfully),
          backgroundColor: AppColor.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToUpdateProfile),
          backgroundColor: AppColor.warningColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        appBar: AppBar(
          title: Text(l10n.profile),
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Enhanced App Bar with better gradient
          SliverAppBar(
            expandedHeight: 180, // Reduced height to prevent image cutoff
            floating: false,
            pinned: true,
            backgroundColor: AppColor.primaryColor,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                l10n.profile,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.primaryColor,
                      AppColor.secondColor,
                      AppColor.goldAccent,
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Fixed Profile Image Section - Minimal Shadow
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background decorative elements
                        Positioned(
                          top: -10,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColor.primaryColor.withOpacity(0.1),
                                  AppColor.goldAccent.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Main profile image container
                        GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // MINIMAL Outer glow effect - Reduced shadow
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.primaryColor.withOpacity(0.15), // Reduced opacity
                                      blurRadius: 8, // Reduced blur
                                      spreadRadius: 1, // Reduced spread
                                      offset: Offset(0, 4), // Reduced offset
                                    ),
                                  ],
                                ),
                              ),

                              // Gradient border
                              Container(
                                width: 136,
                                height: 136,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.primaryColor,
                                      AppColor.goldAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),

                              // White/dark background
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? Color(0xFF2C2520) : Colors.white,
                                  // REMOVED inner shadow completely
                                ),
                              ),

                              // Profile image
                              Container(
                                width: 126,
                                height: 126,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? Color(0xFF2C2520) : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: isLoadingImage
                                      ? Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColor.backgroundcolor2,
                                          AppColor.backgroundcolor,
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColor.primaryColor,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  )
                                      : (currentProfile != null &&
                                      currentProfile!['profile_image'] != null &&
                                      currentProfile!['profile_image'].toString().isNotEmpty)
                                      ? Image.network(
                                    profileImageBaseUrl + currentProfile!['profile_image'],
                                    width: 126,
                                    height: 126,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                    loadingBuilder: (_, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColor.backgroundcolor2,
                                              AppColor.backgroundcolor,
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColor.primaryColor,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                      : _buildDefaultAvatar(),
                                ),
                              ),

                              // Edit camera button - MINIMAL shadow
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColor.primaryColor,
                                        AppColor.secondColor,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? Color(0xFF2C2520) : Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.primaryColor.withOpacity(0.2), // Reduced opacity
                                        blurRadius: 4, // Reduced blur
                                        offset: Offset(0, 2), // Reduced offset
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User Name Display
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Text(
                          currentProfile?['user_name'] ?? l10n.unknown,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                            fontFamily: 'PlayfairDisplay',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          sharedPref.getString("user_email") ?? l10n.noEmail,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Name Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF2C2520) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.08),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.primaryColor,
                                    AppColor.secondColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.edit, color: Colors.white, size: 22),
                            ),
                            SizedBox(width: 12),
                            Text(
                              l10n.editYourName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        Text(
                          l10n.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor2,
                          ),
                          child: TextFormField(
                            controller: nameController,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : AppColor.primaryColor,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.enterFullName,
                              hintStyle: TextStyle(color: AppColor.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.transparent),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // FIXED BUTTON HEIGHT - Increased from 50 to 56
                        SizedBox(
                          width: double.infinity,
                          height: 56, // Increased height to prevent text cutoff
                          child: ElevatedButton(
                            onPressed: updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Added padding
                            ),
                            child: isLoading
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  l10n.updateName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Account Information Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF2C2520) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.08),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.goldAccent,
                                    AppColor.earthBrown,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.person_outline, color: Colors.white, size: 22),
                            ),
                            SizedBox(width: 12),
                            Text(
                              l10n.accountInformation,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.goldAccent,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        _buildInfoItem(
                          icon: Icons.email_outlined,
                          label: l10n.email,
                          value: sharedPref.getString("user_email") ?? l10n.noEmail,
                          iconColor: AppColor.primaryColor,
                        ),
                        SizedBox(height: 16),
                        _buildInfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: "memberSince",
                          value: _formatDate(currentProfile?['created_at']),
                          iconColor: AppColor.goldAccent,
                        ),
                        SizedBox(height: 16),
                        _buildInfoItem(
                          icon: Icons.verified_user_outlined,
                          label: l10n.accountStatus,
                          value: l10n.active,
                          valueColor: AppColor.successColor,
                          iconColor: AppColor.successColor,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.2),
            AppColor.secondColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: 50,
        color: AppColor.primaryColor.withOpacity(0.7),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required Color iconColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColor.earthBrown.withOpacity(0.1) : AppColor.borderGray,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColor.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: valueColor ?? (isDark ? Colors.white : AppColor.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    final l10n = AppLocalizations.of(context);
    if (dateString == null) return l10n.unknown;
    try {
      DateTime date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (e) {
      return l10n.unknown;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}