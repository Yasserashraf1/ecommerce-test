import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _favoritesKeyPrefix = 'favorites_user_';
  static SharedPreferences? _prefs;
  static String? _currentUserId;
  static bool _initialized = false;

  static Future<void> initialize() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
        _initialized = true;
        print('FavoritesManager initialized successfully');
      }
    } catch (e) {
      print('Error initializing FavoritesManager: $e');
      _initialized = false;
    }
  }

  static Future<void> _ensureInitialized() async {
    if (!_initialized || _prefs == null) {
      await initialize();
    }
  }

  static void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  static String _getUserFavoritesKey() {
    if (_currentUserId == null) return 'favorites_default';
    return '$_favoritesKeyPrefix$_currentUserId';
  }

  // Get list of favorite note IDs for current user (async version for consistency)
  static Future<List<String>> getFavoriteIds() async {
    await _ensureInitialized();
    if (_prefs == null || !_initialized) {
      print('FavoritesManager not initialized, returning empty list');
      return [];
    }

    try {
      final favoritesJson = _prefs!.getString(_getUserFavoritesKey());
      if (favoritesJson == null) return [];

      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      return favoritesList.map((id) => id.toString()).toList();
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return [];
    }
  }

  // Synchronous version for immediate UI updates
  static List<String> getFavoriteIdsSync() {
    if (_prefs == null || !_initialized) {
      print('FavoritesManager not initialized, returning empty list');
      return [];
    }

    try {
      final favoritesJson = _prefs!.getString(_getUserFavoritesKey());
      if (favoritesJson == null) return [];

      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      return favoritesList.map((id) => id.toString()).toList();
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return [];
    }
  }

  // Add note to favorites
  static Future<bool> addToFavorites(String noteId) async {
    await _ensureInitialized();
    if (_prefs == null) return false;

    try {
      final favorites = getFavoriteIdsSync();
      if (!favorites.contains(noteId)) {
        favorites.add(noteId);
        final favoritesJson = jsonEncode(favorites);
        bool result = await _prefs!.setString(_getUserFavoritesKey(), favoritesJson);
        print('Added to favorites: $noteId, success: $result');
        return result;
      }
      return true; // Already in favorites
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove note from favorites
  static Future<bool> removeFromFavorites(String noteId) async {
    await _ensureInitialized();
    if (_prefs == null) return false;

    try {
      final favorites = getFavoriteIdsSync();
      if (favorites.contains(noteId)) {
        favorites.remove(noteId);
        final favoritesJson = jsonEncode(favorites);
        bool result = await _prefs!.setString(_getUserFavoritesKey(), favoritesJson);
        print('Removed from favorites: $noteId, success: $result');
        return result;
      }
      return true; // Not in favorites
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Check if note is favorite (synchronous for immediate UI updates)
  static bool isFavorite(String noteId) {
    if (_prefs == null || !_initialized) {
      print('FavoritesManager not initialized in isFavorite');
      return false;
    }

    try {
      final favorites = getFavoriteIdsSync();
      return favorites.contains(noteId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(String noteId) async {
    await _ensureInitialized();
    if (_prefs == null) return false;

    try {
      final isCurrentlyFavorite = isFavorite(noteId);
      print('Toggling favorite for $noteId, currently: $isCurrentlyFavorite');

      if (isCurrentlyFavorite) {
        return await removeFromFavorites(noteId);
      } else {
        return await addToFavorites(noteId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Get count of favorites
  static int getFavoritesCount() {
    final favorites = getFavoriteIdsSync();
    return favorites.length;
  }

  // Clear all favorites for current user
  static Future<bool> clearAllFavorites() async {
    await _ensureInitialized();
    if (_prefs == null) return false;

    try {
      return await _prefs!.remove(_getUserFavoritesKey());
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  // Clear user preferences on logout
  static Future<void> clearUserPreferences() async {
    await _ensureInitialized();
    if (_currentUserId != null && _prefs != null) {
      try {
        await _prefs!.remove(_getUserFavoritesKey());
      } catch (e) {
        print('Error clearing user preferences: $e');
      }
      _currentUserId = null;
    }
  }

  // Check if FavoritesManager is properly initialized
  static bool get isInitialized => _initialized && _prefs != null;
}