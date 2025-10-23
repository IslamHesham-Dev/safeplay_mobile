import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// Child profile state management
class ChildProvider extends ChangeNotifier {
  ChildProvider(this._authService);

  static const _selectedChildKey = 'safeplay.parent.selected_child';

  final AuthService _authService;
  List<ChildProfile> _children = [];
  ChildProfile? _selectedChild;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ChildProfile> get children => _children;
  ChildProfile? get selectedChild => _selectedChild;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load children for parent
  Future<void> loadChildren(String parentId, {String? activeChildId}) async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      _children = await _authService.getChildrenForParent(parentId);

      ChildProfile? resolvedSelection;

      final persistedChildId =
          activeChildId ?? prefs.getString(_selectedChildKey);
      if (persistedChildId != null) {
        resolvedSelection = _findChildById(persistedChildId);
      }

      resolvedSelection ??=
          _selectedChild != null ? _findChildById(_selectedChild!.id) : null;

      resolvedSelection ??= _children.isNotEmpty ? _children.first : null;

      if (resolvedSelection != null) {
        _selectedChild = resolvedSelection;
        await _persistSelectedChild(resolvedSelection.id);
      } else {
        await _persistSelectedChild(null);
      }

      notifyListeners();
    } catch (error) {
      _setError(error.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new child
  Future<ChildProfile?> addChild(ChildProfile profile) async {
    _setLoading(true);
    _clearError();

    try {
      final newProfile = await _authService.createChildProfile(profile);
      _children.add(newProfile);
      notifyListeners();
      return newProfile;
    } catch (error) {
      _setError(error.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update child profile
  Future<bool> updateChild(ChildProfile profile) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateChildProfile(profile);
      final index = _children.indexWhere((c) => c.id == profile.id);
      if (index != -1) {
        _children[index] = profile;
      }
      if (_selectedChild?.id == profile.id) {
        _selectedChild = profile;
        await _persistSelectedChild(profile.id);
      }
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Select a child
  Future<void> selectChild(ChildProfile child) async {
    _selectedChild = child;
    await _persistSelectedChild(child.id);
    notifyListeners();
  }

  /// Deselect current child
  Future<void> deselectChild() async {
    _selectedChild = null;
    await _persistSelectedChild(null);
    notifyListeners();
  }

  /// Update child XP
  Future<void> addXP(String childId, int xp) async {
    final child = _children.firstWhere((c) => c.id == childId);
    final newXp = child.xp + xp;
    final newLevel = _calculateLevel(newXp);

    final updatedStats = child.stats.copyWith(
      totalPoints: newXp,
      level: newLevel,
    );

    final updatedChild = child.copyWith(stats: updatedStats);

    await updateChild(updatedChild);
  }

  /// Update child streak
  Future<void> updateStreak(String childId, int streakDays) async {
    final child = _children.firstWhere((c) => c.id == childId);
    final updatedStats = child.stats.copyWith(currentStreak: streakDays);
    final updatedChild = child.copyWith(stats: updatedStats);
    await updateChild(updatedChild);
  }

  /// Add achievement to child
  Future<void> addAchievement(String childId, String achievementId) async {
    final child = _children.firstWhere((c) => c.id == childId);
    if (!child.achievements.contains(achievementId)) {
      final updatedAchievements = [...child.achievements, achievementId];
      final updatedChild = child.copyWith(achievements: updatedAchievements);
      await updateChild(updatedChild);
    }
  }

  /// Set picture password for Junior Explorer
  Future<void> setPicturePassword(
      String childId, List<String> pictureSequence) async {
    print('[ChildProvider]: Setting picture password for child: $childId');
    print('[ChildProvider]: Picture sequence: $pictureSequence');

    _setLoading(true);
    _clearError();

    try {
      await _authService.setPicturePassword(childId, pictureSequence);
      print('[ChildProvider]: Picture password saved to database');

      // Reload children from database to get updated authData
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        print('[ChildProvider]: Reloading children from database...');
        await loadChildren(currentUser.id);
        print('[ChildProvider]: Children reloaded, checking auth setup...');

        // Check if the child now has auth setup
        final hasAuth = hasAuthSetup(childId);
        print('[ChildProvider]: After reload, child has auth setup: $hasAuth');
      }

      // Send email with credentials
      final child = _children.firstWhere((c) => c.id == childId);
      await _sendCredentialsEmail(child, 'emoji',
          pictureSequence: pictureSequence);
    } catch (error) {
      print('[ChildProvider]: Error setting picture password: $error');
      _setError(error.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Set picture + PIN for Bright Minds
  Future<void> setPicturePin(
      String childId, List<String> pictures, String pin) async {
    print('[ChildProvider]: Setting picture + PIN for child: $childId');
    print('[ChildProvider]: Pictures: $pictures, PIN: $pin');

    _setLoading(true);
    _clearError();

    try {
      await _authService.setPicturePin(childId, pictures, pin);
      print('[ChildProvider]: Picture + PIN saved to database');

      // Reload children from database to get updated authData
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        print('[ChildProvider]: Reloading children from database...');
        await loadChildren(currentUser.id);
        print('[ChildProvider]: Children reloaded, checking auth setup...');

        // Check if the child now has auth setup
        final hasAuth = hasAuthSetup(childId);
        print('[ChildProvider]: After reload, child has auth setup: $hasAuth');
      }

      // Send email with credentials
      final child = _children.firstWhere((c) => c.id == childId);
      await _sendCredentialsEmail(child, 'picture+pin',
          pictures: pictures, pin: pin);
    } catch (error) {
      print('[ChildProvider]: Error setting picture + PIN: $error');
      _setError(error.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a child profile
  Future<bool> deleteChild(String childId) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteChildProfile(childId);
      _children.removeWhere((c) => c.id == childId);

      // If the deleted child was selected, clear selection
      if (_selectedChild?.id == childId) {
        _selectedChild = _children.isNotEmpty ? _children.first : null;
        await _persistSelectedChild(_selectedChild?.id);
      }

      notifyListeners();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if child has authentication setup
  bool hasAuthSetup(String childId) {
    final child = _children.firstWhere((c) => c.id == childId,
        orElse: () => throw Exception('Child not found'));

    print(
        '[ChildProvider]: Checking auth setup for child ${child.name} (${childId})');
    print('[ChildProvider]: Child authData: ${child.authData}');

    // Check if authData exists and has the required fields
    final authData = child.authData;
    if (authData == null || authData.isEmpty) {
      print('[ChildProvider]: No authData found for child ${child.name}');
      return false;
    }

    // Check if authType is set (indicates authentication is configured)
    final hasAuth =
        authData['authType'] != null && authData['authType'].isNotEmpty;
    print(
        '[ChildProvider]: Child ${child.name} has auth setup: $hasAuth (authType: ${authData['authType']})');
    return hasAuth;
  }

  ChildProfile? _findChildById(String id) {
    try {
      return _children.firstWhere((child) => child.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistSelectedChild(String? childId) async {
    final prefs = await SharedPreferences.getInstance();
    if (childId == null) {
      await prefs.remove(_selectedChildKey);
    } else {
      await prefs.setString(_selectedChildKey, childId);
    }
  }

  /// Calculate level from XP
  int _calculateLevel(int xp) {
    // Simple level calculation: 100 XP per level
    return (xp / 100).floor() + 1;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  /// Send credentials email to parent
  Future<void> _sendCredentialsEmail(
    ChildProfile child,
    String authType, {
    List<String>? pictureSequence,
    List<String>? pictures,
    String? pin,
  }) async {
    try {
      // Get current parent's email
      final currentUser = await _authService.getCurrentUser();
      if (currentUser?.email == null) return;

      // Prepare credentials data
      final credentials = <String, dynamic>{};
      if (pictureSequence != null) {
        credentials['pictures'] = pictureSequence;
      }
      if (pictures != null) {
        credentials['pictures'] = pictures;
      }
      if (pin != null) {
        credentials['pin'] = pin;
      }

      // Call Cloud Function to send email
      await _authService.sendCredentialsEmail(
        to: currentUser!.email!,
        subject: 'SafePlay - ${child.name}\'s Login Credentials',
        childName: child.name,
        authType: authType,
        credentials: credentials,
      );
    } catch (error) {
      // Don't throw error for email failure, just log it
      print('Failed to send credentials email: $error');
    }
  }
}
