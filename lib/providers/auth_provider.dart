import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/user_type.dart';
import '../services/auth_service.dart';

/// Authentication state management
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _init();
  }

  static const _userProfileKey = 'safeplay.current_user';
  static const _childProfileKey = 'safeplay.current_child';
  static const _userIdKey = 'user_id';
  static const _childIdKey = 'child_id';

  final AuthService _authService;

  UserProfile? _currentUser;
  ChildProfile? _currentChild;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get currentUser => _currentUser;
  ChildProfile? get currentChild => _currentChild;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasParentSession => _currentUser?.userType == UserType.parent;
  bool get hasChildSession => _currentUser == null && _currentChild != null;
  bool get hasTeacherSession => _currentUser?.userType == UserType.teacher;
  bool get isAuthenticated =>
      hasParentSession || hasChildSession || hasTeacherSession;
  bool get isChildAuthenticated => hasChildSession;

  /// Initialize auth state from storage
  Future<void> _init() async {
    _setLoading(true);
    try {
      print('🔐 AuthProvider: Initializing authentication state...');

      final prefs = await SharedPreferences.getInstance();

      final cachedUserJson = prefs.getString(_userProfileKey);
      if (cachedUserJson != null) {
        try {
          final decoded = jsonDecode(cachedUserJson) as Map<String, dynamic>;
          _currentUser = UserProfile.fromJson(decoded);
          print(
              '🔐 AuthProvider: Restored user from cache: ${_currentUser?.name}');
        } catch (error, stackTrace) {
          debugPrint('Failed to decode stored user profile: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      final cachedChildJson = prefs.getString(_childProfileKey);
      if (cachedChildJson != null) {
        try {
          final decoded = jsonDecode(cachedChildJson) as Map<String, dynamic>;
          _currentChild = ChildProfile.fromJson(decoded);
          print(
              '🔐 AuthProvider: Restored child from cache: ${_currentChild?.name}');
        } catch (error, stackTrace) {
          debugPrint('Failed to decode stored child profile: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      // Check Firebase Auth state
      print('🔐 AuthProvider: Checking Firebase Auth state...');
      final remoteUser = await _authService.getCurrentUser();
      if (remoteUser != null) {
        print(
            '🔐 AuthProvider: Found authenticated user in Firebase: ${remoteUser.name}');
        _currentUser = remoteUser;
        _currentChild = null;
        await _persistCurrentUser(remoteUser);
        await _clearPersistedChild();
        await _saveUserId(remoteUser.id);
        print('🔐 AuthProvider: User session restored successfully');
      } else {
        print('🔐 AuthProvider: No authenticated user in Firebase');
        final savedChildId = prefs.getString(_childIdKey) ?? _currentChild?.id;
        if (savedChildId != null) {
          try {
            print(
                '🔐 AuthProvider: Attempting to restore child session: $savedChildId');
            final childProfile =
                await _authService.getChildProfile(savedChildId);
            if (childProfile != null) {
              _currentChild = childProfile;
              await _persistCurrentChild(childProfile);
              print('🔐 AuthProvider: Child session restored successfully');
            }
          } catch (error, stackTrace) {
            debugPrint('Error restoring child session: $error');
            debugPrintStack(stackTrace: stackTrace);
          }
        }
      }

      print(
          '🔐 AuthProvider: Initialization complete - hasParent: $hasParentSession, hasChild: $hasChildSession');
    } catch (error, stackTrace) {
      debugPrint('Error initializing auth: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _setLoading(false, notify: false);
      notifyListeners();
    }
  }

  /// Sign in with email and password (for parents)
  Future<bool> signInWithEmail(String email, String password) async {
    print('dY"? AuthProvider: Starting signInWithEmail for $email');
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithEmail(email, password);
      print('dY"? AuthProvider: Got user from service: ${user?.name}');
      _currentUser = user;
      if (user != null) {
        _currentChild = null;
        print('AuthProvider: notifying listeners of parent session');
        notifyListeners();

        try {
          await _persistCurrentUser(user);
          await _clearPersistedChild();
          await _saveUserId(user.id);
          print('AuthProvider: Parent session persisted locally');
        } catch (error, stackTrace) {
          debugPrint(
              'AuthProvider: Failed to persist parent session: ${error.toString()}');
          debugPrintStack(stackTrace: stackTrace);
        }

        // Add a small delay to ensure state is fully updated
        await Future.delayed(const Duration(milliseconds: 50));
        print('dY"? AuthProvider: Login successful, returning true');
        return true;
      }

      print('dY"? AuthProvider: User is null, login failed');
      _setError('Failed to sign in');
      return false;
    } catch (error) {
      print('dY"? AuthProvider: Login error: $error');
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email and password (for parents)
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    print('🔐 AuthProvider: Starting signup for $email');
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      print('🔐 AuthProvider: Signup service returned: ${user?.name}');
      _currentUser = user;

      if (user != null) {
        print('🔐 AuthProvider: User created successfully, persisting...');
        _currentChild = null;
        await _persistCurrentUser(user);
        await _clearPersistedChild();
        await _saveUserId(user.id);
        print('🔐 AuthProvider: User persisted, notifying listeners...');
        notifyListeners();
        print('🔐 AuthProvider: Signup completed successfully');
        return true;
      }

      print('🔐 AuthProvider: Signup failed - no user returned');
      _setError('Failed to sign up');
      return false;
    } catch (error) {
      print('🔐 AuthProvider: Signup error: $error');
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up as teacher
  Future<bool> signUpTeacher({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.signUpTeacher(
        email: email,
        password: password,
        name: name,
      );
      _currentUser = user;
      if (user != null) {
        _currentChild = null;
        await _persistCurrentUser(user);
        await _clearPersistedChild();
        await _saveUserId(user.id);
        notifyListeners();
        return true;
      }
      _setError('Failed to sign up teacher');
      return false;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in child with picture password (Junior Explorer)
  Future<bool> signInChildWithPicturePassword(
    String childId,
    List<String> pictureSequence,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final child = await _authService.signInChildWithPicturePassword(
        childId,
        pictureSequence,
      );
      _currentChild = child;
      if (child != null) {
        _currentUser = null;
        await _clearPersistedUser();
        await _persistCurrentChild(child);
        notifyListeners();
        return true;
      }

      _setError('Incorrect picture password');
      return false;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in child with picture + PIN (Bright Minds)
  Future<bool> signInChildWithPicturePin(
    String childId,
    List<String> pictures,
    String pin,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final child = await _authService.signInChildWithPicturePin(
        childId,
        pictures,
        pin,
      );
      _currentChild = child;
      if (child != null) {
        _currentUser = null;
        await _clearPersistedUser();
        await _persistCurrentChild(child);
        notifyListeners();
        return true;
      }

      _setError('Incorrect credentials');
      return false;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with biometric authentication
  Future<bool> signInWithBiometric() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithBiometric();
      _currentUser = user;
      if (user != null) {
        _currentChild = null;
        await _persistCurrentUser(user);
        await _clearPersistedChild();
        await _saveUserId(user.id);
        notifyListeners();
        return true;
      }

      _setError('Biometric authentication failed');
      return false;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if email is verified
  bool isEmailVerified() {
    return _authService.isEmailVerified();
  }

  /// Reload user to get latest email verification status
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      // Refresh current user data
      if (_currentUser != null) {
        final updatedUser = await _authService.getCurrentUser();
        if (updatedUser != null) {
          _currentUser = updatedUser;
          await _persistCurrentUser(updatedUser);
          notifyListeners();
        }
      }
    } catch (error) {
      _setError(error.toString());
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password (requires reauthentication)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user account and all associated data
  Future<bool> deleteAccount({
    required String currentPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount(currentPassword: currentPassword);
      // Clear local state
      _currentUser = null;
      _currentChild = null;
      await _clearPersistedUser();
      await _clearPersistedChild();
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _currentChild = null;
      await _clearPersistedUser();
      await _clearPersistedChild();
      notifyListeners();
    } catch (error) {
      _setError(error.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Select a child profile by ID and persist selection
  Future<void> selectChild(String childId) async {
    _setLoading(true);
    _clearError();

    try {
      final profile = await _authService.getChildProfile(childId);
      if (profile != null) {
        await setActiveChildProfile(profile);
      } else {
        _setError('Child profile not found');
      }
    } catch (error) {
      _setError(error.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Set the active child profile in memory (optionally persisting selection)
  Future<void> setActiveChildProfile(
    ChildProfile child, {
    bool persist = true,
  }) async {
    _currentChild = child;
    if (persist) {
      await _persistCurrentChild(child);
    }
    notifyListeners();
  }

  /// Update child profile
  Future<void> updateChildProfile(ChildProfile profile) async {
    try {
      await _authService.updateChildProfile(profile);
      if (_currentChild?.id == profile.id) {
        _currentChild = profile;
        await _persistCurrentChild(profile);
        notifyListeners();
      }
    } catch (error) {
      _setError(error.toString());
    }
  }

  /// Set demo child (bypasses authentication for testing)
  Future<void> setDemoChild(ChildProfile child) async {
    _currentChild = child;
    _currentUser = null;
    await _clearPersistedUser();
    await _persistCurrentChild(child);
    notifyListeners();
  }

  Future<void> _persistCurrentUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(user.toJson()));
  }

  Future<void> _persistCurrentChild(ChildProfile child) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_childProfileKey, jsonEncode(child.toJson()));
    await _saveChildId(child.id);
  }

  Future<void> _clearPersistedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await _saveUserId(null);
  }

  Future<void> _clearPersistedChild() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_childProfileKey);
    await _saveChildId(null);
  }

  /// Save user ID to storage
  Future<void> _saveUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_userIdKey);
    } else {
      await prefs.setString(_userIdKey, userId);
    }
  }

  /// Save child ID to storage
  Future<void> _saveChildId(String? childId) async {
    final prefs = await SharedPreferences.getInstance();
    if (childId == null) {
      await prefs.remove(_childIdKey);
    } else {
      await prefs.setString(_childIdKey, childId);
    }
  }

  /// Set loading state
  void _setLoading(bool loading, {bool notify = true}) {
    _isLoading = loading;
    if (notify) {
      notifyListeners();
    }
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
}
