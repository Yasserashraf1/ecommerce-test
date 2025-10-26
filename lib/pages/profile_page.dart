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
        slivers: [
          // App Bar with Gradient
          SliverAppBar(
            expandedHeight: 200,
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
                    ],
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
                  // Profile Image Section - FIXED DESIGN
                  Transform.translate(
                    offset: Offset(0, -50),
                    child: GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Gradient border
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColor.primaryColor, AppColor.goldAccent],
                              ),
                            ),
                          ),
                          // White ring
                          Container(
                            width: 124,
                            height: 124,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Color(0xFF1A1614) : Colors.white,
                            ),
                          ),
                          // Image
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppColor.primaryColor.withOpacity(0.3), blurRadius: 20, offset: Offset(0, 10))],
                            ),
                            child: ClipOval(
                              child: isLoadingImage
                                  ? Container(color: AppColor.backgroundcolor2, child: Center(child: CircularProgressIndicator(color: AppColor.primaryColor, strokeWidth: 3)))
                                  : (currentProfile != null && currentProfile!['profile_image'] != null && currentProfile!['profile_image'].toString().isNotEmpty)
                                  ? Image.network(profileImageBaseUrl + currentProfile!['profile_image'], width: 120, height: 120, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                  loadingBuilder: (_, child, progress) => progress == null ? child : Container(color: AppColor.backgroundcolor2, child: Center(child: CircularProgressIndicator(color: AppColor.primaryColor, strokeWidth: 3))))
                                  : _buildDefaultAvatar(),
                            ),
                          ),
                          // Edit button
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColor.primaryColor, AppColor.goldAccent]),
                                shape: BoxShape.circle,
                                border: Border.all(color: isDark ? Color(0xFF1A1614) : Colors.white, width: 3),
                                boxShadow: [BoxShadow(color: AppColor.primaryColor.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))],
                              ),
                              child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Edit Name Section
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.edit, color: AppColor.primaryColor, size: 22),
                            ),
                            SizedBox(width: 12),
                            Text(
                              l10n.editYourName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        Text(
                          l10n.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 10),
                        CustomTextForm(
                          hintText: l10n.enterFullName,
                          controller: nameController,
                        ),

                        SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: Button(
                            title: l10n.updateName,
                            isLoading: false,
                            onpressed: updateProfile,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Account Information Section
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColor.borderGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColor.goldAccent, size: 24),
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
                        _buildInfoRow(l10n.email, sharedPref.getString("user_email") ?? l10n.noEmail),
                        _buildInfoRow(l10n.created, _formatDate(currentProfile?['created_at'])),
                        _buildInfoRow(l10n.accountStatus, l10n.active,
                            valueColor: AppColor.successColor),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColor.primaryColor.withOpacity(0.3), AppColor.secondColor.withOpacity(0.3)],
        ),
      ),
      child: Icon(
        Icons.person,
        size: 60,
        color: AppColor.primaryColor,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColor.grey,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: valueColor ?? AppColor.primaryColor,
              ),
              textAlign: TextAlign.right,
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
      return "${date.day}/${date.month}/${date.year}";
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