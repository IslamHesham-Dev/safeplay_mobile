import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safeplay_mobile/models/user_profile.dart';
import 'package:safeplay_mobile/models/user_type.dart';
import 'package:safeplay_mobile/services/local_child_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalChildStorage validation', () {
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      firestore = FakeFirebaseFirestore();
      LocalChildStorage.configure(firestoreInstance: firestore);

      await firestore.collection('users').doc('parent123').set({
        'email': 'parent@example.com',
        'role': 'parent',
        'children': ['child123'],
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      await firestore.collection('children').doc('child123').set({
        'fullName': 'John Doe',
        'age': 8,
        'gender': 'male',
        'parentIds': ['parent123'],
        'parentEmail': 'parent@example.com',
        'authData': {
          'authType': 'emoji',
          'pictureSequenceHash': 'remote-hash',
          'updatedAt': DateTime.now().toIso8601String(),
        },
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    });

    tearDown(() {
      LocalChildStorage.configure();
    });

    test('validateParentEmail succeeds when parent exists', () async {
      final result =
          await LocalChildStorage.validateParentEmail('parent@example.com');
      expect(result, isTrue);
    });

    test('validateParentEmail fails when parent does not exist', () async {
      final result =
          await LocalChildStorage.validateParentEmail('missing@example.com');
      expect(result, isFalse);
    });

    test('fetchChildForParent returns canonical record', () async {
      final child = await LocalChildStorage.fetchChildForParent(
        parentEmail: 'parent@example.com',
        childName: 'John Doe',
        childAge: 8,
        childGender: 'male',
      );

      expect(child, isNotNull);
      expect(child!.id, 'child123');
      expect(child.parentEmail, 'parent@example.com');
    });

    test('fetchChildForParent returns null for mismatched details', () async {
      final child = await LocalChildStorage.fetchChildForParent(
        parentEmail: 'parent@example.com',
        childName: 'Jane Doe',
        childAge: 8,
        childGender: 'female',
      );

      expect(child, isNull);
    });

    test('fetchChildForParent falls back to local cache on Firestore failure',
        () async {
      final localChild = ChildProfile(
        id: 'child-local',
        name: 'Offline Kid',
        userType: UserType.juniorChild,
        ageGroup: AgeGroup.junior,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentIds: const ['offline-parent'],
        age: 7,
        gender: 'male',
        parentEmail: 'offline@example.com',
        authData: const {
          'authType': 'emoji',
          'pictureSequenceHash': 'local-hash',
        },
      );

      await LocalChildStorage.addChild(localChild);

      LocalChildStorage.configure(
        firestoreInstance: _ThrowingFirebaseFirestore(),
      );

      final child = await LocalChildStorage.fetchChildForParent(
        parentEmail: 'offline@example.com',
        childName: 'Offline Kid',
        childAge: 7,
        childGender: 'male',
      );

      expect(child, isNotNull);
      expect(child!.id, 'child-local');
      expect(child.parentEmail, 'offline@example.com');
    });
  });
}

class _ThrowingFirebaseFirestore extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'Simulated permission error',
    );
  }
}
