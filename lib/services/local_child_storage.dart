import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Local storage service for managing parent-specific children
class LocalChildStorage {
  static const String _childrenKey = 'parent_children';

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
      final prefs = await SharedPreferences.getInstance();
      final children = await getChildren();

      // Find and update the child
      final index = children.indexWhere((child) => child.id == updatedChild.id);
      if (index != -1) {
        children[index] = updatedChild;

        // Save back to storage
        final childrenJson =
            children.map((child) => jsonEncode(child.toJson())).toList();

        return await prefs.setStringList(_childrenKey, childrenJson);
      }
      return false;
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
}
