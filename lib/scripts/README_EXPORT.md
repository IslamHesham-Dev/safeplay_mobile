# Question Templates Export Script

This script exports all question templates from the Firebase `questionTemplates` collection to a JSON file.

## Usage

### Method 1: Run as Flutter app (Recommended)

Create a temporary entry point or run directly:

```bash
cd safeplay_mobile
flutter run lib/scripts/export_question_templates.dart
```

### Method 2: Run with Dart (if Firebase Core supports it)

```bash
cd safeplay_mobile
dart run lib/scripts/export_question_templates.dart
```

### Method 3: Create a simple Flutter app wrapper

You can create a simple main entry point that calls the export function:

```dart
// Create a file: bin/export_questions.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safeplay_mobile/firebase_options.dart';
import 'package:safeplay_mobile/lib/scripts/export_question_templates.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await exportQuestionTemplates();
}
```

Then run:
```bash
flutter run bin/export_questions.dart
```

## Output

The script will create a file named `question_templates_export.json` in the project root directory with the following structure:

```json
{
  "exportedAt": "2024-01-01T12:00:00.000Z",
  "totalCount": 150,
  "collection": "questionTemplates",
  "data": [
    {
      "id": "document-id",
      "title": "Question Title",
      "type": "multiple-choice",
      "prompt": "Question prompt...",
      "options": ["Option 1", "Option 2"],
      "correctAnswer": "Option 1",
      // ... other fields
    }
    // ... more questions
  ]
}
```

## Features

- ✅ Exports all documents from `questionTemplates` collection
- ✅ Converts Firestore Timestamps to ISO 8601 strings
- ✅ Converts Firestore GeoPoints to JSON objects
- ✅ Handles nested objects and arrays recursively
- ✅ Pretty-printed JSON output for readability
- ✅ Includes export metadata (timestamp, count, collection name)
- ✅ Prints statistics about the exported data

## Statistics

The script prints statistics about:
- Total count
- Distribution by question type
- Distribution by subject
- Distribution by difficulty level
- Distribution by age group

## Notes

- The script preserves all document IDs
- Firestore-specific types are converted to JSON-compatible formats
- The export includes a timestamp of when the export was performed
- All data is exported in a flat structure with document IDs at the root level of each object



