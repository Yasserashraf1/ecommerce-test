import 'package:flutter/material.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/main.dart';
import 'package:naseej/utils/favorites_manager.dart';
import 'package:naseej/component/cardnote.dart';
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
  bool _hasChanges = false; // Track if favorites were modified

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
      // Ensure FavoritesManager is initialized
      if (!FavoritesManager.isInitialized) {
        await FavoritesManager.initialize();
      }

      // Get all user notes
      var response = await crud.postRequest(viewNoteLink, {
        "userId": sharedPref.getString("user_id")!
      });

      if (response["status"] == "success" && response["data"] != null) {
        List<dynamic> allNotes = response["data"];

        // Get favorite note IDs using async method
        List<String> favoriteIds = await FavoritesManager.getFavoriteIds();

        // Filter notes to only include favorites
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
    _hasChanges = true; // Mark that changes occurred

    // Reload favorites when a note's favorite status changes with a small delay
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _loadFavoriteNotes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Return the result when navigating back
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.favorites),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(_hasChanges);
            },
          ),
          actions: [
            // Show favorites count
            if (favoriteNotes.isNotEmpty)
              Center(
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "${favoriteNotes.length}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(error!, style: TextStyle(fontSize: 16, color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavoriteNotes,
              child: Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (favoriteNotes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFavoriteNotes,
      child: ListView.builder(
        itemCount: favoriteNotes.length,
        itemBuilder: (context, index) {
          final note = favoriteNotes[index];
          String? imageUrl;

          if (note['note_image'] != null &&
              note['note_image'].toString().isNotEmpty) {
            imageUrl = imageBaseUrl + note['note_image'];
          }

          return CardNote(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated heart icon
          TweenAnimationBuilder<double>(
            duration: Duration(seconds: 2),
            tween: Tween<double>(begin: 0.8, end: 1.1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
              );
            },
            onEnd: () {
              // Optional: Add continuous animation
            },
          ),
          SizedBox(height: 24),
          Text(
            l10n.noFavoritesYet,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.markFavorites,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[500],
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 30),

          // Instruction card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.pink,
                  size: 24,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    l10n.noFavoritesDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}