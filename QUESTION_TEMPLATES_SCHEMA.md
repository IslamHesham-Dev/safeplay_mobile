# Question Templates Collection Schema

## Collection: `curriculumQuestionTemplates`

This collection stores structured, curriculum-aligned question templates that teachers can use to build activities. Each template is designed to work seamlessly with the game system, tracking system, and points/motivation mechanism.

**Note:** This is a new collection separate from the old `questionTemplates` collection. The new collection (`curriculumQuestionTemplates`) contains structured curriculum questions for Math, English, and Science, with proper game type mappings, points, and tracking metadata. The old `questionTemplates` collection remains for backwards compatibility.

## Document Structure

### Core Fields

#### Identification
- `id` (string, auto-generated): Unique template identifier
  - Format: `{subject}_{ageGroup}_{number}_{topic}`
  - Example: `math_junior_001_counting_subtraction`

- `title` (string, required): Short, descriptive title
  - Example: "Counting and Subtraction"

#### Question Content
- `type` (string, enum, required): Question type
  - Values: `multipleChoice`, `trueFalse`, `textInput`, `dragDrop`, `matching`, `sequencing`
  - Used to determine appropriate game type

- `prompt` (string, required): The question text
  - Clear, age-appropriate language
  - Example: "When counting back, what word is another way of saying 'take away'?"

- `options` (array of strings): Answer choices (for multiple choice, matching, etc.)
  - Empty array for text input questions
  - Example: `["Addition", "Subtraction", "Multiplication", "Division"]`

- `correctAnswer` (string | number | array, required): The correct answer
  - Can be string, number, or array for multiple correct answers
  - Example: `"Subtraction"` or `6` or `["option1", "option2"]`

- `explanation` (string, optional): Explanation shown after answering
  - Helps children understand why the answer is correct
  - Example: "Subtraction means taking away or removing something."

- `hint` (string, optional): Hint shown if child struggles
  - Scaffolded support for challenging content
  - Example: "Think about what you do when you 'take away' items."

#### Educational Metadata

- `skills` (array of strings, required): Skills this question teaches
  - Used for tracking progress, recommendations, and analytics
  - Example: `["counting", "subtraction", "vocabulary"]`

- `subjects` (array of strings, required): Subjects this question covers
  - Values: `math`, `science`, `reading`, `writing`
  - Used for filtering and subject-specific games
  - Example: `["math"]`

- `ageGroups` (array of strings, required): Age groups this question is suitable for
  - Values: `junior` (6-8), `bright` (9-12)
  - Used for age-appropriate game selection
  - Example: `["junior"]`

- `topics` (array of strings, required): Curriculum topics
  - Used for organizing and tracking progress by topic
  - Example: `["Number", "Counting"]`

- `difficultyLevel` (string, enum, required): Difficulty rating
  - Values: `easy`, `medium`, `hard`
  - Used for adaptive difficulty and points calculation
  - Example: `"easy"`

#### Game System Integration

- `gameTypes` (array of strings, required): Compatible game types
  - List of games that can effectively present this question
  - Values: 
    - Junior: `numberGridRace`, `koalaCounterAdventure`, `ordinalDragOrder`, `patternBuilder`, `memoryMatch`, `wordBuilder`, `storySequencer`
    - Bright: `fractionNavigator`, `inverseOperationChain`, `dataVisualization`, `cartesianGrid`, plus universal games
  - Example: `["numberGridRace", "koalaCounterAdventure"]`

- `recommendedGameType` (string, required): Best game type for this question
  - Single recommended game that works best
  - Used by SmartGameTypeService for automatic selection
  - Example: `"numberGridRace"`

#### Points & Motivation

- `points` (number, required): Base points for correct answer
  - Junior (6-8): Typically 15-25 points per question
  - Bright (9-12): Typically 25-35 points per question
  - Example: `20`

- `estimatedTimeSeconds` (number, required): Expected time to answer
  - Used for time-based bonuses and tracking
  - Junior: 25-40 seconds typically
  - Bright: 30-50 seconds typically
  - Example: `30`

#### Tracking & Analytics

- `metadata` (object, optional): Additional tracking data
  - `citation` (string): Curriculum reference (e.g., "PYP 1")
  - `learningObjective` (string): What the child should learn
  - `prerequisiteSkills` (array): Skills needed before attempting
  - `followUpSkills` (array): Skills this prepares for
  - Example:
    ```json
    {
      "citation": "PYP K",
      "learningObjective": "Understand subtraction vocabulary",
      "prerequisiteSkills": [],
      "followUpSkills": ["subtraction-operations"]
    }
    ```

#### Status & Lifecycle

- `isActive` (boolean, required): Whether template is available for use
  - `true`: Teachers can use this template
  - `false`: Template is archived/disabled
  - Example: `true`

- `createdAt` (timestamp, auto-generated): When template was created
- `updatedAt` (timestamp, auto-updated): Last modification time

## Complete Example Document

```json
{
  "id": "math_junior_001_counting_subtraction",
  "title": "Counting and Subtraction",
  "type": "multipleChoice",
  "prompt": "When counting back, what word is another way of saying 'take away'?",
  "options": ["Addition", "Subtraction", "Multiplication", "Division"],
  "correctAnswer": "Subtraction",
  "explanation": "Subtraction means taking away or removing something.",
  "hint": "Think about what you do when you 'take away' items.",
  "points": 15,
  "skills": ["counting", "subtraction", "vocabulary"],
  "subjects": ["math"],
  "ageGroups": ["junior"],
  "topics": ["Number", "Counting"],
  "difficultyLevel": "easy",
  "estimatedTimeSeconds": 30,
  "gameTypes": ["numberGridRace", "koalaCounterAdventure"],
  "recommendedGameType": "numberGridRace",
  "isActive": true,
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "metadata": {
    "citation": "PYP K",
    "learningObjective": "Understand subtraction vocabulary",
    "prerequisiteSkills": [],
    "followUpSkills": ["subtraction-operations"]
  }
}
```

## Design Principles

### 1. Game Type Mapping
Each question maps to game types that are:
- **Age-appropriate**: Junior games are simpler, more visual
- **Question-type specific**: Multiple choice → quiz games, drag-drop → drag games
- **Subject-appropriate**: Math → number games, Reading → word games

### 2. Points System
- **Base points**: Age-appropriate base (Junior: 15-25, Bright: 25-35)
- **Difficulty multiplier**: Easy (1x), Medium (1.5x), Hard (2x)
- **Time bonus**: Faster correct answers get bonus points
- **Perfect score bonus**: Complete activity correctly for extra points

### 3. Tracking & Analytics
Every field supports future tracking:
- **Skills**: Track skill mastery across questions
- **Topics**: Track progress by curriculum topic
- **Difficulty**: Track which difficulty levels children master
- **Game types**: Track which games children enjoy/succeed with
- **Time spent**: Track efficiency and engagement

### 4. Teacher-Child Synchronization
- **isActive**: Teachers control which templates are available
- **metadata**: Teachers can see curriculum alignment
- **gameTypes**: Teachers see compatible games when creating activities
- **points**: Teachers understand point values when building activities

### 5. Age Group Differentiation

#### Junior (6-8) Focus:
- Simple vocabulary and concepts
- Visual, interactive games
- Higher points (reward-focused)
- Shorter time expectations
- Immediate feedback

#### Bright (9-12) Focus:
- Complex concepts and strategies
- Strategic, mastery-focused games
- Points based on mastery
- Longer time for complex problems
- Detailed explanations

## Usage in Activity Builder

When a teacher creates an activity:
1. Filters templates by `subjects` and `ageGroups`
2. Selects templates
3. System recommends `recommendedGameType` or suggests from `gameTypes`
4. Activity inherits `points`, `skills`, `topics` from selected templates
5. Published activity uses templates' metadata for tracking

## Usage in Child Games

When a child plays a game:
1. Game loads questions from selected templates
2. Questions use `recommendedGameType` for game presentation
3. Points are calculated based on `points`, `difficultyLevel`, time, accuracy
4. Child's solution is logged with template `id` for tracking
5. Skills and topics are tracked for analytics

## Future Extensions

The schema supports:
- **Adaptive difficulty**: Use `difficultyLevel` and `prerequisiteSkills`
- **Skill mastery tracking**: Track progress across `skills`
- **Topic-based recommendations**: Recommend activities by `topics`
- **Game performance analytics**: Track which `gameTypes` work best
- **Time-based analytics**: Compare `estimatedTimeSeconds` vs actual time

