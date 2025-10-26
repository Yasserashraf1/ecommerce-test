import 'package:flutter/material.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/core/constant/color.dart';
import '../l10n/generated/app_localizations.dart';

class ProductCard extends StatefulWidget {
  final void Function() onTap;
  final void Function()? onFavoriteChanged;
  final String noteId;
  final String title;
  final String content;
  final String? imageAsset;

  const ProductCard({
    Key? key,
    required this.onTap,
    this.onFavoriteChanged,
    required this.noteId,
    required this.title,
    required this.content,
    this.imageAsset,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  bool _disposed = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.noteId.isNotEmpty) {
      try {
        isFavorite = FavoritesManager.isFavorite(widget.noteId);
      } catch (e) {
        isFavorite = false;
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite || _disposed || widget.noteId.isEmpty) return;
    _isTogglingFavorite = true;

    try {
      if (mounted && !_disposed) {
        final newState = !isFavorite;
        setState(() => isFavorite = newState);
        await FavoritesManager.toggleFavorite(widget.noteId);
        if (widget.onFavoriteChanged != null) {
          Future.delayed(Duration(milliseconds: 100), widget.onFavoriteChanged!);
        }
      }
    } finally {
      _isTogglingFavorite = false;
    }
  }

  String _getPrice() {
    final priceRegex = RegExp(r'\$?\d+\.?\d*');
    final match = priceRegex.firstMatch(widget.content);
    if (match != null) {
      var price = match.group(0);
      return price!.startsWith('\$') ? price : '\$$price';
    }
    return '\$299';
  }

  String _getSize() {
    final sizeRegex = RegExp(r'\d+\s?[x×]\s?\d+\s?(ft|m|meter|feet)');
    final match = sizeRegex.firstMatch(widget.content);
    if (match != null) {
      return match.group(0)!;
    }
    return '5x8 ft';
  }

  String _getProductName() {
    return widget.title.trim().isEmpty ? 'Traditional Carpet' : widget.title;
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 165,
        height: 240,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Image Section - EVEN LARGER with minimized bottom space
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                width: double.infinity,
                height: 150, // Increased from 140 to 150
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor2,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: widget.imageAsset != null && widget.imageAsset!.isNotEmpty
                      ? Image.asset(
                    widget.imageAsset!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                  )
                      : _buildPlaceholder(isDark),
                ),
              ),
            ),

            // Content Section - MINIMIZED bottom space
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 82, // Reduced from 92 to 82 (more space for image)
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6), // Reduced bottom padding from 10 to 6
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name - LARGER TEXT
                    SizedBox(
                      height: 20,
                      child: Text(
                        _getProductName(),
                        style: TextStyle(
                          fontSize: 14, // Increased from 13 to 14
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          fontFamily: 'PlayfairDisplay',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Size Information - LARGER TEXT
                    SizedBox(
                      height: 18,
                      child: Row(
                        children: [
                          Icon(
                            Icons.aspect_ratio,
                            size: 12,
                            color: isDark ? AppColor.desertSand : AppColor.grey2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getSize(),
                            style: TextStyle(
                              fontSize: 12, // Increased from 11 to 12
                              color: isDark ? AppColor.desertSand : AppColor.grey2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price and Add to Cart - LARGER TEXT
                    SizedBox(
                      height: 30, // Slightly reduced to fit new layout
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price - LARGER TEXT
                          Text(
                            _getPrice(),
                            style: TextStyle(
                              fontSize: 16, // Increased from 14 to 16
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                            ),
                          ),

                          // Add to Cart Button - LARGER TEXT
                          Container(
                            width: 80,
                            height: 26, // Slightly reduced to fit
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColor.primaryColor, AppColor.secondColor],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11, // Increased from 10 to 11
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Favorite Button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColor.primaryColor : AppColor.grey,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF2C2520), Color(0xFF1A1614)]
              : [AppColor.backgroundcolor2, AppColor.backgroundcolor],
        ),
      ),
      child: Icon(
        Icons.photo_outlined,
        size: 45, // Larger for bigger image area
        color: AppColor.primaryColor.withOpacity(0.3),
      ),
    );
  }
}