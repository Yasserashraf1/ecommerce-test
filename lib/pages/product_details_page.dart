import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/main.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/operations/edit.dart';
import '../l10n/generated/app_localizations.dart';

class ProductDetailsPage extends StatefulWidget {
  final String noteId;
  final String title;
  final String content;
  final String? imageUrl;

  const ProductDetailsPage({
    Key? key,
    required this.noteId,
    required this.title,
    required this.content,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  Crud crud = Crud();
  final ImagePicker _picker = ImagePicker();
  String? currentImageUrl;
  bool isFavorite = false;
  bool _isAddingToCart = false;

  // Product options
  int selectedQuantity = 1;
  String? selectedSize;
  String? selectedColor;
  int currentImageIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Available options (extracted from content or default)
  final List<String> availableSizes = ['Small (4x6 ft)', 'Medium (6x9 ft)', 'Large (8x10 ft)', 'X-Large (9x12 ft)'];
  final List<Map<String, dynamic>> availableColors = [
    {'name': 'Burgundy', 'color': Color(0xFF8b3c3c)},
    {'name': 'Gold', 'color': Color(0xFFd4a574)},
    {'name': 'Brown', 'color': Color(0xFF8b7355)},
    {'name': 'Cream', 'color': Color(0xFFf1e9db)},
    {'name': 'Multi-color', 'color': Color(0xFFc26b6b)},
  ];

  // Sample images for the carousel (in real app, fetch from server)
  List<String> productImages = [];

  @override
  void initState() {
    super.initState();
    currentImageUrl = widget.imageUrl;
    isFavorite = FavoritesManager.isFavorite(widget.noteId);

    // Initialize with default selections
    selectedSize = availableSizes[1]; // Default to Medium
    selectedColor = availableColors[0]['name'];

    // Initialize images (in real app, fetch multiple images from server)
    productImages = [
      if (currentImageUrl != null) currentImageUrl!,
      // Add placeholder for demo (in real app, these would come from server)
      'assets/images/rug1.jpg',
      'assets/images/icon1.png',
      'assets/images/rug1.jpg',
      'assets/images/rug1.jpg',
    ];
    // Let's add more images for demonstration purposes
    if (productImages.isEmpty) {
      productImages = ['placeholder']; // Fallback
    }

    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final l10n = AppLocalizations.of(context);
    _animationController.forward().then((_) => _animationController.reverse());

    setState(() {
      isFavorite = !isFavorite;
    });

    await FavoritesManager.toggleFavorite(widget.noteId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? l10n.addedToFavorites : l10n.removedFromFavorites),
        backgroundColor: isFavorite ? AppColor.successColor : AppColor.grey,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addToCart() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isAddingToCart = true;
    });

    // Simulate adding to cart (in real app, make API call)
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isAddingToCart = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Added to cart successfully!'),
            ),
          ],
        ),
        backgroundColor: AppColor.successColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to cart
            // Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  Future<void> _deleteProduct() async {
    final l10n = AppLocalizations.of(context);

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteNote, style: TextStyle(color: AppColor.primaryColor)),
        content: Text(l10n.deleteNoteDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: AppColor.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete, style: TextStyle(color: AppColor.warningColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      var response = await crud.postRequest(deleteNoteLink, {
        "noteId": widget.noteId,
      });

      if (response["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDeletedSuccessfully),
            backgroundColor: AppColor.successColor,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDeleteNote),
            backgroundColor: AppColor.warningColor,
          ),
        );
      }
    }
  }

  String _extractPrice() {
    final priceRegex = RegExp(r'\$?\d+\.?\d*');
    final match = priceRegex.firstMatch(widget.content);
    if (match != null) {
      var price = match.group(0);
      return price!.startsWith('\$') ? price : '\$$price';
    }
    return '\$299';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Gallery
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            backgroundColor: AppColor.primaryColor,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: AppColor.primaryColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.pink : AppColor.primaryColor,
                    ),
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Gallery
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemCount: productImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showFullScreenImage(index),
                        child: _buildProductImage(productImages[index]),
                      );
                    },
                  ),

                  // Image Indicators
                  if (productImages.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          productImages.length,
                              (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: currentImageIndex == index
                                  ? AppColor.goldAccent
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Horizontal Image Gallery
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Show the full-screen image viewer when an image is tapped.
                      _showFullScreenImage(index);
                    },
                    child: Container(
                      width: 80,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 24 : 12,
                        right: index == productImages.length - 1 ? 24 : 0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: currentImageIndex == index
                              ? AppColor.primaryColor
                              : AppColor.borderGray,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: productImages[index].startsWith('assets/')
                              ? AssetImage(productImages[index]) as ImageProvider
                              : productImages[index] == 'placeholder'
                                  ? AssetImage('assets/images/placeholder.png') as ImageProvider
                                  : NetworkImage(productImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price Section
                  Container(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColor.goldAccent, AppColor.earthBrown],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.verified, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Handcrafted',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Row(
                              children: [
                                Icon(Icons.star, color: AppColor.goldAccent, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  '4.8',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                  ),
                                ),
                                Text(
                                  ' (124)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                            fontFamily: 'PlayfairDisplay',
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              _extractPrice(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColor.successColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Free Shipping',
                                style: TextStyle(
                                  color: AppColor.successColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Size Selection
                  _buildSectionTitle(l10n, 'Select Size', Icons.straighten),
                  Container(
                    height: 60,
                    child: ListView.builder(
                      key: PageStorageKey('sizeList'), // Add key to preserve scroll position
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      itemCount: availableSizes.length,
                      itemBuilder: (context, index) {
                        final size = availableSizes[index];
                        final isSelected = selectedSize == size;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSize = size;
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
                              color: isSelected ? null : (isDark ? Color(0xFF2C2520) : AppColor.cardBackground),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : AppColor.borderGray,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : (isDark ? AppColor.goldAccent : AppColor.primaryColor),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24),

                  // Color Selection
                  _buildSectionTitle(l10n, 'Select Color', Icons.palette),
                  Container(
                    height: 80,
                    child: ListView.builder(
                      key: PageStorageKey('colorList'), // Add key to preserve scroll position
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      itemCount: availableColors.length,
                      itemBuilder: (context, index) {
                        final colorOption = availableColors[index];
                        final isSelected = selectedColor == colorOption['name'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = colorOption['name'];
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorOption['color'],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColor.goldAccent : AppColor.borderGray,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: colorOption['color'].withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? Icon(Icons.check, color: Colors.white, size: 24)
                                      : null,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  colorOption['name'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? (isDark ? AppColor.goldAccent : AppColor.primaryColor) : AppColor.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24),

                  // Quantity Selection
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.borderGray),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (selectedQuantity > 1) {
                                    setState(() {
                                      selectedQuantity--;
                                    });
                                  }
                                },
                                icon: Icon(Icons.remove, color: AppColor.primaryColor),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '$selectedQuantity',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedQuantity++;
                                  });
                                },
                                icon: Icon(Icons.add, color: AppColor.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Description
                  _buildSectionTitle(l10n, 'Description', Icons.description),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColor.grey,
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Features
                  _buildSectionTitle(l10n, 'Features', Icons.check_circle_outline),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildFeatureItem('100% Handmade Egyptian Craftsmanship', Icons.handyman),
                        _buildFeatureItem('Premium Quality Wool Material', Icons.verified),
                        _buildFeatureItem('Traditional Weaving Technique', Icons.architecture),
                        _buildFeatureItem('Easy to Clean & Maintain', Icons.cleaning_services),
                        _buildFeatureItem('Free Shipping on Orders Over \$500', Icons.local_shipping),
                      ],
                    ),
                  ),

                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2C2520) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Total Price
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _extractPrice(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12),

              // Add to Cart Button
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isAddingToCart ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColor.primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isAddingToCart
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black12,
      child: imageUrl.startsWith('assets/')
          ? Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : (imageUrl == 'placeholder'
              ? _buildPlaceholder()
              : Image.network(
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        }, imageUrl,
      )),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColor.backgroundcolor2,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: AppColor.grey,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(AppLocalizations l10n, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColor.successColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColor.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: productImages.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    child: Center(
                      child: productImages[index].startsWith('assets/')
                          ? Image.asset(productImages[index], fit: BoxFit.contain)
                          : (productImages[index] == 'placeholder'
                              ? Icon(Icons.image_outlined, size: 100, color: Colors.white54)
                              : Image.network(
                                  productImages[index],
                                  fit: BoxFit.contain,
                                )),
                    ),
                  );
                },
              ),
              SafeArea(
                child: Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}