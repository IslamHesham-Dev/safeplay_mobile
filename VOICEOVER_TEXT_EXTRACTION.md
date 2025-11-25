# Voiceover Text Extraction - All Texts for Recording

## 1. WELCOME MESSAGES

### Dashboard Entry (Primary)
**Text:** "Welcome back! Ready to learn and play? Let's explore amazing games and activities together!"

**Audio File:** `welcome_dashboard.mp3`

---

## 2. INTERACTIVE GAMES DETAIL SCREEN

### Static Headers (Create Once)

#### Topics Header
**Text:** "Topics"
**Audio File:** `interactive_topics_header.mp3`
**Page:** 0

#### Learning Goals Header
**Text:** "What You'll Learn"
**Audio File:** `interactive_learning_goals_header.mp3`
**Page:** 1-N (Learning Goals pages)

#### About Header
**Text:** "About The Game"
**Audio File:** `interactive_about_header.mp3`
**Page:** Last page

#### Warning Header
**Text:** "Important Note"
**Audio File:** `interactive_warning_header.mp3`
**Page:** Last page (if warning exists)

---

### Dynamic Content (Per Game)

**Note:** The following will need to be created for EACH interactive game in your system. You'll need to:
1. Get the list of all games from your database/service
2. Extract the title, topics, learning goals, explanation, and warning for each
3. Create audio files following the naming convention

#### Game Title
**Format:** "[GAME_TITLE]"
**Example:** "Math Adventure", "Word Builder", "Pattern Wizard"
**Audio File Pattern:** `interactive_game_title_[game_id].mp3`
**Page:** 0

#### Game Meta (Time & Difficulty)
**Format:** "[X] mins, [DIFFICULTY]"
**Examples:** 
- "15 mins, Easy Peasy"
- "20 mins, Medium"
- "25 mins, Challenge"
**Audio File Pattern:** `interactive_game_meta_[game_id].mp3`
**Page:** 0

#### Topics (List)
**Format:** Each topic as separate text
**Examples:** "Addition", "Subtraction", "Numbers", "Grammar", "Vocabulary"
**Audio File Pattern:** `interactive_topic_[sanitized_topic_name].mp3`
**Note:** Common topics can be reused across games
**Page:** 0

#### Learning Goals (List - 3 per page)
**Format:** Each learning goal as separate text
**Examples:**
- "Practice adding numbers up to 20"
- "Learn to subtract single-digit numbers"
- "Understand number patterns"
**Audio File Pattern:** `interactive_goal_[game_id]_[01, 02, 03...].mp3`
**Page:** 1-N (Learning Goals pages)

#### Game Explanation
**Format:** Full explanation text (can be long)
**Example:** "In this game, you'll help characters solve math problems by choosing the correct answers. Each level gets more challenging as you progress!"
**Audio File Pattern:** `interactive_explanation_[game_id].mp3`
**Page:** Last page

#### Warning (If Present)
**Format:** Full warning text
**Example:** "Please play this game with adult supervision. Some concepts may require help from a parent or teacher."
**Audio File Pattern:** `interactive_warning_[game_id].mp3`
**Page:** Last page (only if game has warning)

---

### Navigation Buttons

#### Previous Button
**Text:** "Previous"
**Audio File:** `button_previous.mp3`
**Used On:** All pages except first

#### Next Button
**Text:** "Next"
**Audio File:** `button_next.mp3`
**Used On:** All pages except last

#### Start Game Button
**Text:** "Start Game"
**Audio File:** `button_start_game.mp3`
**Used On:** Last page

---

## 3. SIMULATION GAMES DETAIL SCREEN

### Static Headers (Create Once)

#### Topics Header
**Text:** "Topics"
**Audio File:** `sim_topics_header.mp3`
**Page:** 0

#### Learning Goals Header
**Text:** "Learning Goals"
**Audio File:** `sim_learning_goals_header.mp3`
**Page:** 1-N (Learning Goals pages)

#### Scientific Explanation Header
**Text:** "Scientific Explanation"
**Audio File:** `sim_scientific_explanation_header.mp3`
**Page:** Last page

#### Warning Header
**Text:** "Important Note"
**Audio File:** `sim_warning_header.mp3`
**Page:** Last page

---

### Dynamic Content (Per Simulation)

**Note:** The following will need to be created for EACH simulation in your system.

#### Simulation Title
**Format:** "[SIMULATION_TITLE]"
**Examples:** "States of Matter", "Energy Forms and Changes", "Gravity Force Lab"
**Audio File Pattern:** `sim_title_[simulation_id].mp3`
**Page:** 0

#### Simulation Meta (Time & Difficulty)
**Format:** "[X] mins, [DIFFICULTY]"
**Examples:**
- "20 mins, Easy Peasy"
- "25 mins, Medium"
- "30 mins, Challenge"
**Audio File Pattern:** `sim_meta_[simulation_id].mp3`
**Page:** 0

#### Topics (List)
**Format:** Each topic as separate text
**Examples:** "Physics", "Matter", "Temperature", "Energy", "Forces"
**Audio File Pattern:** `sim_topic_[sanitized_topic_name].mp3`
**Note:** Common topics can be reused across simulations
**Page:** 0

#### Learning Goals (List - 3 per page)
**Format:** Each learning goal as separate text
**Examples:**
- "Understand the three states of matter: solid, liquid, and gas"
- "See how temperature affects the state of matter"
- "Explore phase changes through interactive experiments"
**Audio File Pattern:** `sim_goal_[simulation_id]_[01, 02, 03...].mp3`
**Page:** 1-N (Learning Goals pages)

#### Scientific Explanation
**Format:** Full explanation text (can be long)
**Example:** "This simulation lets you explore how matter changes between solid, liquid, and gas states. You can adjust temperature and observe the particles move and change state in real-time."
**Audio File Pattern:** `sim_explanation_[simulation_id].mp3`
**Page:** Last page

#### Warning
**Format:** Full warning text
**Example:** "This simulation is designed for educational purposes. Please use it with adult supervision and follow all safety guidelines."
**Audio File Pattern:** `sim_warning_[simulation_id].mp3`
**Page:** Last page

---

### Navigation Buttons

#### Previous Button
**Text:** "Previous"
**Audio File:** `button_previous.mp3` (Reuse from interactive games)

#### Next Button
**Text:** "Next"
**Audio File:** `button_next.mp3` (Reuse from interactive games)

#### Start Sim Button
**Text:** "Start Sim"
**Audio File:** `button_start_sim.mp3`
**Used On:** Last page

---

## 4. COMPLETION MESSAGES

### Interactive Game Completion
**Text (Primary):** "Awesome job! You just completed an interactive game! You earned coins for your hard work. Keep playing and learning!"

**Audio File:** `completion_interactive_game.mp3`
**Plays:** In dashboard after exiting interactive game (with coins sound effect)

**Text (Short Alternative):** "Great work! You finished the game and earned coins! Well done!"

**Audio File:** `completion_interactive_game_short.mp3`

---

### Simulation Game Completion
**Text (Primary):** "Fantastic! You just finished exploring a simulation! You learned something new and earned coins. Keep exploring science and math!"

**Audio File:** `completion_simulation.mp3`
**Plays:** In dashboard after exiting simulation (with coins sound effect)

**Text (Short Alternative):** "Excellent! You completed the simulation and earned coins! Great learning!"

**Audio File:** `completion_simulation_short.mp3`

---

## SUMMARY OF FILES TO CREATE

### Static Files (Create Once - 15 files)
1. `welcome_dashboard.mp3`
2. `interactive_topics_header.mp3`
3. `interactive_learning_goals_header.mp3`
4. `interactive_about_header.mp3`
5. `interactive_warning_header.mp3`
6. `sim_topics_header.mp3`
7. `sim_learning_goals_header.mp3`
8. `sim_scientific_explanation_header.mp3`
9. `sim_warning_header.mp3`
10. `button_previous.mp3`
11. `button_next.mp3`
12. `button_start_game.mp3`
13. `button_start_sim.mp3`
14. `completion_interactive_game.mp3`
15. `completion_simulation.mp3`

### Dynamic Files (Per Game/Simulation)
For each interactive game, create:
- `interactive_game_title_[game_id].mp3`
- `interactive_game_meta_[game_id].mp3`
- `interactive_goal_[game_id]_[index].mp3` (one per learning goal)
- `interactive_explanation_[game_id].mp3`
- `interactive_warning_[game_id].mp3` (only if game has warning)

For each simulation, create:
- `sim_title_[simulation_id].mp3`
- `sim_meta_[simulation_id].mp3`
- `sim_goal_[simulation_id]_[index].mp3` (one per learning goal)
- `sim_explanation_[simulation_id].mp3`
- `sim_warning_[simulation_id].mp3`

For common topics (can be reused):
- `interactive_topic_[topic_name].mp3`
- `sim_topic_[topic_name].mp3`

---

## NEXT STEPS

1. **Extract Game/Simulation Data:**
   - Query your database/service to get all games and simulations
   - Extract: ID, title, topics, learning goals, explanation, warning, time, difficulty

2. **Create Static Audio Files:**
   - Record the 15 static files listed above
   - Use gender-neutral, friendly voice suitable for ages 6-12

3. **Create Dynamic Audio Files:**
   - For each game/simulation, create the required audio files
   - Consider using TTS for highly dynamic content as a fallback

4. **Organize Files:**
   - Follow the file structure in VOICEOVER_GUIDE.md
   - Ensure all filenames match the naming convention exactly

5. **Test Integration:**
   - Implement audio playback in the app
   - Test with actual games/simulations
   - Ensure proper timing with UI transitions

---

**Note:** All texts are gender-neutral and suitable for both boys and girls. The language is encouraging, age-appropriate (6-12 years), and focuses on learning and achievement.

