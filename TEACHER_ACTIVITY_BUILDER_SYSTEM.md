# Teacher Activity Builder System - Complete Implementation

## Overview

This document describes the comprehensive teacher activity creation system that allows teachers to create, configure, and publish educational games for children. The system includes smart game type selection, points/leveling system, progress logging, and publishing validation.

## Architecture

### Core Services

#### 1. `SmartGameTypeService`
**Location:** `lib/services/smart_game_type_service.dart`

**Purpose:** Intelligently maps question types to optimal game types based on subject, age group, and question characteristics.

**Key Features:**
- **Automatic Game Type Selection:** Analyzes question templates and recommends the best game type
- **Question Type Mapping:** Maps question types (multiple choice, drag-drop, sequencing, etc.) to optimal game types
- **Subject-Aware Selection:** Considers subject (math, reading, etc.) when selecting games
- **Age Group Optimization:** Different game recommendations for Junior (6-8) vs Bright (9-12)
- **Points Calculation:** Calculates recommended points based on difficulty and age group

**Methods:**
- `determineBestGameType()` - Analyzes templates and recommends game type
- `calculateRecommendedPoints()` - Calculates optimal points for activity
- `getRecommendedGameTypes()` - Gets all suitable games for subject/age combo

**Game Type Mapping Examples:**
- **Junior Math + Multiple Choice** → `NumberGridRace` or `KoalaCounterAdventure`
- **Junior Reading + DragDrop** → `WordBuilder`
- **Junior Reading + Sequencing** → `StorySequencer`
- **Bright Math + Multiple Choice** → `FractionNavigator`
- **Bright Math + Matching** → `InverseOperationChain`

#### 2. `PointsLevelingService`
**Location:** `lib/services/points_leveling_service.dart`

**Purpose:** Manages points calculation, level progression, and achievement system.

**Key Features:**
- **Dynamic Points Calculation:** Points based on:
  - Age group (Junior: 15 base, Bright: 20 base)
  - Difficulty (Easy: 1x, Medium: 1.5x, Hard: 2x)
  - Time efficiency (faster = more bonus)
  - Accuracy (correct = full points, attempts = 20%)
  - Streak bonuses (consecutive good performance)
- **Level System:**
  - Junior: 10 levels (0, 50, 150, 300, 500, 750, 1050, 1400, 1800, 2250 points)
  - Bright: 10 levels (0, 100, 250, 450, 700, 1000, 1350, 1750, 2200, 2700 points)
- **Progress Tracking:** Tracks level progress, points to next level, achievements

**Methods:**
- `calculateSessionPoints()` - Calculates total points for a game session
- `getLevel()` - Gets current level based on total points
- `getPointsForNextLevel()` - Points needed for next level
- `getLevelProgress()` - Progress percentage to next level (0.0 to 1.0)
- `updateChildProgress()` - Updates progress and checks for level up
- `getAchievementSuggestions()` - Suggests achievements based on progress

**Point Calculation Formula:**
```dart
Base Points = Age Group Base (15 for Junior, 20 for Bright)
Difficulty Multiplier = 1.0 (Easy) | 1.5 (Medium) | 2.0 (Hard)
Time Multiplier = 1.5 (fast) | 1.0 (normal) | 0.8 (slow)
Accuracy Multiplier = 1.0 (correct) | 0.2 (attempt)
Streak Bonus = (streak * 5).clamp(0, 50)

Total Points = (Base * Difficulty * Time * Accuracy) + Streak Bonus
```

#### 3. `ActivityBuilderScreen`
**Location:** `lib/screens/teacher/activity_builder_screen.dart`

**Purpose:** Main UI for teachers to create and publish activities.

**Key Features:**
- **Step-by-Step Wizard:**
  1. **Filter Templates** - Select subject, age group, difficulty
  2. **Select Templates** - Browse and select question templates
  3. **Configure Activity** - Set title, description, game type, points
  4. **Review & Publish** - Final review before publishing
- **Template Library:**
  - Filter by subject, age group, difficulty
  - Search templates by title, prompt, or skills
  - Visual template selection with checkboxes
  - Template preview (title, prompt, skills)
- **Smart Game Type Recommendation:**
  - Automatically suggests best game type based on selected templates
  - Shows recommended game types with star indicator
  - Manual override available
- **Activity Configuration:**
  - Title and description
  - Learning objectives (one per line)
  - Points (auto-calculated, can be customized)
  - Duration (minutes)
  - Game type selection

**Workflow:**
1. Teacher selects subject and age group
2. System loads available templates
3. Teacher selects templates (can search)
4. System recommends game type and points
5. Teacher configures activity details
6. Teacher reviews and publishes

### Supporting Services

#### 4. `ChildSubmissionService`
**Location:** `lib/services/child_submission_service.dart`

**Purpose:** Logs child game sessions and solutions to database.

**Key Collections:**
- `gameSessions` - Tracks game sessions (start, progress, completion)
- `gameResponses` - Logs individual question answers
- `childProgress` - Tracks overall child progress

**Key Methods:**
- `startGameSession()` - Creates new game session
- `saveGameResponse()` - Logs individual answer with solution
- `updateGameSession()` - Updates session progress
- `completeGameSession()` - Marks session as completed
- `getChildResponses()` - Retrieves child solutions for teacher review

**Data Logged for Each Answer:**
- Question ID and template ID
- User's answer (exact submission)
- Correct answer
- Is correct (boolean)
- Points earned
- Time spent (seconds)
- Timestamp
- Response metadata (any additional context)

#### 5. `PublishingService`
**Location:** `lib/services/publishing_service.dart`

**Purpose:** Validates and publishes activities with safety checks.

**Key Features:**
- **Validation Checks:**
  - At least one question template selected
  - Game type is selected
  - Title and description provided
  - Learning objectives defined
  - Age group and subject match
- **Publishing States:**
  - `draft` - Created but not published
  - `published` - Published and visible to children
  - `archived` - Hidden but not deleted

**Methods:**
- `publishActivity()` - Validates and publishes activity
- `unpublishActivity()` - Unpublishes (removes from children's view)
- `validateActivity()` - Checks activity validity

## Points & Leveling System

### Points Calculation

**Base Points per Question:**
- Junior (6-8): 15 base points
- Bright (9-12): 20 base points

**Difficulty Multipliers:**
- Easy: 1.0x
- Medium: 1.5x
- Hard: 2.0x

**Time Bonuses:**
- Optimal time (Junior: 30s, Bright: 20s): +50% bonus
- Slow (3x optimal): -20% penalty

**Accuracy:**
- Correct answer: Full points
- Attempt (wrong): 20% of points

**Streak Bonuses:**
- Each day streak: +5 points
- Maximum streak bonus: 50 points

**Completion Bonuses:**
- Perfect score: +50 points (Junior) or +75 points (Bright)
- Speed bonus (fast perfect): +25 points (Junior) or +35 points (Bright)

### Level Progression

**Junior Levels (6-8):**
1. Level 1: 0 points
2. Level 2: 50 points
3. Level 3: 150 points
4. Level 4: 300 points
5. Level 5: 500 points
6. Level 6: 750 points
7. Level 7: 1,050 points
8. Level 8: 1,400 points
9. Level 9: 1,800 points
10. Level 10: 2,250 points

**Bright Levels (9-12):**
1. Level 1: 0 points
2. Level 2: 100 points
3. Level 3: 250 points
4. Level 4: 450 points
5. Level 5: 700 points
6. Level 6: 1,000 points
7. Level 7: 1,350 points
8. Level 8: 1,750 points
9. Level 9: 2,200 points
10. Level 10: 2,700 points

### Achievements

**Milestone Achievements:**
- Points milestones (e.g., 100, 250, 500, 1000 points)
- Lesson completion milestones (e.g., 5, 10, 25, 50 lessons)
- Level up achievements (e.g., Level 3, 5, 7, 10)

**Performance Achievements:**
- Perfect score achievements
- Streak achievements
- Mastery achievements (high accuracy across topics)

## Question Type → Game Type Mapping

### Junior (6-8) Age Group

**Math Subject:**
- Multiple Choice / Text Input → `NumberGridRace` or `KoalaCounterAdventure`
- Drag Drop → `OrdinalDragOrder`
- Sequencing → `PatternBuilder`
- Matching → `MemoryMatch`
- True/False → `NumberGridRace`

**Reading Subject:**
- Multiple Choice / True/False → `MemoryMatch`
- Drag Drop → `WordBuilder`
- Sequencing → `StorySequencer`
- Matching → `MemoryMatch`
- Text Input → `WordBuilder`

### Bright (9-12) Age Group

**Math Subject:**
- Multiple Choice / Text Input → `FractionNavigator`
- Drag Drop / Sequencing → `DataVisualization`
- Matching → `InverseOperationChain`
- True/False → `FractionNavigator`

**Reading Subject:**
- Multiple Choice / True/False → `MemoryMatch`
- Drag Drop → `WordBuilder`
- Sequencing → `StorySequencer`
- Matching → `MemoryMatch`
- Text Input → `WordBuilder`

## Child Progress Logging

### What Gets Logged

**Game Session:**
- Session ID, child ID, activity ID
- Game type
- Start time, completion time
- Total time spent
- Points earned
- Completion status

**Individual Answers:**
- Question ID and template ID
- User's exact answer
- Correct answer
- Is correct (boolean)
- Points earned for this question
- Time spent on question
- Timestamp
- Response metadata (hints used, attempts, etc.)

### Database Collections

**`gameSessions/{sessionId}`:**
```json
{
  "childId": "child123",
  "gameActivityId": "activity456",
  "gameType": "numberGridRace",
  "startedAt": "2024-01-15T10:00:00Z",
  "completedAt": "2024-01-15T10:15:00Z",
  "pointsEarned": 150,
  "timeSpentSeconds": 900,
  "isCompleted": true,
  "responses": [...]
}
```

**`gameResponses/{responseId}`:**
```json
{
  "childId": "child123",
  "sessionId": "session789",
  "questionId": "q1",
  "questionTemplateId": "template123",
  "userAnswer": "10",
  "correctAnswer": "10",
  "isCorrect": true,
  "pointsEarned": 20,
  "timeSpentSeconds": 15,
  "answeredAt": "2024-01-15T10:05:00Z",
  "responseMetadata": {
    "attempts": 1,
    "hintUsed": false
  }
}
```

### Teacher Access

Teachers can access child solutions through:
- `ChildSubmissionService.getChildResponses()` - Get all responses for a child
- `ChildSubmissionService.getChildActivityProgress()` - Get progress for specific activity
- `ChildSubmissionService.getChildAnalytics()` - Get learning analytics

## Usage Example

### Creating an Activity

```dart
// 1. Teacher navigates to Activity Builder
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ActivityBuilderScreen(),
  ),
);

// 2. Teacher filters templates (Step 1)
// Selects: Math, Junior (6-8), Easy

// 3. Teacher selects templates (Step 2)
// Selects 5 templates about skip counting

// 4. System automatically recommends:
// - Game Type: NumberGridRace (for skip counting patterns)
// - Points: 150 (5 questions * 15 base * 2.0 difficulty)

// 5. Teacher configures (Step 3):
// - Title: "Skip Counting Adventure"
// - Description: "Count by 2s and 5s!"
// - Learning Objectives: "Skip counting by 2s", "Number patterns"
// - Points: 150 (recommended, can adjust)
// - Duration: 5 minutes

// 6. Teacher reviews and publishes (Step 4)
// System validates and publishes activity
```

### Child Playing Game

```dart
// 1. Child selects activity
// 2. System starts game session
final sessionId = await childSubmissionService.startGameSession(
  childId: childId,
  gameActivityId: activityId,
  gameType: gameType,
);

// 3. Child answers questions
// System logs each answer:
await childSubmissionService.saveGameResponse(
  GameResponse(
    questionId: 'q1',
    userAnswer: '10',
    correctAnswer: '10',
    isCorrect: true,
    pointsEarned: 20,
    timeSpentSeconds: 15,
    ...
  ),
);

// 4. Game completes
// System calculates total points:
final totalPoints = await pointsLevelingService.calculateSessionPoints(
  childId: childId,
  correctAnswers: 4,
  totalQuestions: 5,
  timeSpentSeconds: 300,
  difficulty: Difficulty.easy,
  ageGroup: AgeGroup.junior,
);

// 5. System updates progress
final levelUpResult = await pointsLevelingService.updateChildProgress(
  childId: childId,
  pointsEarned: totalPoints,
  ageGroup: AgeGroup.junior,
);

// 6. If level up, show celebration
if (levelUpResult.leveledUp) {
  showLevelUpCelebration(levelUpResult);
}
```

### Teacher Reviewing Progress

```dart
// Get all responses for a child
final responses = await childSubmissionService.getChildResponses(
  childId: childId,
  activityId: activityId,
);

// Analyze answers
for (final response in responses) {
  print('Question: ${response.questionId}');
  print('User Answer: ${response.userAnswer}');
  print('Correct Answer: ${response.correctAnswer}');
  print('Is Correct: ${response.isCorrect}');
  print('Time Spent: ${response.timeSpentSeconds}s');
}
```

## Integration Points

### Teacher Dashboard
- Link to `ActivityBuilderScreen` for creating activities
- View published activities
- View child progress and solutions

### Junior Dashboard
- Display activities as games
- Launch games through `JuniorGameLauncher`
- Show points and level progress

### Game Player Screens
- Integrate `ChildSubmissionService` to log answers
- Integrate `PointsLevelingService` to calculate points
- Show level-up celebrations

## Future Enhancements

### Mindful/Break Games
- Short, non-academic games for emotional health
- Breathing exercises, color matching, simple puzzles
- No points, just fun breaks

### Advanced Analytics
- Detailed learning analytics for teachers
- Progress trends, difficulty analysis
- Personalized recommendations

### Collaborative Features
- Team-based challenges
- Cooperative games
- Peer learning activities

## Conclusion

This comprehensive system provides teachers with a powerful tool to create engaging educational games while tracking child progress and solutions. The smart game type selection ensures children get the best learning experience for each question type, while the points/leveling system provides motivation and achievement tracking.

