# Voiceover - Exact Texts Extracted from Code

## 1. WELCOME MESSAGE (Dashboard Entry)

**Exact Text:**
"Welcome back! Ready to learn and play? Let's explore amazing games and activities together!"

**Audio File Name:** `welcome_dashboard.mp3`

**Location:** Plays when child enters dashboard after login

**Gender-Neutral:** ✅ Yes (uses "you" and "your")

---

## 2. INTERACTIVE GAMES DETAIL SCREEN

### Page 0: Title & Topics Page

#### Header Section (Dynamic - Game Title)
**Text:** `[widget.game.title]` - This is dynamic, will be the actual game title
**Example:** "Math Adventure", "Word Builder", "Pattern Wizard"
**Audio File Pattern:** `interactive_game_title_[game_id].mp3`
**Note:** You need to create one audio file per game with the actual game title

#### Time & Difficulty Tags (Dynamic)
**Text Format:** `"${widget.game.estimatedMinutes} mins"` and `widget.game.difficulty`
**Example:** "15 mins" and "Easy Peasy"
**Audio File Pattern:** `interactive_game_meta_[game_id].mp3`
**Note:** Combine time and difficulty in one audio: "15 mins, Easy Peasy"

#### Topics Section Header (Static)
**Exact Text:** `"TOPICS"`
**Audio File Name:** `interactive_topics_header.mp3`
**Page:** 0

#### Topics List (Dynamic)
**Text:** Each item from `widget.game.topics` array
**Example:** "Addition", "Subtraction", "Numbers"
**Audio File Pattern:** `interactive_topic_[sanitized_topic_name].mp3`
**Note:** Create one file per unique topic (topics can be reused across games)
**Page:** 0

---

### Pages 1 to N: Learning Goals Pages

#### Page Header (Static)
**Exact Text:** `"What You'll Learn"`
**Audio File Name:** `interactive_learning_goals_header.mp3`
**Page:** 1, 2, 3... (all learning goals pages)

#### Learning Goals (Dynamic - 3 per page)
**Text:** Each item from `widget.game.learningGoals` array (3 goals per page)
**Example:** "Practice adding numbers up to 20", "Learn to subtract single-digit numbers"
**Audio File Pattern:** `interactive_goal_[game_id]_[01, 02, 03...].mp3`
**Note:** Number goals sequentially: 01, 02, 03, etc.
**Page:** 1, 2, 3... (depends on number of learning goals)

---

### Last Page: About The Game Page

#### Page Header (Static)
**Exact Text:** `"About The Game"`
**Audio File Name:** `interactive_about_header.mp3`
**Page:** Last page

#### Game Explanation (Dynamic)
**Text:** `widget.game.explanation` - Full explanation text
**Example:** "In this game, you'll help characters solve math problems..."
**Audio File Pattern:** `interactive_explanation_[game_id].mp3`
**Note:** One audio file per game with the full explanation text
**Page:** Last page

#### Warning Section (Conditional - Only if warning exists)

**Warning Header (Static):**
**Exact Text:** `"Important Note"`
**Audio File Name:** `interactive_warning_header.mp3`
**Page:** Last page (only if `widget.game.warning != null`)

**Warning Text (Dynamic):**
**Text:** `widget.game.warning!` - Full warning text
**Example:** "Please play this game with adult supervision..."
**Audio File Pattern:** `interactive_warning_[game_id].mp3`
**Note:** Only create if the game has a warning field populated
**Page:** Last page (only if warning exists)

---

### Navigation Buttons (All Pages)

#### Previous Button (Static)
**Exact Text:** `"Previous"`
**Audio File Name:** `button_previous.mp3`
**Shown On:** All pages except page 0

#### Next Button (Static)
**Exact Text:** `"Next"`
**Audio File Name:** `button_next.mp3`
**Shown On:** All pages except last page

#### Start Game Button (Static)
**Exact Text:** `"Start Game"`
**Audio File Name:** `button_start_game.mp3`
**Shown On:** Last page only

---

## 3. SIMULATION GAMES DETAIL SCREEN

### Page 0: Title & Topics Page

#### Header Section (Dynamic - Simulation Title)
**Text:** `widget.simulation.title` - This is dynamic, will be the actual simulation title
**Example:** "States of Matter", "Energy Forms and Changes", "Gravity Force Lab"
**Audio File Pattern:** `sim_title_[simulation_id].mp3`
**Note:** You need to create one audio file per simulation with the actual title

#### Time & Difficulty Tags (Dynamic)
**Text Format:** `"${widget.simulation.estimatedMinutes} mins"` and `widget.simulation.difficulty`
**Example:** "20 mins" and "Easy Peasy"
**Audio File Pattern:** `sim_meta_[simulation_id].mp3`
**Note:** Combine time and difficulty in one audio: "20 mins, Easy Peasy"

#### Topics Section Header (Static)
**Exact Text:** `"TOPICS"`
**Audio File Name:** `sim_topics_header.mp3`
**Page:** 0

#### Topics List (Dynamic)
**Text:** Each item from `widget.simulation.topics` array
**Example:** "Physics", "Matter", "Temperature"
**Audio File Pattern:** `sim_topic_[sanitized_topic_name].mp3`
**Note:** Create one file per unique topic (topics can be reused across simulations)
**Page:** 0

---

### Pages 1 to N: Learning Goals Pages

#### Page Header (Static)
**Exact Text:** `"Learning Goals"`
**Audio File Name:** `sim_learning_goals_header.mp3`
**Page:** 1, 2, 3... (all learning goals pages)

#### Learning Goals (Dynamic - 3 per page)
**Text:** Each item from `widget.simulation.learningGoals` array (3 goals per page)
**Example:** "Understand the three states of matter", "See how temperature affects matter"
**Audio File Pattern:** `sim_goal_[simulation_id]_[01, 02, 03...].mp3`
**Note:** Number goals sequentially: 01, 02, 03, etc.
**Page:** 1, 2, 3... (depends on number of learning goals)

---

### Last Page: Scientific Explanation Page

#### Page Header (Static)
**Exact Text:** `"Scientific Explanation"`
**Audio File Name:** `sim_scientific_explanation_header.mp3`
**Page:** Last page

#### Scientific Explanation (Dynamic)
**Text:** `widget.simulation.scientificExplanation` - Full explanation text
**Example:** "This simulation lets you explore how matter changes..."
**Audio File Pattern:** `sim_explanation_[simulation_id].mp3`
**Note:** One audio file per simulation with the full explanation text
**Page:** Last page

#### Warning Section (Always Present)

**Warning Header (Static):**
**Exact Text:** `"Important Note"`
**Audio File Name:** `sim_warning_header.mp3`
**Page:** Last page

**Warning Text (Dynamic):**
**Text:** `widget.simulation.warning` - Full warning text
**Example:** "This simulation is designed for educational purposes..."
**Audio File Pattern:** `sim_warning_[simulation_id].mp3`
**Note:** All simulations have warnings, so create one per simulation
**Page:** Last page

---

### Navigation Buttons (All Pages)

#### Previous Button (Static)
**Exact Text:** `"Previous"`
**Audio File Name:** `button_previous.mp3` (Reuse from interactive games)
**Shown On:** All pages except page 0

#### Next Button (Static)
**Exact Text:** `"Next"`
**Audio File Name:** `button_next.mp3` (Reuse from interactive games)
**Shown On:** All pages except last page

#### Start Sim Button (Static)
**Exact Text:** `"Start Sim"`
**Audio File Name:** `button_start_sim.mp3`
**Shown On:** Last page only

---

## 4. COMPLETION MESSAGES (Play with Coins Sound Effect)

### Interactive Game Completion
**Exact Text:** "Awesome job! You just completed an interactive game! You earned coins for your hard work. Keep playing and learning!"

**Audio File Name:** `completion_interactive_game.mp3`

**Location:** Plays in dashboard after exiting interactive game (when coins are awarded)

**Gender-Neutral:** ✅ Yes

**Plays With:** Coins sound effect in dashboard

---

### Simulation Game Completion
**Exact Text:** "Fantastic! You just finished exploring a simulation! You learned something new and earned coins. Keep exploring science and math!"

**Audio File Name:** `completion_simulation.mp3`

**Location:** Plays in dashboard after exiting simulation (when coins are awarded)

**Gender-Neutral:** ✅ Yes

**Plays With:** Coins sound effect in dashboard

---

## FILE STRUCTURE & ORGANIZATION

```
audio/
└── voiceover/
    ├── welcome/
    │   └── welcome_dashboard.mp3
    │
    ├── interactive_games/
    │   ├── headers/
    │   │   ├── interactive_topics_header.mp3
    │   │   ├── interactive_learning_goals_header.mp3
    │   │   ├── interactive_about_header.mp3
    │   │   └── interactive_warning_header.mp3
    │   │
    │   ├── titles/
    │   │   └── interactive_game_title_[game_id].mp3
    │   │   (Example: interactive_game_title_math_adventure.mp3)
    │   │
    │   ├── meta/
    │   │   └── interactive_game_meta_[game_id].mp3
    │   │   (Example: interactive_game_meta_math_adventure.mp3)
    │   │
    │   ├── topics/
    │   │   └── interactive_topic_[topic_name].mp3
    │   │   (Example: interactive_topic_addition.mp3)
    │   │
    │   ├── goals/
    │   │   └── interactive_goal_[game_id]_[index].mp3
    │   │   (Example: interactive_goal_math_adventure_01.mp3)
    │   │
    │   ├── explanations/
    │   │   └── interactive_explanation_[game_id].mp3
    │   │   (Example: interactive_explanation_math_adventure.mp3)
    │   │
    │   └── warnings/
    │       └── interactive_warning_[game_id].mp3
    │       (Example: interactive_warning_math_adventure.mp3)
    │       (Only create if game has warning)
    │
    ├── simulations/
    │   ├── headers/
    │   │   ├── sim_topics_header.mp3
    │   │   ├── sim_learning_goals_header.mp3
    │   │   ├── sim_scientific_explanation_header.mp3
    │   │   └── sim_warning_header.mp3
    │   │
    │   ├── titles/
    │   │   └── sim_title_[simulation_id].mp3
    │   │   (Example: sim_title_states_of_matter.mp3)
    │   │
    │   ├── meta/
    │   │   └── sim_meta_[simulation_id].mp3
    │   │   (Example: sim_meta_states_of_matter.mp3)
    │   │
    │   ├── topics/
    │   │   └── sim_topic_[topic_name].mp3
    │   │   (Example: sim_topic_physics.mp3)
    │   │
    │   ├── goals/
    │   │   └── sim_goal_[simulation_id]_[index].mp3
    │   │   (Example: sim_goal_states_of_matter_01.mp3)
    │   │
    │   ├── explanations/
    │   │   └── sim_explanation_[simulation_id].mp3
    │   │   (Example: sim_explanation_states_of_matter.mp3)
    │   │
    │   └── warnings/
    │       └── sim_warning_[simulation_id].mp3
    │       (Example: sim_warning_states_of_matter.mp3)
    │
    ├── buttons/
    │   ├── button_previous.mp3
    │   ├── button_next.mp3
    │   ├── button_start_game.mp3
    │   └── button_start_sim.mp3
    │
    └── completion/
        ├── completion_interactive_game.mp3
        └── completion_simulation.mp3
```

---

## SUMMARY OF STATIC TEXTS (Create Once)

### Welcome
1. **"Welcome back! Ready to learn and play? Let's explore amazing games and activities together!"**
   - File: `welcome_dashboard.mp3`

### Interactive Games Headers
2. **"TOPICS"**
   - File: `interactive_topics_header.mp3`
3. **"What You'll Learn"**
   - File: `interactive_learning_goals_header.mp3`
4. **"About The Game"**
   - File: `interactive_about_header.mp3`
5. **"Important Note"**
   - File: `interactive_warning_header.mp3`

### Simulation Games Headers
6. **"TOPICS"**
   - File: `sim_topics_header.mp3`
7. **"Learning Goals"**
   - File: `sim_learning_goals_header.mp3`
8. **"Scientific Explanation"**
   - File: `sim_scientific_explanation_header.mp3`
9. **"Important Note"**
   - File: `sim_warning_header.mp3`

### Buttons
10. **"Previous"**
    - File: `button_previous.mp3`
11. **"Next"**
    - File: `button_next.mp3`
12. **"Start Game"**
    - File: `button_start_game.mp3`
13. **"Start Sim"**
    - File: `button_start_sim.mp3`

### Completion Messages
14. **"Awesome job! You just completed an interactive game! You earned coins for your hard work. Keep playing and learning!"**
    - File: `completion_interactive_game.mp3`
15. **"Fantastic! You just finished exploring a simulation! You learned something new and earned coins. Keep exploring science and math!"**
    - File: `completion_simulation.mp3`

---

## DYNAMIC CONTENT (Per Game/Simulation)

For each interactive game, you need to create:
- `interactive_game_title_[game_id].mp3` - The game's title
- `interactive_game_meta_[game_id].mp3` - "X mins, [Difficulty]"
- `interactive_goal_[game_id]_[01, 02, 03...].mp3` - One per learning goal
- `interactive_explanation_[game_id].mp3` - Full explanation text
- `interactive_warning_[game_id].mp3` - Only if game has warning

For each simulation, you need to create:
- `sim_title_[simulation_id].mp3` - The simulation's title
- `sim_meta_[simulation_id].mp3` - "X mins, [Difficulty]"
- `sim_goal_[simulation_id]_[01, 02, 03...].mp3` - One per learning goal
- `sim_explanation_[simulation_id].mp3` - Full scientific explanation text
- `sim_warning_[simulation_id].mp3` - Warning text

For topics (can be reused):
- `interactive_topic_[topic_name].mp3` - One per unique topic
- `sim_topic_[topic_name].mp3` - One per unique topic

---

## PAGE BREAKDOWN

### Interactive Games Detail Screen

**Page 0:**
- Game Title (dynamic)
- Time & Difficulty (dynamic)
- "TOPICS" header (static)
- Topics list (dynamic)
- Button: "Next" (static)

**Page 1-N (Learning Goals):**
- "What You'll Learn" header (static)
- Learning Goal 1 (dynamic)
- Learning Goal 2 (dynamic)
- Learning Goal 3 (dynamic)
- Button: "Previous" (static) + "Next" (static)

**Last Page:**
- "About The Game" header (static)
- Game Explanation (dynamic)
- "Important Note" header (static) - if warning exists
- Warning Text (dynamic) - if warning exists
- Button: "Previous" (static) + "Start Game" (static)

---

### Simulation Games Detail Screen

**Page 0:**
- Simulation Title (dynamic)
- Time & Difficulty (dynamic)
- "TOPICS" header (static)
- Topics list (dynamic)
- Button: "Next" (static)

**Page 1-N (Learning Goals):**
- "Learning Goals" header (static)
- Learning Goal 1 (dynamic)
- Learning Goal 2 (dynamic)
- Learning Goal 3 (dynamic)
- Button: "Previous" (static) + "Next" (static)

**Last Page:**
- "Scientific Explanation" header (static)
- Scientific Explanation (dynamic)
- "Important Note" header (static)
- Warning Text (dynamic)
- Button: "Previous" (static) + "Start Sim" (static)

---

## NOTES

1. **All texts are gender-neutral** - Use "you", "your" instead of gender-specific pronouns
2. **Dynamic content** - Game/simulation titles, learning goals, explanations, and warnings are pulled from the database and will need individual audio files
3. **File naming** - Use lowercase, underscores, and sanitize dynamic parts (remove spaces, special characters)
4. **Completion messages** - Play automatically when returning to dashboard after completing a game/simulation, synchronized with coins sound effect
5. **Page numbering** - Pages are 0-indexed in code, but for audio organization, you can think of them as Page 1, Page 2, etc.

---

**Last Updated:** Based on code extraction from web_game_detail_screen.dart and simulation_detail_screen.dart



