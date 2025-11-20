# Question Templates Export Guide

## Overview

This guide explains how to export question templates to JSON format directly from the source code, **without needing Firebase permissions** or database access.

## How It Works

The questions are not magically stored in Firebase - they're defined in seeding scripts in the codebase. This export tool extracts the question data directly from those scripts and converts them to JSON format.

## Source Files

The question templates are defined in:
- `lib/scripts/seed_comprehensive_question_templates.dart` - Main comprehensive seeder
- `lib/services/database_initializer.dart` - Alternative curriculum-aligned seeder

The export tool reads from `seed_comprehensive_question_templates.dart`.

## Usage

### Option 1: Using the Widget (Recommended)

1. **Add the widget to your app temporarily:**

   In your router or wherever you want to access it:
   ```dart
   import 'package:safeplay_mobile/widgets/question_template_exporter.dart';
   
   // Add a route or button to navigate to:
   QuestionTemplateExporter()
   ```

2. **Run the app and navigate to the export widget**

3. **Click "Export to JSON"** - This extracts all templates from source code (no Firebase needed!)

4. **Copy or save the JSON** - Use the "Copy JSON" or "Save to File" buttons

### Option 2: Using the Export Function Directly

If you want to use the export function in your own code:

```dart
import 'package:safeplay_mobile/scripts/extract_question_templates_from_source.dart';

// Get JSON string
final jsonString = exportQuestionTemplatesToJson();
print(jsonString);

// Or parse it
import 'dart:convert';
final data = jsonDecode(jsonString);
final templates = data['templates'] as List;
print('Total templates: ${templates.length}');
```

## Output Format

The JSON export includes:

```json
{
  "metadata": {
    "exportDate": "2024-01-01T12:00:00.000Z",
    "totalTemplates": 30,
    "source": "seed_comprehensive_question_templates.dart"
  },
  "templates": [
    {
      "title": "Skip Counting by 2s",
      "type": "multiple-choice",
      "prompt": "What comes next in the pattern? 2, 4, 6, 8, __",
      "options": ["9", "10", "11", "12"],
      "correctAnswer": "10",
      "skills": ["skip-counting", "number-patterns"],
      "points": 20,
      "explanation": "We are counting by 2s, so 8 + 2 = 10",
      "hint": "Add 2 to the last number",
      "ageGroups": ["junior"],
      "subjects": ["math"],
      "gameTypes": ["numberGridRace"],
      "difficulty": "easy",
      "duration": 2
    },
    // ... more templates
  ]
}
```

## Template Categories

The export includes templates for:

1. **Junior Explorer (6-8) Mathematics:**
   - Number Grid Race
   - Koala Counter's Adventure
   - Ordinal Drag Order
   - Pattern Builder

2. **Junior Explorer (6-8) English:**
   - Memory Match
   - Word Builder
   - Story Sequencer

3. **Bright Minds (9-12) Mathematics:**
   - Fraction Navigator
   - Inverse Operation Chain
   - Data Visualization
   - Cartesian Grid

4. **Bright Minds (9-12) English:**
   - Memory Match
   - Word Builder
   - Story Sequencer

5. **Mindful Exercises:**
   - For both age groups
   - Breathing exercises, gratitude practice, etc.

## Advantages

✅ **No Firebase permissions needed** - Reads directly from source code  
✅ **No network required** - Works offline  
✅ **Always up-to-date** - Extracts current data from codebase  
✅ **No authentication needed** - Works immediately  
✅ **Fast** - Instant extraction, no database queries  

## Troubleshooting

### Error: "No such file or directory"
- Make sure you're running the app from the `safeplay_mobile` directory
- Check that `lib/scripts/extract_question_templates_from_source.dart` exists

### Empty or incomplete JSON
- Verify that `seed_comprehensive_question_templates.dart` has all the template data
- Check for any compilation errors in the extractor script

### Widget not showing up
- Make sure you've imported the widget correctly
- Check that the route is properly configured

## Notes

- The export extracts templates from `seed_comprehensive_question_templates.dart`
- If you've modified the seeding scripts, the export will reflect those changes
- Mindful exercises use `ActivitySubject.social` (Social Studies) as the subject category
- All enum values are converted to strings (e.g., `QuestionType.multipleChoice` → `"multiple-choice"`)

## Next Steps

After exporting:
1. Save the JSON file to your desired location
2. Use it for game development, testing, or documentation
3. You can import it into other tools or systems as needed







