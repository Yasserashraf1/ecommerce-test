import 'package:flutter/material.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/core/constant/color.dart';
import '../l10n/generated/app_localizations.dart';

class ProductCard extends StatefulWidget {
  final void Function() onTap;
  final void Function()? onImageTap;
  final void Function()? onFavoriteChanged;
  final String noteId;
  final String title;
  final String content;
  final String? imageUrl;

  const ProductCard({
    Key? key,
    required this.onTap,
    this.onImageTap,
    this.onFavoriteChanged,
    required this.noteId,
    required this.title,
    required this.content,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late AnimationController _animationController;
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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isTogglingFavorite && widget.noteId.isNotEmpty) {
      final newStatus = FavoritesManager.isFavorite(widget.noteId);
      if (isFavorite != newStatus && mounted) {
        setState(() => isFavorite = newStatus);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (_disposed) return SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.12),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section (60%)
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor2,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                          ? Image.network(
                        widget.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColor.primaryColor,
                              strokeWidth: 3,
                            ),
                          );
                        },
                      )
                          : _buildPlaceholder(isDark),
                    ),
                  ),
                  // Premium Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.goldAccent, AppColor.bronzeAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Premium', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.pink : AppColor.grey, size: 18),
                      ),
                    ),
                  ),
                  // Edit Button
                  if (widget.onImageTap != null)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: widget.onImageTap,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_a_photo, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content Section (40%)
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title.trim().isEmpty ? 'Handmade Carpet' : widget.title,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColor.goldAccent : AppColor.primaryColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Text(widget.content.trim().isEmpty ? 'Traditional design' : widget.content,
                              style: TextStyle(fontSize: 11, color: AppColor.grey, height: 1.3),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_getPrice(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColor.goldAccent : AppColor.primaryColor)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColor.primaryColor, AppColor.secondColor]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Buy', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
          colors: isDark ? [Color(0xFF2C2520), Color(0xFF1A1614)] : [AppColor.backgroundcolor2, AppColor.backgroundcolor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 40, color: AppColor.primaryColor.withOpacity(0.4)),
          SizedBox(height: 6),
          Text('Add Image', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColor.primaryColor.withOpacity(0.5), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}