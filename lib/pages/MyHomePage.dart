import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/main.dart';
import 'package:naseej/operations/addNote.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/operations/notedetailpage.dart';
import 'package:naseej/component/app_drawer.dart';
import 'package:naseej/pages/shop_page.dart';
import 'package:naseej/utils/favorites_manager.dart';
import '../l10n/generated/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Crud crud = Crud();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Traditional', 'icon': Icons.architecture},
    {'name': 'Modern', 'icon': Icons.filter_none},
    {'name': 'Vintage', 'icon': Icons.history},
    {'name': 'Custom', 'icon': Icons.palette},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize favorites manager with current user
    final userId = sharedPref.getString("user_id");
    if (userId != null) {
      FavoritesManager.setCurrentUser(userId);
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  getNotes() async {
    var response = await crud.postRequest(viewNoteLink, {
      "userId": sharedPref.getString("user_id")!
    });
    return response;
  }

  Future<void> _pickAndUploadImage(String noteId, ImageSource source, int? noteIndex) async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        _showUploadingOverlay();

        File imageFile = File(pickedFile.path);

        var response = await crud.postRequestWithFile(
          uploadImageLink,
          {"noteId": noteId},
          imageFile,
        );

        Navigator.of(context).pop(); // Remove overlay

        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.imageUploadedSuccessfully),
              backgroundColor: AppColor.successColor,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToUploadImage),
              backgroundColor: AppColor.warningColor,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorPickingImage),
          backgroundColor: AppColor.warningColor,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showUploadingOverlay() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColor.primaryColor,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                l10n.uploadingImage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeImage(String noteId, int? noteIndex) async {
    final l10n = AppLocalizations.of(context);

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.remove, style: TextStyle(color: AppColor.primaryColor)),
        content: Text(l10n.confirmRemoveImage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: AppColor.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.remove, style: TextStyle(color: AppColor.warningColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      var response = await crud.postRequest(removeImageLink, {
        "noteId": noteId,
      });

      if (response["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageRemovedSuccessfully),
            backgroundColor: AppColor.successColor,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToRemoveImage),
            backgroundColor: AppColor.warningColor,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      drawer: AppDrawer(
        onFavoritesChanged: () {
          setState(() {});
        },
      ),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColor.primaryColor,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'نسيج',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
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
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Welcome Section
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Handcrafted Egyptian Carpets',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Discover timeless elegance woven with tradition',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColor.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Promotions Section
          SliverToBoxAdapter(

            child: Container(
              height: 180,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: PageView(
                children: [
                  _buildPromotionCard(
                    title: 'Special Offer',
                    subtitle: 'Up to 30% OFF',
                    description: 'On Traditional Handwoven Carpets',
                    gradient: LinearGradient(
                      colors: [AppColor.primaryColor, AppColor.secondColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.local_offer,
                    category: 'All', // ✅ Added

                  ),
                  _buildPromotionCard(
                    title: 'New Arrival',
                    subtitle: 'Premium Collection',
                    description: 'Discover Our Latest Designs',
                    gradient: LinearGradient(
                      colors: [AppColor.goldAccent, AppColor.earthBrown],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.auto_awesome,
                    category: 'All', // ✅ Added

                  ),
                  _buildPromotionCard(
                    title: 'Free Shipping',
                    subtitle: 'Orders Over \$500',
                    description: 'Limited Time Offer',
                    gradient: LinearGradient(
                      colors: [AppColor.earthBrown, AppColor.bronzeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.local_shipping,
                    category: 'All', // ✅ Added

                  ),
                ],
              ),
            ),
          ),
          // Recommended Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColor.goldAccent, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Recommended for You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all products
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ShopPage(category: 'All'),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'] as String;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                          colors: [AppColor.primaryColor, AppColor.secondColor],
                        )
                            : null,
                        color: isSelected ? null : AppColor.cardBackground,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppColor.borderGray,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            size: 20,
                            color: isSelected ? Colors.white : AppColor.primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            category['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Products Grid
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: FutureBuilder(
              future: getNotes(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
                            SizedBox(height: 16),
                            Text(
                              "${l10n.error}: ${snapshot.error}",
                              style: TextStyle(color: AppColor.warningColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data["status"] != "success" ||
                    snapshot.data["data"] == null ||
                    snapshot.data["data"].isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyState(l10n),
                  );
                }

                List<dynamic> notes = snapshot.data["data"];

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final note = notes[i];
                      String? imageUrl;

                      if (note['note_image'] != null && note['note_image'].toString().isNotEmpty) {
                        imageUrl = imageBaseUrl + note['note_image'];
                      }

                      return ProductCard(
                        noteId: note['note_id'].toString(),
                        onTap: () {
                          String? fullImageUrl;
                          if (note['note_image'] != null && note['note_image'].toString().isNotEmpty) {
                            fullImageUrl = imageBaseUrl + note['note_image'];
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NoteDetailPage(
                                noteId: note['note_id'].toString(),
                                title: note['note_title'],
                                content: note['note_content'],
                                imageUrl: fullImageUrl,
                              ),
                            ),
                          ).then((result) {
                            if (result == true) {
                              setState(() {});
                            }
                          });
                        },
                        onImageTap: () {
                          _showImagePickerDialog(context, note['note_id'].toString(), i);
                        },
                        onFavoriteChanged: () {
                          setState(() {});
                        },
                        title: "${note['note_title']}",
                        content: "${note['note_content']}",
                        imageUrl: imageUrl,
                      );
                    },
                    childCount: notes.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // // Floating Action Button with Gradient
      // floatingActionButton: Container(
      //   decoration: BoxDecoration(
      //     shape: BoxShape.circle,
      //     gradient: LinearGradient(
      //       colors: [AppColor.primaryColor, AppColor.secondColor],
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: AppColor.primaryColor.withOpacity(0.4),
      //         blurRadius: 12,
      //         offset: Offset(0, 6),
      //       ),
      //     ],
      //   ),
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       Navigator.of(context).push(
      //         MaterialPageRoute(builder: (context) => AddNotePage()),
      //       ).then((result) {
      //         if (result == true) {
      //           setState(() {});
      //         }
      //       });
      //     },
      //     backgroundColor: Colors.transparent,
      //     elevation: 0,
      //     child: Icon(Icons.add, size: 32),
      //   ),
      // ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColor.cardBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 64,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              l10n.noNotesYet,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Start adding your handcrafted carpets',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddNotePage()),
                ).then((result) {
                  if (result == true) {
                    setState(() {});
                  }
                });
              },
              icon: Icon(Icons.add),
              label: Text('Add Product'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard({
    required String title,
    required String subtitle,
    required String description,
    required Gradient gradient,
    required IconData icon, required String category,
  }) {
    return GestureDetector(
        onTap: () {
          // Navigate to shop page with category filter
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShopPage(category: category),
            ),
          );
        },
     child: Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            color: AppColor.primaryColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }

  void _showImagePickerDialog(BuildContext context, String noteId, int noteIndex) {
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
                l10n.selectImage,
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
                      _pickAndUploadImage(noteId, ImageSource.camera, noteIndex);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: l10n.gallery,
                    color: AppColor.goldAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(noteId, ImageSource.gallery, noteIndex);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.delete_outline,
                    label: l10n.remove,
                    color: AppColor.warningColor,
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage(noteId, noteIndex);
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
        padding: EdgeInsets.all(20),
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
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
