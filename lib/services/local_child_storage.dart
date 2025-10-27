import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Local storage service for managing parent-specific children
class LocalChildStorage {
  static const String _childrenKey = 'parent_children';
  static FirebaseFirestore? _firestore;

  static FirebaseFirestore get _firestoreInstance =>
      _firestore ?? FirebaseFirestore.instance;

  /// Allows tests to inject a mock Firestore instance or reset to default.
  static void configure({FirebaseFirestore? firestoreInstance}) {
    _firestore = firestoreInstance;
  }

  /// Get all children for the current parent (local storage)
  static Future<List<ChildProfile>> getChildren() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final childrenJson = prefs.getStringList(_childrenKey) ?? [];

      return childrenJson
          .map((json) => ChildProfile.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('[LocalChildStorage]: Error getting children: $e');
      return [];
    }
  }

  /// Get all children linked to a specific parent email.
  static Future<List<ChildProfile>> getChildrenForParent(
    String parentEmail,
  ) async {
    final normalizedEmail = parentEmail.trim().toLowerCase();
    print(
        '[LocalChildStorage]: getChildrenForParent called with: $parentEmail -> $normalizedEmail');

    if (normalizedEmail.isEmpty) return [];

    final children = await getChildren();
    print(
        '[LocalChildStorage]: Found ${children.length} total children in local storage');

    for (final child in children) {
      final childParentEmail = (child.parentEmail ?? '').trim().toLowerCase();
      print(
          '[LocalChildStorage]: Child ${child.name}: parentEmail = "$childParentEmail" vs "$normalizedEmail" -> ${childParentEmail == normalizedEmail}');
    }

    final filteredChildren = children
        .where(
          (child) =>
              (child.parentEmail ?? '').trim().toLowerCase() == normalizedEmail,
        )
        .toList();

    print(
        '[LocalChildStorage]: Filtered to ${filteredChildren.length} children for parent $normalizedEmail');
    return filteredChildren;
  }

  /// Fetch a child from local storage using its identifier.
  static Future<ChildProfile?> getChildById(String childId) async {
    if (childId.trim().isEmpty) return null;

    final children = await getChildren();
    for (final child in children) {
      if (child.id == childId) {
        return child;
      }
    }
    return null;
  }

  /// Add a new child to local storage
  static Future<bool> addChild(ChildProfile child) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final children = await getChildren();

      // Add the new child
      children.add(child);

      // Save back to storage
      final childrenJson =
          children.map((child) => jsonEncode(child.toJson())).toList();

      return await prefs.setStringList(_childrenKey, childrenJson);
    } catch (e) {
      print('[LocalChildStorage]: Error adding child: $e');
      return false;
    }
  }

  /// Update an existing child in local storage
  static Future<bool> updateChild(ChildProfile updatedChild) async {
    try {
      print(
          '[LocalChildStorage]: updateChild called for: ${updatedChild.name} (${updatedChild.id})');
      print(
          '[LocalChildStorage]: Child parentEmail: ${updatedChild.parentEmail}');

      final prefs = await SharedPreferences.getInstance();
      final children = await getChildren();

      print(
          '[LocalChildStorage]: Found ${children.length} existing children in local storage');

      // Find and update the child
      final index = children.indexWhere((child) => child.id == updatedChild.id);
      print('[LocalChildStorage]: Child index in existing children: $index');

      if (index != -1) {
        print('[LocalChildStorage]: Updating existing child at index $index');
        children[index] = updatedChild;
      } else {
        print('[LocalChildStorage]: Child not found, adding as new child');
        children.add(updatedChild);
      }

      // Save back to storage
      final childrenJson =
          children.map((child) => jsonEncode(child.toJson())).toList();

      final success = await prefs.setStringList(_childrenKey, childrenJson);
      print('[LocalChildStorage]: Save to local storage successful: $success');
      return success;
    } catch (e) {
      print('[LocalChildStorage]: Error updating child: $e');
      return false;
    }
  }

  /// Remove a child from local storage
  static Future<bool> removeChild(String childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final children = await getChildren();

      // Remove the child
      children.removeWhere((child) => child.id == childId);

      // Save back to storage
      final childrenJson =
          children.map((child) => jsonEncode(child.toJson())).toList();

      return await prefs.setStringList(_childrenKey, childrenJson);
    } catch (e) {
      print('[LocalChildStorage]: Error removing child: $e');
      return false;
    }
  }

  /// Clear all children (for testing or reset)
  static Future<bool> clearAllChildren() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_childrenKey);
    } catch (e) {
      print('[LocalChildStorage]: Error clearing children: $e');
      return false;
    }
  }

  /// Get child count
  static Future<int> getChildCount() async {
    final children = await getChildren();
    return children.length;
  }

  /// Check if a parent email exists in Firestore.
  static Future<bool> validateParentEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return false;
    }

    // First check email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(normalizedEmail)) {
      return false;
    }

    // Check if parent exists in Firestore database
    try {
      final usersRef = _firestoreInstance.collection('users');
      final querySnapshot = await usersRef
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (firebaseError) {
      _logFirestoreError(
        operation: 'validateParentEmail',
        error: firebaseError,
        email: normalizedEmail,
      );
      return _fallbackParentEmailCheck(normalizedEmail);
    } catch (e) {
      print('[LocalChildStorage]: Error validating parent email: $e');
      return _fallbackParentEmailCheck(normalizedEmail);
    }
  }

  /// Check if a child name is available (no duplicates in local storage).
  static Future<bool> validateChildName(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return false;
    }

    try {
      // Check local storage for duplicate names
      final existingChildren = await getChildren();
      final hasDuplicate = existingChildren.any((child) {
        return child.name.toLowerCase() == trimmedName.toLowerCase();
      });

      return !hasDuplicate;
    } catch (e) {
      print('[LocalChildStorage]: Error validating child name: $e');
      return false;
    }
  }

  /// Load the canonical child profile for a given parent/child combination.
  static Future<ChildProfile?> fetchChildForParent({
    required String parentEmail,
    required String childName,
    required int childAge,
    required String childGender,
  }) async {
    final normalizedEmail = parentEmail.trim().toLowerCase();
    final normalizedChildName = childName.trim().toLowerCase();
    final normalizedGender = childGender.trim().toLowerCase();

    print('[LocalChildStorage]: fetchChildForParent called with:');
    print(
        '[LocalChildStorage]: - ParentEmail: $parentEmail -> $normalizedEmail');
    print(
        '[LocalChildStorage]: - ChildName: $childName -> $normalizedChildName');
    print('[LocalChildStorage]: - ChildAge: $childAge');
    print(
        '[LocalChildStorage]: - ChildGender: $childGender -> $normalizedGender');

    if (normalizedEmail.isEmpty || normalizedChildName.isEmpty) {
      print('[LocalChildStorage]: Empty email or child name, returning null');
      return null;
    }

    try {
      // First try: Direct search by parentEmail in children collection (most reliable)
      print('[LocalChildStorage]: Trying direct search by parentEmail...');
      final childrenRef = _firestoreInstance.collection('children');
      final emailChildren = await childrenRef
          .where('parentEmail', isEqualTo: normalizedEmail)
          .get();

      print(
          '[LocalChildStorage]: Found ${emailChildren.docs.length} children with parentEmail $normalizedEmail');

      for (final doc in emailChildren.docs) {
        print(
            '[LocalChildStorage]: Checking child ${doc.id} with data: ${doc.data()}');
        if (_childDocMatchesParent(
          data: doc.data(),
          normalizedChildName: normalizedChildName,
          expectedAge: childAge,
          normalizedGender: normalizedGender,
          parentId: '', // Not needed for parentEmail validation
          parentEmail: normalizedEmail,
        )) {
          print(
              '[LocalChildStorage]: Found matching child by parentEmail: ${doc.id}');
          return _childProfileFromFirestoreDoc(
            doc: doc,
            fallbackEmail: normalizedEmail,
          );
        }
      }

      // Second try: Find parent and use full validation (if permissions allow)
      print(
          '[LocalChildStorage]: Direct search failed, trying parent lookup...');
      final usersRef = _firestoreInstance.collection('users');
      final parentQuery = await usersRef
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (parentQuery.docs.isEmpty) {
        print(
            '[LocalChildStorage]: No parent found with email $normalizedEmail');
        return null;
      }

      final parentDoc = parentQuery.docs.first;
      final parentId = parentDoc.id;
      print('[LocalChildStorage]: Found parent with ID: $parentId');
      print('[LocalChildStorage]: Parent data: ${parentDoc.data()}');

      final firestoreMatch = await _findChildInFirestore(
        childrenRef: childrenRef,
        parentDoc: parentDoc,
        parentId: parentId,
        normalizedChildName: normalizedChildName,
        expectedAge: childAge,
        normalizedGender: normalizedGender,
        parentEmail: normalizedEmail,
      );

      if (firestoreMatch != null) {
        print(
            '[LocalChildStorage]: Found matching child in Firestore: ${firestoreMatch.id}');
        return firestoreMatch;
      }

      print(
          '[LocalChildStorage]: No matching child found in Firestore, trying local fallback...');
      return _findChildLocally(
        parentEmail: normalizedEmail,
        childName: normalizedChildName,
        childAge: childAge,
        childGender: normalizedGender,
      );
    } on FirebaseException catch (firebaseError) {
      print(
          '[LocalChildStorage]: Firebase error in fetchChildForParent: ${firebaseError.code} - ${firebaseError.message}');

      // If it's a permission error, try direct children search first
      if (firebaseError.code == 'permission-denied') {
        print(
            '[LocalChildStorage]: Permission denied, trying direct children search...');
        try {
          final childrenRef = _firestoreInstance.collection('children');
          final emailChildren = await childrenRef
              .where('parentEmail', isEqualTo: normalizedEmail)
              .get();

          print(
              '[LocalChildStorage]: Found ${emailChildren.docs.length} children with parentEmail $normalizedEmail');

          for (final doc in emailChildren.docs) {
            if (_childDocMatchesParent(
              data: doc.data(),
              normalizedChildName: normalizedChildName,
              expectedAge: childAge,
              normalizedGender: normalizedGender,
              parentId: '', // Not needed for parentEmail validation
              parentEmail: normalizedEmail,
            )) {
              print(
                  '[LocalChildStorage]: Found matching child by parentEmail (permission fallback): ${doc.id}');
              return _childProfileFromFirestoreDoc(
                doc: doc,
                fallbackEmail: normalizedEmail,
              );
            }
          }
        } catch (e) {
          print('[LocalChildStorage]: Direct children search also failed: $e');
        }
      }

      _logFirestoreError(
        operation: 'fetchChildForParent',
        error: firebaseError,
        email: normalizedEmail,
      );
      return _findChildLocally(
        parentEmail: normalizedEmail,
        childName: normalizedChildName,
        childAge: childAge,
        childGender: normalizedGender,
      );
    } catch (e) {
      print('[LocalChildStorage]: Error fetching child profile: $e');
      return _findChildLocally(
        parentEmail: normalizedEmail,
        childName: normalizedChildName,
        childAge: childAge,
        childGender: normalizedGender,
      );
    }
  }

  /// Check if a child belongs to a specific parent in Firestore.
  static Future<bool> validateParentChildRelationship(
    String parentEmail,
    String childName,
    int childAge,
    String childGender,
  ) async {
    final childProfile = await fetchChildForParent(
      parentEmail: parentEmail,
      childName: childName,
      childAge: childAge,
      childGender: childGender,
    );

    return childProfile != null;
  }

  static Future<bool> _fallbackParentEmailCheck(String normalizedEmail) async {
    final hasLocalRecord = await _parentExistsLocally(normalizedEmail);
    if (hasLocalRecord) {
      print(
          '[LocalChildStorage]: Found parent email $normalizedEmail in local storage, allowing offline validation.');
      return true;
    }

    print(
        '[LocalChildStorage]: Falling back to email format validation for $normalizedEmail.');
    return true;
  }

  static Future<bool> _parentExistsLocally(String normalizedEmail) async {
    final children = await getChildren();
    for (final child in children) {
      final parentEmail = child.parentEmail?.trim().toLowerCase();
      if (parentEmail == normalizedEmail) {
        return true;
      }
    }
    return false;
  }

  static Future<ChildProfile?> _findChildLocally({
    required String parentEmail,
    required String childName,
    required int childAge,
    required String childGender,
  }) async {
    print('[LocalChildStorage]: Searching locally for child...');
    final cachedChildren = await getChildren();
    print(
        '[LocalChildStorage]: Found ${cachedChildren.length} children in local cache');

    for (final child in cachedChildren) {
      final normalizedParent = (child.parentEmail ?? '').trim().toLowerCase();
      final normalizedName = child.name.trim().toLowerCase();
      final normalizedGender = (child.gender ?? '').trim().toLowerCase();
      final storedAge = child.age;

      final matchesParent = normalizedParent == parentEmail;
      final matchesName = normalizedName == childName;
      final matchesAge = storedAge != null && storedAge == childAge;
      final matchesGender = normalizedGender.isEmpty
          ? childGender.isEmpty
          : normalizedGender == childGender;

      print('[LocalChildStorage]: Checking local child ${child.id}:');
      print(
          '[LocalChildStorage]: - Parent: $normalizedParent vs $parentEmail -> $matchesParent');
      print(
          '[LocalChildStorage]: - Name: $normalizedName vs $childName -> $matchesName');
      print(
          '[LocalChildStorage]: - Age: $storedAge vs $childAge -> $matchesAge');
      print(
          '[LocalChildStorage]: - Gender: $normalizedGender vs $childGender -> $matchesGender');

      if (matchesParent && matchesName && matchesAge && matchesGender) {
        print(
            '[LocalChildStorage]: Relationship validated locally for $childName ($parentEmail).');
        return child;
      }
    }

    print(
        '[LocalChildStorage]: Unable to validate relationship locally for $childName ($parentEmail).');
    return null;
  }

  static List<String> _extractChildIds(Map<String, dynamic>? parentData) {
    if (parentData == null) {
      return const [];
    }

    final childrenField = parentData['children'];
    if (childrenField is List) {
      return childrenField
          .map((entry) {
            if (entry is Map) {
              final id = (entry['id'] ?? entry['childId'] ?? entry['uid'] ?? '')
                  .toString()
                  .trim();
              return id;
            }
            return entry?.toString().trim() ?? '';
          })
          .where((id) => id.isNotEmpty)
          .toList();
    }

    return const [];
  }

  static List<List<String>> _chunkList(List<String> ids, int size) {
    if (ids.length <= size) {
      return [ids];
    }

    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += size) {
      final end = (i + size < ids.length) ? i + size : ids.length;
      chunks.add(ids.sublist(i, end));
    }
    return chunks;
  }

  static bool _childDocMatchesParent({
    required Map<String, dynamic>? data,
    required String normalizedChildName,
    required int expectedAge,
    required String normalizedGender,
    required String parentId,
    required String parentEmail,
  }) {
    if (data == null) {
      return false;
    }

    final storedName = (data['fullName'] ?? data['name'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (storedName.isEmpty || storedName != normalizedChildName) {
      return false;
    }

    final storedAge = _parseInt(data['age']);
    if (storedAge == null || storedAge != expectedAge) {
      return false;
    }

    final storedGender = (data['gender'] ?? '').toString().trim().toLowerCase();
    if (normalizedGender.isNotEmpty &&
        storedGender.isNotEmpty &&
        storedGender != normalizedGender) {
      return false;
    }

    final parentIds = _stringList(data['parentIds']);
    final storedParentEmail =
        (data['parentEmail'] ?? '').toString().trim().toLowerCase();

    // Prioritize parentEmail check since it's the most reliable after recreation
    // Also check parentIds for backward compatibility (only if parentId is provided)
    final belongsToParent = storedParentEmail == parentEmail ||
        (parentId.isNotEmpty && parentIds.contains(parentId));

    print(
        '[LocalChildStorage]: Child validation - Name: $storedName, Age: $storedAge, Gender: $storedGender');
    print(
        '[LocalChildStorage]: Parent validation - Email: $storedParentEmail vs $parentEmail, ParentIds: $parentIds contains $parentId: ${parentId.isNotEmpty ? parentIds.contains(parentId) : 'N/A (parentId empty)'}');
    print('[LocalChildStorage]: Belongs to parent: $belongsToParent');

    return belongsToParent;
  }

  static Future<ChildProfile?> _findChildInFirestore({
    required CollectionReference<Map<String, dynamic>> childrenRef,
    required QueryDocumentSnapshot<Map<String, dynamic>> parentDoc,
    required String parentId,
    required String normalizedChildName,
    required int expectedAge,
    required String normalizedGender,
    required String parentEmail,
  }) async {
    print(
        '[LocalChildStorage]: Searching for child in Firestore - Name: $normalizedChildName, Age: $expectedAge, Gender: $normalizedGender, ParentEmail: $parentEmail');

    // First try: Search by parentEmail (most reliable after recreation)
    print('[LocalChildStorage]: Searching by parentEmail...');
    final emailChildren =
        await childrenRef.where('parentEmail', isEqualTo: parentEmail).get();
    print(
        '[LocalChildStorage]: Found ${emailChildren.docs.length} children with parentEmail $parentEmail');

    for (final doc in emailChildren.docs) {
      print(
          '[LocalChildStorage]: Checking child ${doc.id} with data: ${doc.data()}');
      if (_childDocMatchesParent(
        data: doc.data(),
        normalizedChildName: normalizedChildName,
        expectedAge: expectedAge,
        normalizedGender: normalizedGender,
        parentId: parentId,
        parentEmail: parentEmail,
      )) {
        print(
            '[LocalChildStorage]: Found matching child by parentEmail: ${doc.id}');
        return _childProfileFromFirestoreDoc(
          doc: doc,
          fallbackEmail: parentEmail,
        );
      }
    }

    // Second try: Search by parentIds array
    print('[LocalChildStorage]: Searching by parentIds...');
    final linkedChildren =
        await childrenRef.where('parentIds', arrayContains: parentId).get();
    print(
        '[LocalChildStorage]: Found ${linkedChildren.docs.length} children with parentId $parentId');

    for (final doc in linkedChildren.docs) {
      print(
          '[LocalChildStorage]: Checking child ${doc.id} with data: ${doc.data()}');
      if (_childDocMatchesParent(
        data: doc.data(),
        normalizedChildName: normalizedChildName,
        expectedAge: expectedAge,
        normalizedGender: normalizedGender,
        parentId: parentId,
        parentEmail: parentEmail,
      )) {
        print(
            '[LocalChildStorage]: Found matching child by parentIds: ${doc.id}');
        return _childProfileFromFirestoreDoc(
          doc: doc,
          fallbackEmail: parentEmail,
        );
      }
    }

    // Third try: Search by parent's children array (legacy)
    final parentChildIds = _extractChildIds(parentDoc.data());
    if (parentChildIds.isNotEmpty) {
      print(
          '[LocalChildStorage]: Searching by parent children array with ${parentChildIds.length} child IDs...');
      final idBatches = _chunkList(parentChildIds, 10);
      for (final batch in idBatches) {
        final snapshot =
            await childrenRef.where(FieldPath.documentId, whereIn: batch).get();

        for (final doc in snapshot.docs) {
          print(
              '[LocalChildStorage]: Checking child ${doc.id} with data: ${doc.data()}');
          if (_childDocMatchesParent(
            data: doc.data(),
            normalizedChildName: normalizedChildName,
            expectedAge: expectedAge,
            normalizedGender: normalizedGender,
            parentId: parentId,
            parentEmail: parentEmail,
          )) {
            print(
                '[LocalChildStorage]: Found matching child by children array: ${doc.id}');
            return _childProfileFromFirestoreDoc(
              doc: doc,
              fallbackEmail: parentEmail,
            );
          }
        }
      }
    }

    print('[LocalChildStorage]: No matching child found in Firestore');
    return null;
  }

  static ChildProfile _childProfileFromFirestoreDoc({
    required QueryDocumentSnapshot<Map<String, dynamic>> doc,
    required String fallbackEmail,
  }) {
    final data = doc.data();
    final childJson = {
      'id': doc.id,
      ...data,
      'parentEmail': data['parentEmail'] ?? fallbackEmail,
    };
    return ChildProfile.fromJson(childJson);
  }

  static List<String> _stringList(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) => item?.toString())
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }

    return const [];
  }

  static int? _parseInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  static void _logFirestoreError({
    required String operation,
    required FirebaseException error,
    required String email,
  }) {
    print(
        '[LocalChildStorage][$operation]: Firestore error (${error.code}) for $email: ${error.message}');
    if (error.code == 'permission-denied') {
      print(
          '[LocalChildStorage][$operation]: Firestore denied read access. Ensure security rules allow the required read operations.');
    }
  }
}
