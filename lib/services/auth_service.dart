import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart'; // Removed to fix build issues
import 'package:firebase_core/firebase_core.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user_profile.dart';
import 'local_auth_store.dart';
import '../models/user_type.dart';

/// Authentication service handling all authentication methods
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final LocalAuthStore _localAuthStore = LocalAuthStore();

  // Collections
  static const String usersCollection = 'users';
  static const String childrenCollection = 'children';

  /// Get current authenticated user
  Future<UserProfile?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) return null;

      return UserProfile.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Sign in with email and password
  Future<UserProfile?> signInWithEmail(String email, String password) async {
    try {
      print('[AuthService]: Attempting to sign in with email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user ?? _auth.currentUser;
      print(
          '[AuthService]: Firebase auth successful, user ID: ${firebaseUser?.uid}');
      if (firebaseUser == null) {
        print('[AuthService]: No user returned from Firebase');
        return null;
      }

      return await _loadParentProfile(
        firebaseUser: firebaseUser,
        fallbackEmail: email,
      );
    } on FirebaseAuthException catch (authError) {
      print('[AuthService]: Firebase auth error: ${authError.code}');
      throw authError;
    } on TypeError catch (typeError, stackTrace) {
      final message = typeError.toString();
      if (message.contains('PigeonUserDetails')) {
        print(
            '[AuthService]: Detected firebase_auth result casting issue: ${message}');
        final fallbackUser = _auth.currentUser;
        if (fallbackUser != null) {
          print(
              '[AuthService]: Attempting recovery using currentUser fallback...');
          try {
            return await _loadParentProfile(
              firebaseUser: fallbackUser,
              fallbackEmail: email,
            );
          } catch (recoveryError, recoveryStack) {
            print('[AuthService]: Recovery attempt failed: ${recoveryError}');
            print('[AuthService]: Recovery stack trace: ${recoveryStack}');
          }
        }
      }
      print('[AuthService]: Type error during signInWithEmail: ${typeError}');
      print('[AuthService]: Stack trace: ${stackTrace}');
      rethrow;
    } catch (e, stackTrace) {
      print('[AuthService]: Error signing in: ${e}');
      print('[AuthService]: Stack trace: ${stackTrace}');
      rethrow;
    }
  }

  Future<UserProfile?> _loadParentProfile({
    required User firebaseUser,
    required String fallbackEmail,
  }) async {
    print('[AuthService]: Getting user document from Firestore...');
    final docRef = _firestore.collection(usersCollection).doc(firebaseUser.uid);
    var doc = await docRef.get();
    print('[AuthService]: Firestore document retrieved, exists: ${doc.exists}');

    if (!doc.exists) {
      print(
          '[AuthService]: No user profile in Firestore, creating default profile...');
      try {
        final defaultProfile = _buildDefaultParentProfile(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? fallbackEmail,
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
        );
        print('[AuthService]: Default profile data: ${defaultProfile}');
        await docRef.set(defaultProfile, SetOptions(merge: true));
        print('[AuthService]: Default profile created successfully');
        doc = await docRef.get();
      } catch (e) {
        print('[AuthService]: Error creating default profile: ${e}');
        rethrow;
      }
    } else {
      print('[AuthService]: User profile exists, normalizing...');
      try {
        final docData = doc.data() ?? <String, dynamic>{};
        print('[AuthService]: Existing document data: ${docData}');
        final updates = _normalizeParentProfile(
          docData,
          firebaseUser: firebaseUser,
          fallbackEmail: fallbackEmail,
        );
        if (updates.isNotEmpty) {
          print(
              '[AuthService]: Normalizing parent profile with updates: ${updates}');
          await docRef.set(updates, SetOptions(merge: true));
          doc = await docRef.get();
        }
      } catch (e) {
        print('[AuthService]: Error normalizing profile: ${e}');
        rethrow;
      }
    }

    print('[AuthService]: Firestore document exists: ${doc.exists}');
    if (!doc.exists) {
      print('[AuthService]: Failed to create parent profile in Firestore');
      return null;
    }

    final docData = doc.data()!;
    print('[AuthService]: Document data: ${docData}');

    try {
      print('[AuthService]: Creating UserProfile from JSON...');
      final profile = UserProfile.fromJson({
        'id': doc.id,
        ...docData,
      });

      print(
          '[AuthService]: Created user profile: ${profile.name} (${profile.userType})');

      await _updateLastLogin(firebaseUser.uid);

      return profile;
    } catch (e, stackTrace) {
      print('[AuthService]: Error creating UserProfile: ${e}');
      print('[AuthService]: Stack trace: ${stackTrace}');
      rethrow;
    }
  }

  // Removed unused _trySignInWithLocalAccount due to build warnings

  // Removed unused _shouldAttemptLocalFallback to resolve warnings

  UserProfile _buildLocalUserProfile(Map<String, dynamic> account) {
    final createdAtString = account['createdAt'] as String?;
    final lastLoginString = account['lastLoginAt'] as String?;
    final email = account['email']?.toString() ?? '';
    final name = (account['name'] as String?)?.trim();

    return UserProfile(
      id: account['id']?.toString() ?? 'local-$email',
      name: (name != null && name.isNotEmpty)
          ? name
          : _deriveNameFromEmail(email),
      email: email.isEmpty ? null : email,
      userType: UserType.parent,
      createdAt: createdAtString != null
          ? DateTime.tryParse(createdAtString) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: lastLoginString != null
          ? DateTime.tryParse(lastLoginString)
          : DateTime.now(),
      metadata: <String, dynamic>{
        'source': 'local',
        'localAccount': true,
      },
    );
  }

  Future<UserProfile> _signUpLocalAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final account = await _localAuthStore.createAccount(
        email: email,
        password: password,
        name: name,
      );
      print('[AuthService]: Created local fallback account for $email');
      final profile = _buildLocalUserProfile(account);
      await _updateLastLogin(profile.id);
      return profile;
    } on LocalAuthException catch (localError) {
      if (localError.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'An account with this email already exists on this device.',
        );
      }
      rethrow;
    }
  }

  bool _shouldFallbackToLocalOnSignup(Object error) {
    if (error is FirebaseAuthException) {
      const allowedCodes = {
        'network-request-failed',
        'internal-error',
        'unknown',
        'app-not-authorized',
      };
      return allowedCodes.contains(error.code);
    }
    return error is FirebaseException ||
        error is PlatformException ||
        error is SocketException;
  }

  Map<String, dynamic> _buildDefaultParentProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) {
    final timestamp = FieldValue.serverTimestamp();
    final resolvedName = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : _deriveNameFromEmail(email);

    return {
      'uid': uid,
      'displayName': resolvedName,
      'email': email,
      'role': UserType.parent.name,
      'userType': UserType.parent.name,
      'photoURL': photoUrl,
      'children': <String>[],
      'preferences': {
        'notifications': true,
        'emailReports': true,
      },
      'metadata': <String, dynamic>{},
      'createdAt': timestamp,
      'updatedAt': timestamp,
      'lastLoginAt': timestamp,
      'lastLogin': timestamp,
    };
  }

  Map<String, dynamic> _normalizeParentProfile(
    Map<String, dynamic> current, {
    required User firebaseUser,
    required String fallbackEmail,
  }) {
    final updates = <String, dynamic>{};
    final now = FieldValue.serverTimestamp();

    if (current['email'] == null ||
        (current['email'] as String?)?.isEmpty == true) {
      updates['email'] = firebaseUser.email ?? fallbackEmail;
    }

    final currentDisplayName = current['displayName'] as String?;
    if (currentDisplayName == null || currentDisplayName.trim().isEmpty) {
      updates['displayName'] =
          firebaseUser.displayName ?? _deriveNameFromEmail(fallbackEmail);
    }

    if (current['role'] == null) {
      updates['role'] = UserType.parent.name;
    }

    if (current['userType'] == null) {
      updates['userType'] = UserType.parent.name;
    }

    if (current['photoURL'] == null && firebaseUser.photoURL != null) {
      updates['photoURL'] = firebaseUser.photoURL;
    }

    if (current['children'] == null) {
      updates['children'] = <String>[];
    }

    if (current['preferences'] == null) {
      updates['preferences'] = {
        'notifications': true,
        'emailReports': true,
      };
    }

    if (current['metadata'] == null) {
      updates['metadata'] = <String, dynamic>{};
    }

    if (current['lastLoginAt'] == null) {
      updates['lastLoginAt'] = now;
    }

    if (current['lastLogin'] == null) {
      updates['lastLogin'] = now;
    }

    if (updates.isNotEmpty) {
      updates['updatedAt'] = now;
    }

    return updates;
  }

  String _deriveNameFromEmail(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) {
      return 'SafePlay Parent';
    }

    final sanitized = localPart
        .replaceAll(RegExp(r'[_\.\-]+'), ' ')
        .split(' ')
        .where((segment) => segment.isNotEmpty)
        .map((segment) {
      final lower = segment.toLowerCase();
      return lower[0].toUpperCase() + lower.substring(1);
    }).join(' ');

    return sanitized.isEmpty ? 'SafePlay Parent' : sanitized;
  }

  /// Sign up with email and password
  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('[AuthService]: Starting signup for $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(
          '[AuthService]: Firebase user created with ID: ${credential.user?.uid}');
      if (credential.user == null) {
        print('[AuthService]: No user returned from Firebase signup');
        return null;
      }

      final profileData = {
        'uid': credential.user!.uid,
        'id': credential.user!.uid,
        'name': name,
        'displayName': name,
        'email': email,
        'userType': UserType.parent.name,
        'role': UserType.parent.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'children': <String>[],
        'preferences': {
          'notifications': true,
          'emailReports': true,
        },
        'metadata': <String, dynamic>{},
      };

      print('[AuthService]: Profile data to save: $profileData');

      await _firestore
          .collection(usersCollection)
          .doc(credential.user!.uid)
          .set(profileData);

      print('[AuthService]: User profile saved to Firestore');

      await credential.user!.updateDisplayName(name);

      final profile = UserProfile(
        id: credential.user!.uid,
        name: name,
        email: email,
        userType: UserType.parent,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      print('[AuthService]: Signup completed successfully');
      return profile;
    } on FirebaseAuthException catch (authError) {
      print('[AuthService]: Firebase auth signup error: ${authError.code}');
      if (_shouldFallbackToLocalOnSignup(authError)) {
        return await _signUpLocalAccount(
          email: email,
          password: password,
          name: name,
        );
      }
      throw authError;
    } on FirebaseException catch (firebaseError) {
      print(
          '[AuthService]: Firebase platform signup error: ${firebaseError.code}');
      if (_shouldFallbackToLocalOnSignup(firebaseError)) {
        return await _signUpLocalAccount(
          email: email,
          password: password,
          name: name,
        );
      }
      rethrow;
    } on PlatformException catch (platformError) {
      print('[AuthService]: Platform signup error: ${platformError.code}');
      if (_shouldFallbackToLocalOnSignup(platformError)) {
        return await _signUpLocalAccount(
          email: email,
          password: password,
          name: name,
        );
      }
      rethrow;
    } on SocketException catch (socketError) {
      print('[AuthService]: Network error during signup: $socketError');
      if (_shouldFallbackToLocalOnSignup(socketError)) {
        return await _signUpLocalAccount(
          email: email,
          password: password,
          name: name,
        );
      }
      rethrow;
    } catch (error) {
      print('[AuthService]: Error signing up: $error');
      if (_shouldFallbackToLocalOnSignup(error)) {
        return await _signUpLocalAccount(
          email: email,
          password: password,
          name: name,
        );
      }
      rethrow;
    }
  }

  /// Sign up a teacher account with email/password
  Future<UserProfile?> signUpTeacher({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      final profileData = {
        'uid': credential.user!.uid,
        'id': credential.user!.uid,
        'name': name,
        'displayName': name,
        'email': email,
        'userType': UserType.teacher.name,
        'role': UserType.teacher.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'metadata': <String, dynamic>{},
      };

      await _firestore
          .collection(usersCollection)
          .doc(credential.user!.uid)
          .set(profileData);

      await credential.user!.updateDisplayName(name);

      final profile = UserProfile(
        id: credential.user!.uid,
        name: name,
        email: email,
        userType: UserType.teacher,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      return profile;
    } on FirebaseAuthException catch (authError) {
      if (_shouldFallbackToLocalOnSignup(authError)) {
        // Local fallback signs up as parent; skip for teacher to avoid confusion
      }
      throw authError;
    }
  }

  Future<UserProfile?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) {
    return signUp(email: email, password: password, name: name);
  }

  /// Sign in child with picture password (Junior Explorer)
  Future<ChildProfile?> signInChildWithPicturePassword(
    String childId,
    List<String> pictureSequence,
  ) async {
    try {
      final doc =
          await _firestore.collection(childrenCollection).doc(childId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final authData = _extractAuthData(data);
      final storedHash = (authData['pictureSequenceHash'] as String?) ??
          (data['picturePasswordHash'] as String?);

      if (storedHash == null) return null;

      final providedHash = _hashPictureSequence(pictureSequence);

      if (providedHash != storedHash) {
        await _trackFailedLoginAttempt(childId);
        return null;
      }

      await _updateChildLastLogin(childId);

      return ChildProfile.fromJson({
        'id': doc.id,
        ...data,
      });
    } catch (e) {
      print('Error signing in child with picture password: $e');
      rethrow;
    }
  }

  /// Sign in child with picture + PIN (Bright Minds)
  Future<ChildProfile?> signInChildWithPicturePin(
    String childId,
    List<String> pictures,
    String pin,
  ) async {
    try {
      final doc =
          await _firestore.collection(childrenCollection).doc(childId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final authData = _extractAuthData(data);
      final storedPictureHash = (authData['pictureSequenceHash'] as String?) ??
          (data['pictureSelectionHash'] as String?);
      final storedPinHash =
          (authData['pinHash'] as String?) ?? (data['pinHash'] as String?);

      if (storedPictureHash == null || storedPinHash == null) return null;

      final providedPictureHash = _hashPictureSequence(pictures);
      final providedPinHash = _hashPin(pin);

      if (providedPictureHash != storedPictureHash ||
          providedPinHash != storedPinHash) {
        await _trackFailedLoginAttempt(childId);
        return null;
      }

      await _updateChildLastLogin(childId);

      return ChildProfile.fromJson({
        'id': doc.id,
        ...data,
      });
    } catch (e) {
      print('Error signing in child with picture+PIN: $e');
      rethrow;
    }
  }

  /// Sign in with biometric authentication
  Future<UserProfile?> signInWithBiometric() async {
    try {
      // Check if biometric is available
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return null;

      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access SafePlay',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) return null;

      // Get stored user ID
      final userId = await _secureStorage.read(key: 'biometric_user_id');
      if (userId == null) return null;

      // Get user profile
      final doc =
          await _firestore.collection(usersCollection).doc(userId).get();

      if (!doc.exists) return null;

      return UserProfile.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      print('Error signing in with biometric: $e');
      rethrow;
    }
  }

  /// Enable biometric authentication for user
  Future<void> enableBiometric(String userId) async {
    await _secureStorage.write(key: 'biometric_user_id', value: userId);
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Check if email is verified
  bool isEmailVerified() {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Reload user to get latest email verification status
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Change password (requires reauthentication)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Reauthenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }

  /// Send credentials email via Cloud Function
  /// NOTE: Disabled to fix iOS build issues. Parents can manually share credentials.
  Future<void> sendCredentialsEmail({
    required String to,
    required String subject,
    required String childName,
    required String authType,
    required Map<String, dynamic> credentials,
  }) async {
    // Firebase Functions removed to fix iOS build issues
    // Parents can manually share child login credentials
    print(
        '[AuthService]: Email functionality disabled. Please share credentials manually.');
  }

  /// Delete user account and all associated data
  Future<void> deleteAccount({
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Reauthenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Delete user data from Firestore
    await _deleteUserData(user.uid);

    // Delete Firebase Auth account
    await user.delete();
  }

  /// Delete all user data from Firestore
  Future<void> _deleteUserData(String userId) async {
    try {
      // Delete user profile
      await _firestore.collection(usersCollection).doc(userId).delete();

      // Delete user's children (if they are the only parent)
      final childrenQuery = await _firestore
          .collection(childrenCollection)
          .where('parentIds', arrayContains: userId)
          .get();

      for (final doc in childrenQuery.docs) {
        final data = doc.data();
        final parentIds = List<String>.from(data['parentIds'] ?? []);

        if (parentIds.length == 1 && parentIds.contains(userId)) {
          // Only parent, delete child
          await doc.reference.delete();
        } else {
          // Multiple parents, remove this parent
          parentIds.remove(userId);
          await doc.reference.update({'parentIds': parentIds});
        }
      }

      // Delete auth logs
      final authLogsQuery = await _firestore
          .collection('authLogs')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in authLogsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete any other user-specific data
      final activitiesQuery = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in activitiesQuery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get child profile
  Future<ChildProfile?> getChildProfile(String childId) async {
    try {
      final doc =
          await _firestore.collection(childrenCollection).doc(childId).get();

      if (!doc.exists) return null;

      return ChildProfile.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      print('Error getting child profile: $e');
      return null;
    }
  }

  /// Get children for parent
  Future<List<ChildProfile>> getChildrenForParent(String parentId) async {
    try {
      final collection = _firestore.collection(childrenCollection);

      final List<QuerySnapshot<Map<String, dynamic>>> snapshots = [];
      final primarySnapshot =
          await collection.where('parentIds', arrayContains: parentId).get();
      snapshots.add(primarySnapshot);

      if (primarySnapshot.docs.isEmpty) {
        final legacySnapshot =
            await collection.where('parentId', isEqualTo: parentId).get();
        snapshots.add(legacySnapshot);
      }

      final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>
          uniqueDocs = {};
      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          uniqueDocs[doc.id] = doc;
        }
      }

      final children = uniqueDocs.values.map((doc) {
        final data = doc.data();
        print('[AuthService]: Loading child ${doc.id} with data: $data');
        print('[AuthService]: Child ${doc.id} authData: ${data['authData']}');
        return ChildProfile.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      print(
          '[AuthService]: Loaded ${children.length} children for parent $parentId');
      for (final child in children) {
        print(
            '[AuthService]: Child ${child.id} (${child.name}) - authData: ${child.authData}');
      }

      return children;
    } catch (e) {
      print('Error getting children: $e');
      return [];
    }
  }

  /// Create child profile
  Future<ChildProfile> createChildProfile(ChildProfile profile) async {
    try {
      print('[AuthService]: Creating child profile for ${profile.name}');

      // Ensure we have a parent user logged in
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No parent user logged in');
      }

      // Ensure the profile has the current parent's ID
      final updatedProfile = profile.copyWith(
        parentIds: [
          currentUser.uid,
          ...profile.parentIds.where((id) => id != currentUser.uid)
        ],
      );

      final data = _childProfileToFirestore(updatedProfile, forUpdate: false);

      // Ensure parentId is also set for legacy compatibility
      data['parentId'] = currentUser.uid;
      data['parentIds'] = [currentUser.uid];

      print('[AuthService]: Child profile data: $data');

      // Add the document to Firestore
      final docRef = await _firestore.collection(childrenCollection).add(data);
      print('[AuthService]: Child profile created with ID: ${docRef.id}');

      // Update parent's children list
      await _firestore.collection(usersCollection).doc(currentUser.uid).update({
        'children': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get the created document
      final stored = await docRef.get();
      final storedData = stored.data() ?? {};

      final createdProfile = ChildProfile.fromJson({
        'id': stored.id,
        ...storedData,
      });

      print(
          '[AuthService]: Child profile created successfully: ${createdProfile.name}');
      return createdProfile;
    } catch (e) {
      print('[AuthService]: Error creating child profile: $e');
      rethrow;
    }
  }

  /// Update child profile
  Future<void> updateChildProfile(ChildProfile profile) async {
    final data = _childProfileToFirestore(profile, forUpdate: true);
    await _firestore
        .collection(childrenCollection)
        .doc(profile.id)
        .set(data, SetOptions(merge: true));
  }

  /// Delete child profile
  Future<void> deleteChildProfile(String childId) async {
    try {
      print('[AuthService]: Deleting child profile: $childId');

      // Ensure we have a parent user logged in
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No parent user logged in');
      }

      // Get the child profile to verify ownership
      final childDoc =
          await _firestore.collection(childrenCollection).doc(childId).get();
      if (!childDoc.exists) {
        throw Exception('Child profile not found');
      }

      final childData = childDoc.data()!;
      if (!childData['parentIds'].contains(currentUser.uid)) {
        throw Exception(
            'You do not have permission to delete this child profile');
      }

      // Delete the child profile
      await _firestore.collection(childrenCollection).doc(childId).delete();
      print('[AuthService]: Child profile deleted successfully: $childId');
    } catch (e) {
      print('[AuthService]: Error deleting child profile: $e');
      rethrow;
    }
  }

  /// Set picture password for child
  Future<void> setPicturePassword(
    String childId,
    List<String> pictureSequence,
  ) async {
    try {
      print('[AuthService]: Setting picture password for child: $childId');
      print('[AuthService]: Picture sequence: $pictureSequence');

      final hash = _hashPictureSequence(pictureSequence);
      print('[AuthService]: Generated hash: $hash');

      final authData = {
        'pictureSequenceHash': hash,
        'authType': 'picture',
        'updatedAt': FieldValue.serverTimestamp(),
        'loginAttempts': 0,
        'lockedUntil': null,
      };

      print('[AuthService]: Auth data to save: $authData');

      // Use set with merge to ensure the authData field is created properly
      await _firestore.collection(childrenCollection).doc(childId).set({
        'authData': authData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print(
          '[AuthService]: Picture password saved successfully for child: $childId');
    } catch (e) {
      print('[AuthService]: Error setting picture password: $e');
      rethrow;
    }
  }

  /// Set picture + PIN for child
  Future<void> setPicturePin(
    String childId,
    List<String> pictures,
    String pin,
  ) async {
    try {
      print('[AuthService]: Setting picture + PIN for child: $childId');
      print('[AuthService]: Pictures: $pictures, PIN: $pin');

      final pictureHash = _hashPictureSequence(pictures);
      final pinHash = _hashPin(pin);

      print('[AuthService]: Picture hash: $pictureHash, PIN hash: $pinHash');

      final authData = {
        'pictureSequenceHash': pictureHash,
        'pinHash': pinHash,
        'authType': 'picture+pin',
        'updatedAt': FieldValue.serverTimestamp(),
        'loginAttempts': 0,
        'lockedUntil': null,
      };

      print('[AuthService]: Auth data to save: $authData');

      // Use set with merge to ensure the authData field is created properly
      await _firestore.collection(childrenCollection).doc(childId).set({
        'authData': authData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print(
          '[AuthService]: Picture + PIN saved successfully for child: $childId');
    } catch (e) {
      print('[AuthService]: Error setting picture + PIN: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _extractAuthData(Map<String, dynamic> data) {
    final raw = data['authData'];
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    return <String, dynamic>{};
  }

  /// Hash picture sequence using SHA-256
  String _hashPictureSequence(List<String> sequence) {
    final combined = sequence.join('|');
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash PIN
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Update last login timestamp for parent accounts
  Future<void> _updateLastLogin(String userId) async {
    await _firestore.collection(usersCollection).doc(userId).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update child last login
  Future<void> _updateChildLastLogin(String childId) async {
    await _firestore.collection(childrenCollection).doc(childId).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'loginAttempts': 0,
      'lockedUntil': null,
    });
  }

  /// Track failed login attempt and handle lockout
  Future<void> _trackFailedLoginAttempt(String childId) async {
    final doc =
        await _firestore.collection(childrenCollection).doc(childId).get();

    final data = doc.data() ?? <String, dynamic>{};
    final currentAttempts = (data['loginAttempts'] as int?) ?? 0;
    final newAttempts = currentAttempts + 1;
    const maxAttempts = 3;
    final updateData = <String, dynamic>{
      'loginAttempts': newAttempts,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (newAttempts >= maxAttempts) {
      final lockoutEnd = DateTime.now().add(const Duration(minutes: 15));
      updateData['lockedUntil'] = Timestamp.fromDate(lockoutEnd);
    }

    await _firestore
        .collection(childrenCollection)
        .doc(childId)
        .update(updateData);
  }

  /// Reset failed login attempts
  Future<void> _resetFailedLoginAttempts(String childId) async {
    await _firestore.collection(childrenCollection).doc(childId).update({
      'loginAttempts': 0,
      'lockedUntil': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check if child is locked out
  Future<bool> isChildLockedOut(String childId) async {
    final doc =
        await _firestore.collection(childrenCollection).doc(childId).get();

    final data = doc.data();
    if (data == null) return false;

    final lockoutValue = data['lockedUntil'];
    final loginAttempts = (data['loginAttempts'] as int?) ?? 0;

    DateTime? lockoutEnd;
    if (lockoutValue is Timestamp) {
      lockoutEnd = lockoutValue.toDate();
    } else if (lockoutValue is DateTime) {
      lockoutEnd = lockoutValue;
    }

    if (lockoutEnd != null) {
      if (DateTime.now().isBefore(lockoutEnd)) {
        return true;
      } else {
        await _resetFailedLoginAttempts(childId);
        return false;
      }
    }

    if (loginAttempts >= 3) {
      await _resetFailedLoginAttempts(childId);
    }

    return false;
  }

  /// Get remaining lockout time
  Future<Duration?> getRemainingLockoutTime(String childId) async {
    final doc =
        await _firestore.collection(childrenCollection).doc(childId).get();

    final data = doc.data();
    if (data == null) return null;

    final lockoutValue = data['lockedUntil'];
    DateTime? lockoutEnd;

    if (lockoutValue is Timestamp) {
      lockoutEnd = lockoutValue.toDate();
    } else if (lockoutValue is DateTime) {
      lockoutEnd = lockoutValue;
    }

    if (lockoutEnd == null) {
      return null;
    }

    final now = DateTime.now();
    if (now.isAfter(lockoutEnd)) {
      await _resetFailedLoginAttempts(childId);
      return null;
    }

    return lockoutEnd.difference(now);
  }

  /// Convert child profile to Firestore data format
  Map<String, dynamic> _childProfileToFirestore(ChildProfile profile,
      {required bool forUpdate}) {
    final data = profile.toJson();

    // Remove id from data as it's handled separately
    data.remove('id');

    // For updates, only include changed fields
    if (forUpdate) {
      // Remove fields that shouldn't be updated
      data.remove('createdAt');
      data['updatedAt'] = DateTime.now().toIso8601String();
    }

    return data;
  }
}
