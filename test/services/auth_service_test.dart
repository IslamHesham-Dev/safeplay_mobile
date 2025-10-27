import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safeplay_mobile/models/user_profile.dart';
import 'package:safeplay_mobile/models/user_type.dart';
import 'package:safeplay_mobile/services/auth_service.dart';
import 'package:safeplay_mobile/services/local_child_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    late FakeFirebaseFirestore firestore;
    late AuthService authService;
    late FirebaseAuth mockAuth;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      firestore = FakeFirebaseFirestore();
      LocalChildStorage.configure(firestoreInstance: firestore);
      mockAuth = _MockFirebaseAuth();
      authService = AuthService(auth: mockAuth, firestore: firestore);
    });

    tearDown(() {
      LocalChildStorage.configure();
    });

    test('should be instantiated', () {
      expect(authService, isNotNull);
    });

    test('should have required methods', () {
      expect(authService.signInWithEmail, isNotNull);
      expect(authService.signUpWithEmail, isNotNull);
      expect(authService.signOut, isNotNull);
    });

    test('createChildProfile stores parent email on child record', () async {
      final profile = ChildProfile(
        id: '',
        name: 'Razan',
        userType: UserType.juniorChild,
        ageGroup: AgeGroup.junior,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentIds: const ['parent-uid'],
        age: 8,
        gender: 'female',
        stats: const ChildStats(),
        achievements: const [],
        favoriteSubjects: const [],
        learningModes: const [],
        parentEmail: 'Parent@Example.com',
      );

      final createdProfile = await authService.createChildProfile(profile);
      final storedDoc = await firestore
          .collection(AuthService.childrenCollection)
          .doc(createdProfile.id)
          .get();

      expect(storedDoc.data()?['parentEmail'], 'parent@example.com');
      expect(createdProfile.parentEmail, 'parent@example.com');
    });

    test('authenticateChildWithEmojis succeeds using local cache', () async {
      final sequence = ['😀', '🚀', '🌟', '🐱'];
      final hash = _hashSequence(sequence);
      final child = ChildProfile(
        id: 'emoji-child',
        name: 'Emoji Kid',
        userType: UserType.juniorChild,
        ageGroup: AgeGroup.junior,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentIds: const [],
        age: 7,
        gender: 'male',
        parentEmail: 'parent@example.com',
        authData: {
          'authType': 'emoji',
          'pictureSequenceHash': hash,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await LocalChildStorage.addChild(child);

      final result =
          await authService.authenticateChildWithEmojis(child.id, sequence);

      expect(result, isTrue);
    });

    test('authenticateChildWithEmojis falls back to Firestore when needed',
        () async {
      final sequence = ['😀', '🚀', '🌟', '🐱'];
      final correctHash = _hashSequence(sequence);
      final wrongHash = _hashSequence(['😀', '😀', '😀', '😀']);

      final child = ChildProfile(
        id: 'emoji-firestore',
        name: 'Emoji Kid',
        userType: UserType.juniorChild,
        ageGroup: AgeGroup.junior,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentIds: const [],
        age: 7,
        gender: 'male',
        parentEmail: 'parent@example.com',
        authData: {
          'authType': 'emoji',
          'pictureSequenceHash': wrongHash,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await LocalChildStorage.addChild(child);

      await firestore.collection('children').doc(child.id).set({
        'authData': {
          'authType': 'emoji',
          'pictureSequenceHash': correctHash,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        'fullName': 'Emoji Kid',
        'age': 7,
        'gender': 'male',
        'parentEmail': 'parent@example.com',
        'updatedAt': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      final result =
          await authService.authenticateChildWithEmojis(child.id, sequence);

      expect(result, isTrue);
    });

    test('authenticateChildWithPicturePin succeeds using local cache',
        () async {
      final pictures = ['A', 'B', 'C'];
      final pin = '1234';
      final pictureHash = _hashSequence(pictures);
      final pinHash = _hashPin(pin);

      final child = ChildProfile(
        id: 'bright-child',
        name: 'Bright Kid',
        userType: UserType.brightChild,
        ageGroup: AgeGroup.bright,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentIds: const [],
        age: 10,
        gender: 'female',
        parentEmail: 'bright@example.com',
        authData: {
          'authType': 'picture+pin',
          'pictureSequenceHash': pictureHash,
          'pinHash': pinHash,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await LocalChildStorage.addChild(child);

      final result = await authService.authenticateChildWithPicturePin(
        child.id,
        pictures,
        pin,
      );

      expect(result, isTrue);
    });

    test('authenticateChildWithPicturePin fails when hashes do not match',
        () async {
      final pictures = ['A', 'B', 'C'];
      final pin = '1234';
      final wrongPictureHash = _hashSequence(['X', 'Y', 'Z']);
      final wrongPinHash = _hashPin('9999');

      final child = ChildProfile(
        id: 'bright-failure',
        name: 'Bright Kid',
        userType: UserType.brightChild,
        ageGroup: AgeGroup.bright,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentIds: const [],
        age: 10,
        gender: 'female',
        parentEmail: 'bright@example.com',
        authData: {
          'authType': 'picture+pin',
          'pictureSequenceHash': wrongPictureHash,
          'pinHash': wrongPinHash,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      await LocalChildStorage.addChild(child);

      final result = await authService.authenticateChildWithPicturePin(
        child.id,
        pictures,
        pin,
      );

      expect(result, isFalse);
    });
  });
}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

String _hashSequence(List<String> sequence) {
  final combined = sequence.join('|');
  final bytes = utf8.encode(combined);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

String _hashPin(String pin) {
  final bytes = utf8.encode(pin);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
