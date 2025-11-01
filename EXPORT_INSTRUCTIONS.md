# Question Templates Export - Instructions

## Method 1: Use Widget in App (Easiest - Recommended)

Add this widget to your app temporarily to export the data:

1. **Import the widget** in your app (e.g., in a developer/debug menu):
```dart
import 'package:safeplay_mobile/widgets/question_template_exporter.dart';

// Then navigate to it:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const QuestionTemplateExporter()),
);
```

2. **Run your app** and navigate to the export widget
3. Click "Export to JSON"
4. Copy the JSON or save it to a file

## Method 2: Use Web Server (If Chrome doesn't work)

If Chrome browser fails to launch, try web-server instead:

```bash
flutter run -d web-server bin/export_question_templates.dart
```

Then open the URL shown in the console (usually `http://localhost:xxxxx`) in your browser.

### Step 2: Alternative - Use the web app wrapper

I can create a simple web page that downloads the file automatically. Would you like me to create that?

## What You Get

The exported JSON file will contain:
- All documents from the `questionTemplates` collection
- Each document's ID and all fields
- Firestore Timestamps converted to ISO strings
- Metadata (export date, total count)
- Statistics printed to console

## File Structure

```json
{
  "exportedAt": "2024-01-01T12:00:00.000Z",
  "totalCount": 150,
  "collection": "questionTemplates",
  "data": [
    {
      "id": "doc-id",
      "title": "Question Title",
      "type": "multiple-choice",
      // ... all other fields
    }
  ]
}
```

## Troubleshooting

### If Chrome doesn't work:
1. Make sure you have Chrome installed
2. Try: `flutter devices` to see available devices
3. Use any available web browser device

### If you need Windows build:
Install Visual Studio 2019 or later with "Desktop development with C++" workload, then run:
```bash
flutter doctor
```
Follow the instructions to complete setup.

### Alternative: Use Firebase Console
You can also export directly from Firebase Console:
1. Go to Firebase Console
2. Navigate to Firestore Database
3. Select `questionTemplates` collection
4. Use the export function (if available in your Firebase plan)

