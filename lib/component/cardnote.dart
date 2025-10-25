import 'package:flutter/material.dart';
import 'package:naseej/utils/favorites_manager.dart';
import '../l10n/generated/app_localizations.dart';

class CardNote extends StatefulWidget {
  final void Function() onTap;
  final void Function()? onImageTap;
  final void Function()? onFavoriteChanged;
  final String noteId;
  final String title;
  final String content;
  final String? imageUrl;

  const CardNote({
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
  State<CardNote> createState() => _CardNoteState();
}

class _CardNoteState extends State<CardNote> with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _disposed = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    // Initialize favorite status safely
    _initializeFavoriteStatus();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeFavoriteStatus() {
    if (widget.noteId.isNotEmpty) {
      try {
        // Use the synchronous method that already exists
        isFavorite = FavoritesManager.isFavorite(widget.noteId);
      } catch (e) {
        print('Error initializing favorite status: $e');
        isFavorite = false;
      }
    }
  }

  @override
  void didUpdateWidget(CardNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update favorite status when widget rebuilds, regardless of noteId change
    if (!_isTogglingFavorite) {
      final newFavoriteStatus = FavoritesManager.isFavorite(widget.noteId);
      if (isFavorite != newFavoriteStatus) {
        setState(() {
          isFavorite = newFavoriteStatus;
        });
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
    final l10n = AppLocalizations.of(context);
    // Prevent multiple simultaneous toggles
    if (_isTogglingFavorite || _disposed || widget.noteId.isEmpty) return;

    _isTogglingFavorite = true;

    try {
      // Animate the heart immediately for responsive UI
      if (mounted && !_disposed) {
        _animationController.forward().then((_) {
          if (mounted && !_disposed) {
            _animationController.reverse();
          }
        });

        // Update UI state immediately for better UX
        final newFavoriteState = !isFavorite;
        setState(() {
          isFavorite = newFavoriteState;
        });

        // Perform the actual toggle operation
        final success = await FavoritesManager.toggleFavorite(widget.noteId);

        if (!success) {
          // Revert the UI change if the operation failed
          if (mounted && !_disposed) {
            setState(() {
              isFavorite = !newFavoriteState;
            });
          }
          _showErrorMessage("Failed to update favorite status");
        } else {
          // Show success feedback
          _showSuccessMessage(
            newFavoriteState ? l10n.addedToFavorites :l10n.removedFromFavorites ,
            newFavoriteState,
          );

          // Notify parent widget with a delay to prevent immediate rebuilds
          if (widget.onFavoriteChanged != null) {
            Future.delayed(Duration(milliseconds: 100), () {
              if (!_disposed) {
                widget.onFavoriteChanged!();
              }
            });
          }
        }
      }
    } catch (e) {
      // Handle any errors gracefully
      if (mounted && !_disposed) {
        setState(() {
          // Revert to original state
          _initializeFavoriteStatus();
        });
      }
      _showErrorMessage("Error updating favorite status");
    } finally {
      _isTogglingFavorite = false;
    }
  }

  void _showSuccessMessage(String message, bool isFav) {
    if (mounted && !_disposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isFav ? Colors.green : Colors.grey[600],
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted && !_disposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Prevent building if disposed
    if (_disposed) return SizedBox.shrink();

    // Add null safety checks for required fields with fallbacks
    final safeTitle = widget.title.trim().isEmpty ? l10n.unknown : widget.title;
    final safeContent = widget.content.trim().isEmpty ? l10n.noteContent : widget.content;
    final safeNoteId = widget.noteId.trim().isEmpty ?l10n.unknown : widget.noteId;

    return Card(
      key: ValueKey('card_note_$safeNoteId'),
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      child: IntrinsicHeight( // Ensures consistent height
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section with Upload Functionality
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(8),
                child: InkWell(
                  onTap: widget.onImageTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]!
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Image Display
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImageWidget(),
                        ),

                        // Upload/Edit Overlay - only show if onImageTap is provided
                        if (widget.onImageTap != null)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _hasImage() ? Icons.edit : Icons.add_a_photo,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content Section (Clickable)
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        safeTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        safeContent,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Favorite Icon and Arrow Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Favorite Icon
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: InkWell(
                          onTap: _toggleFavorite,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.pink
                                  : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[500]
                                  : Colors.grey[400]),
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8),

                  // // Arrow Icon (Clickable)
                  // InkWell(
                  //   onTap: widget.onTap,
                  //   borderRadius: BorderRadius.circular(20),
                  //   child: Container(
                  //     padding: EdgeInsets.all(8),
                  //     child: Icon(
                  //       Icons.arrow_forward_ios,
                  //       size: 16,
                  //       color: Theme.of(context).brightness == Brightness.dark
                  //           ? Colors.grey[500]
                  //           : Colors.grey[400],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasImage() {
    return widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
  }

  Widget _buildImageWidget() {
    if (_hasImage()) {
      return Image.network(
        widget.imageUrl!,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 24,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[500],
          ),
          SizedBox(height: 2),
          Text(
            widget.onImageTap != null ?  l10n.addImage: l10n.noImage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}