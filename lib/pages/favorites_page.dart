import 'package:flutter/material.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/main.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/component/product_card.dart';
import 'package:naseej/operations/notedetailpage.dart';
import '../l10n/generated/app_localizations.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Crud crud = Crud();
  List<Map<String, dynamic>> favoriteNotes = [];
  bool isLoading = true;
  String? error;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteNotes();
  }

  Future<void> _loadFavoriteNotes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      if (!FavoritesManager.isInitialized) {
        await FavoritesManager.initialize();
      }

      var response = await crud.postRequest(viewNoteLink, {
        "userId": sharedPref.getString("user_id")!
      });

      if (response["status"] == "success" && response["data"] != null) {
        List<dynamic> allNotes = response["data"];
        List<String> favoriteIds = await FavoritesManager.getFavoriteIds();

        List<Map<String, dynamic>> filteredFavorites = [];
        for (var note in allNotes) {
          String noteId = note['note_id'].toString();
          if (favoriteIds.contains(noteId)) {
            filteredFavorites.add(Map<String, dynamic>.from(note));
          }
        }

        if (mounted) {
          setState(() {
            favoriteNotes = filteredFavorites;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            favoriteNotes = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading favorite notes: $e");
      if (mounted) {
        setState(() {
          favoriteNotes = [];
          isLoading = false;
          error = "Error loading favorites: ${e.toString()}";
        });
      }
    }
  }

  void _onFavoriteChanged() {
    _hasChanges = true;
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _loadFavoriteNotes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
        appBar: AppBar(
          title: Text(l10n.favorites),
          backgroundColor: AppColor.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(_hasChanges);
            },
          ),
          actions: [
            if (favoriteNotes.isNotEmpty)
              Center(
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.goldAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.goldAccent.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "${favoriteNotes.length}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColor.primaryColor,
          strokeWidth: 3,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
              SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColor.warningColor),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFavoriteNotes,
                icon: Icon(Icons.refresh),
                label: Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
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

    if (favoriteNotes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFavoriteNotes,
      color: AppColor.primaryColor,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: favoriteNotes.length,
        itemBuilder: (context, index) {
          final note = favoriteNotes[index];
          String? imageUrl;

          if (note['note_image'] != null &&
              note['note_image'].toString().isNotEmpty) {
            imageUrl = imageBaseUrl + note['note_image'];
          }

          return ProductCard(
            key: ValueKey('favorite_note_${note['note_id']}_$index'),
            noteId: note['note_id'].toString(),
            onTap: () async {
              String? fullImageUrl;
              if (note['note_image'] != null &&
                  note['note_image'].toString().isNotEmpty) {
                fullImageUrl = imageBaseUrl + note['note_image'];
              }

              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NoteDetailPage(
                    noteId: note['note_id'].toString(),
                    title: note['note_title'] ?? 'Untitled',
                    content: note['note_content'] ?? '',
                    imageUrl: fullImageUrl,
                  ),
                ),
              );

              if (result == true) {
                _hasChanges = true;
                _loadFavoriteNotes();
              }
            },
            onFavoriteChanged: _onFavoriteChanged,
            title: note['note_title']?.toString() ?? 'Untitled',
            content: note['note_content']?.toString() ?? '',
            imageUrl: imageUrl,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated heart icon
              TweenAnimationBuilder<double>(
                duration: Duration(seconds: 2),
                tween: Tween<double>(begin: 0.8, end: 1.1),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppColor.cardBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.pink.withOpacity(0.6),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 32),
              Text(
                l10n.noFavoritesYet,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.markFavorites,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.grey,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Instruction card
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.withOpacity(0.1),
                      AppColor.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.pink.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.noFavoritesDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Back to Notes Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(_hasChanges);
                },
                icon: Icon(Icons.arrow_back),
                label: Text(l10n.backToNotes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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