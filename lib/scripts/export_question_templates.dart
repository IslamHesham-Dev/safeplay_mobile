import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../firebase_options.dart';

/// Script to export all questionTemplates from Firestore to a JSON file
///
/// Usage (from project root):
///   flutter run -d <device> lib/scripts/export_question_templates.dart
///
/// Or create a wrapper in bin/export_questions.dart (see README_EXPORT.md)
///
/// Output: question_templates_export.json in the project root
Future<void> exportQuestionTemplates() async {
  print('🚀 Starting question templates export...');

  try {
    // Initialize Firebase
    print('📡 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    // Get Firestore instance
    final firestore = FirebaseFirestore.instance;
    print('📚 Connecting to Firestore...');

    // Fetch all documents from questionTemplates collection
    print('📥 Fetching documents from "questionTemplates" collection...');
    final snapshot = await firestore
        .collection('questionTemplates')
        .orderBy('createdAt', descending: false)
        .get();

    print('✅ Found ${snapshot.docs.length} documents');

    // Convert documents to JSON-serializable format
    final List<Map<String, dynamic>> questionsData = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Convert Firestore Timestamps to ISO strings for JSON compatibility
      final convertedData = <String, dynamic>{};
      convertedData['id'] = doc.id;

      data.forEach((key, value) {
        if (value is Timestamp) {
          convertedData[key] = value.toDate().toIso8601String();
        } else if (value is GeoPoint) {
          convertedData[key] = {
            'latitude': value.latitude,
            'longitude': value.longitude,
          };
        } else if (value is List) {
          convertedData[key] = _convertList(value);
        } else if (value is Map) {
          convertedData[key] = _convertMap(value);
        } else {
          convertedData[key] = value;
        }
      });

      questionsData.add(convertedData);
    }

    // Create the export object
    final exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'totalCount': questionsData.length,
      'collection': 'questionTemplates',
      'data': questionsData,
    };

    // Convert to JSON with pretty printing
    final jsonString = JsonEncoder.withIndent('  ').convert(exportData);

    // Save to file (handle web vs mobile differently)
    String filePath;
    if (kIsWeb) {
      // For web, we'll create a download link
      print('✅ Export completed successfully!');
      print('📊 Total questions exported: ${questionsData.length}');
      print('📄 JSON data prepared (use browser download functionality)');

      // In a real web implementation, you'd trigger a download
      // For now, print the JSON (you can copy it manually)
      print('\n' + '=' * 50);
      print('JSON Data:');
      print('=' * 50);
      print(jsonString);
      print('=' * 50);
      print(
          '\n💡 Tip: Copy the JSON above and save it as question_templates_export.json');

      return;
    } else {
      // For non-web platforms, save to file
      final outputFile = File('question_templates_export.json');
      await outputFile.writeAsString(jsonString);
      filePath = outputFile.absolute.path;

      print('✅ Export completed successfully!');
      print('📄 File saved to: $filePath');
      print('📊 Total questions exported: ${questionsData.length}');
    }

    // Print summary statistics
    _printStatistics(questionsData);
  } catch (e, stackTrace) {
    print('❌ Error during export:');
    print(e);
    print('\nStack trace:');
    print(stackTrace);
    rethrow;
  }
}

/// Main entry point for standalone execution
/// Note: This requires Firebase to be initialized first
Future<void> main() async {
  await exportQuestionTemplates();
}

/// Recursively convert a list, handling Firestore types
List _convertList(List list) {
  return list.map((item) {
    if (item is Timestamp) {
      return item.toDate().toIso8601String();
    } else if (item is GeoPoint) {
      return {
        'latitude': item.latitude,
        'longitude': item.longitude,
      };
    } else if (item is Map) {
      return _convertMap(item);
    } else if (item is List) {
      return _convertList(item);
    } else {
      return item;
    }
  }).toList();
}

/// Recursively convert a map, handling Firestore types
Map<String, dynamic> _convertMap(Map map) {
  final converted = <String, dynamic>{};
  map.forEach((key, value) {
    if (value is Timestamp) {
      converted[key.toString()] = value.toDate().toIso8601String();
    } else if (value is GeoPoint) {
      converted[key.toString()] = {
        'latitude': value.latitude,
        'longitude': value.longitude,
      };
    } else if (value is List) {
      converted[key.toString()] = _convertList(value);
    } else if (value is Map) {
      converted[key.toString()] = _convertMap(value);
    } else {
      converted[key.toString()] = value;
    }
  });
  return converted;
}

/// Print statistics about the exported questions
void _printStatistics(List<Map<String, dynamic>> questions) {
  if (questions.isEmpty) {
    print('\n📈 No statistics available (empty collection)');
    return;
  }

  print('\n📈 Export Statistics:');
  print('─' * 50);

  // Count by type
  final typeCount = <String, int>{};
  final subjectCount = <String, int>{};
  final difficultyCount = <String, int>{};
  final ageGroupCount = <String, int>{};

  for (final question in questions) {
    // Count types
    final type = question['type']?.toString() ?? 'Unknown';
    typeCount[type] = (typeCount[type] ?? 0) + 1;

    // Count subjects
    if (question['subjects'] != null && question['subjects'] is List) {
      for (final subject in question['subjects'] as List) {
        final subjectStr = subject.toString();
        subjectCount[subjectStr] = (subjectCount[subjectStr] ?? 0) + 1;
      }
    }

    // Count difficulty
    if (question['difficulty'] != null) {
      final difficulty = question['difficulty'].toString();
      difficultyCount[difficulty] = (difficultyCount[difficulty] ?? 0) + 1;
    }

    // Count age groups
    if (question['ageGroups'] != null && question['ageGroups'] is List) {
      for (final ageGroup in question['ageGroups'] as List) {
        final ageGroupStr = ageGroup.toString();
        ageGroupCount[ageGroupStr] = (ageGroupCount[ageGroupStr] ?? 0) + 1;
      }
    }
  }

  print('\n📝 By Type:');
  typeCount.forEach((type, count) {
    print('   $type: $count');
  });

  if (subjectCount.isNotEmpty) {
    print('\n📚 By Subject:');
    subjectCount.forEach((subject, count) {
      print('   $subject: $count');
    });
  }

  if (difficultyCount.isNotEmpty) {
    print('\n🎯 By Difficulty:');
    difficultyCount.forEach((difficulty, count) {
      print('   $difficulty: $count');
    });
  }

  if (ageGroupCount.isNotEmpty) {
    print('\n👥 By Age Group:');
    ageGroupCount.forEach((ageGroup, count) {
      print('   $ageGroup: $count');
    });
  }

  print('─' * 50);
}
