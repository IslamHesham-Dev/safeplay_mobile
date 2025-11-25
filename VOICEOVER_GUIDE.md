# Voiceover Guide for SafePlay Mobile App

## Table of Contents
1. [Welcome Messages](#welcome-messages)
2. [Interactive Games Detail Screen](#interactive-games-detail-screen)
3. [Simulation Games Detail Screen](#simulation-games-detail-screen)
4. [Completion Messages](#completion-messages)
5. [Audio File Naming Convention](#audio-file-naming-convention)
6. [File Structure](#file-structure)

---

## Welcome Messages

### Dashboard Entry (Gender-Neutral)
**Text:** "Welcome back! Ready to learn and play? Let's explore amazing games and activities together!"

**Audio File:** `welcome_dashboard.mp3`

**Alternative (More Energetic):**
**Text:** "Hey there! Welcome to your learning adventure! Pick a game and let's have some fun while learning!"

**Audio File:** `welcome_dashboard_alt.mp3`

---

## Interactive Games Detail Screen

### Page Structure
- **Page 0:** Title + Topics
- **Pages 1-N:** Learning Goals (3 per page)
- **Last Page:** About The Game + Warning (if exists)

### Page 0: Title & Topics Page

#### Header Section
**Text:** "[GAME_TITLE]" (Dynamic - use game title)
**Audio File:** `interactive_game_title_[game_id].mp3`
**Note:** You'll need to create separate audio files for each game title

**Time & Difficulty Tags**
**Text:** "[X] mins, [DIFFICULTY]" (e.g., "15 mins, Easy Peasy")
**Audio File:** `interactive_game_meta_[game_id].mp3`
**Note:** Dynamic content - may need TTS or individual files per game

#### Topics Section
**Section Header:**
**Text:** "Topics"
**Audio File:** `interactive_topics_header.mp3`

**Individual Topics:**
**Text:** Each topic from the game's topics list (Dynamic)
**Audio File:** `interactive_topic_[topic_name].mp3` (sanitize topic name for filename)
**Note:** Topics are dynamic - you may need TTS or create files for common topics

---

### Pages 1-N: Learning Goals Pages

#### Page Header
**Text:** "What You'll Learn"
**Audio File:** `interactive_learning_goals_header.mp3`

#### Individual Learning Goals
**Text:** Each learning goal text (Dynamic - 3 per page)
**Audio Files:** 
- `interactive_goal_[game_id]_[goal_index].mp3`
- Example: `interactive_goal_math_adventure_01.mp3`, `interactive_goal_math_adventure_02.mp3`

**Note:** Learning goals are dynamic per game. You'll need to create audio for each goal of each game.

---

### Last Page: About The Game

#### Page Header
**Text:** "About The Game"
**Audio File:** `interactive_about_header.mp3`

#### Game Explanation
**Text:** [GAME_EXPLANATION] (Dynamic - full explanation text)
**Audio File:** `interactive_explanation_[game_id].mp3`
**Note:** Each game has unique explanation text

#### Warning Section (If Present)
**Warning Header:**
**Text:** "Important Note"
**Audio File:** `interactive_warning_header.mp3`

**Warning Text:**
**Text:** [WARNING_TEXT] (Dynamic)
**Audio File:** `interactive_warning_[game_id].mp3`
**Note:** Only some games have warnings

---

### Navigation Buttons

**Previous Button:**
**Text:** "Previous"
**Audio File:** `button_previous.mp3`

**Next Button:**
**Text:** "Next"
**Audio File:** `button_next.mp3`

**Start Game Button:**
**Text:** "Start Game"
**Audio File:** `button_start_game.mp3`

---

## Simulation Games Detail Screen

### Page Structure
- **Page 0:** Title + Topics
- **Pages 1-N:** Learning Goals (3 per page)
- **Last Page:** Scientific Explanation + Warning

### Page 0: Title & Topics Page

#### Header Section
**Text:** "[SIMULATION_TITLE]" (Dynamic - use simulation title)
**Audio File:** `sim_title_[simulation_id].mp3`
**Note:** Create separate audio files for each simulation title

**Time & Difficulty Tags**
**Text:** "[X] mins, [DIFFICULTY]" (e.g., "20 mins, Medium")
**Audio File:** `sim_meta_[simulation_id].mp3`
**Note:** Dynamic content

#### Topics Section
**Section Header:**
**Text:** "Topics"
**Audio File:** `sim_topics_header.mp3`

**Individual Topics:**
**Text:** Each topic from the simulation's topics list (Dynamic)
**Audio File:** `sim_topic_[topic_name].mp3` (sanitize topic name)
**Note:** Topics are dynamic

---

### Pages 1-N: Learning Goals Pages

#### Page Header
**Text:** "Learning Goals"
**Audio File:** `sim_learning_goals_header.mp3`

#### Individual Learning Goals
**Text:** Each learning goal text (Dynamic - 3 per page)
**Audio Files:**
- `sim_goal_[simulation_id]_[goal_index].mp3`
- Example: `sim_goal_states_of_matter_01.mp3`, `sim_goal_states_of_matter_02.mp3`

**Note:** Learning goals are dynamic per simulation

---

### Last Page: Scientific Explanation

#### Page Header
**Text:** "Scientific Explanation"
**Audio File:** `sim_scientific_explanation_header.mp3`

#### Scientific Explanation Text
**Text:** [SCIENTIFIC_EXPLANATION] (Dynamic - full explanation text)
**Audio File:** `sim_explanation_[simulation_id].mp3`
**Note:** Each simulation has unique explanation text

#### Warning Section
**Warning Header:**
**Text:** "Important Note"
**Audio File:** `sim_warning_header.mp3`

**Warning Text:**
**Text:** [WARNING_TEXT] (Dynamic)
**Audio File:** `sim_warning_[simulation_id].mp3`
**Note:** All simulations have warnings

---

### Navigation Buttons

**Previous Button:**
**Text:** "Previous"
**Audio File:** `button_previous.mp3` (Reuse from interactive games)

**Next Button:**
**Text:** "Next"
**Audio File:** `button_next.mp3` (Reuse from interactive games)

**Start Sim Button:**
**Text:** "Start Sim"
**Audio File:** `button_start_sim.mp3`

---

## Completion Messages

### Interactive Game Completion
**Text (Gender-Neutral):** "Awesome job! You just completed an interactive game! You earned coins for your hard work. Keep playing and learning!"

**Audio File:** `completion_interactive_game.mp3`

**Alternative (Shorter):**
**Text:** "Great work! You finished the game and earned coins! Well done!"

**Audio File:** `completion_interactive_game_short.mp3`

**Note:** This plays with the coins sound effect in the dashboard

---

### Simulation Game Completion
**Text (Gender-Neutral):** "Fantastic! You just finished exploring a simulation! You learned something new and earned coins. Keep exploring science and math!"

**Audio File:** `completion_simulation.mp3`

**Alternative (Shorter):**
**Text:** "Excellent! You completed the simulation and earned coins! Great learning!"

**Audio File:** `completion_simulation_short.mp3`

**Note:** This plays with the coins sound effect in the dashboard

---

## Audio File Naming Convention

### General Rules:
1. Use lowercase letters
2. Use underscores instead of spaces
3. Remove special characters
4. Keep filenames descriptive but concise
5. Use consistent prefixes:
   - `interactive_` for interactive games
   - `sim_` for simulations
   - `button_` for button labels
   - `completion_` for completion messages

### Dynamic Content Handling:
- For game/simulation titles: Use game/simulation ID or sanitized title
- For learning goals: Use game/simulation ID + goal index (01, 02, 03...)
- For topics: Sanitize topic name (lowercase, underscores, no special chars)

### Examples:
- `interactive_game_title_math_adventure.mp3`
- `sim_title_states_of_matter.mp3`
- `interactive_goal_math_adventure_01.mp3`
- `sim_goal_states_of_matter_02.mp3`
- `sim_topic_physics.mp3`
- `interactive_topic_addition.mp3`

---

## File Structure

```
audio/
├── voiceover/
│   ├── welcome/
│   │   ├── welcome_dashboard.mp3
│   │   └── welcome_dashboard_alt.mp3
│   │
│   ├── interactive_games/
│   │   ├── headers/
│   │   │   ├── interactive_topics_header.mp3
│   │   │   ├── interactive_learning_goals_header.mp3
│   │   │   ├── interactive_about_header.mp3
│   │   │   └── interactive_warning_header.mp3
│   │   │
│   │   ├── titles/
│   │   │   ├── interactive_game_title_[game_id].mp3
│   │   │   └── (one file per game)
│   │   │
│   │   ├── meta/
│   │   │   ├── interactive_game_meta_[game_id].mp3
│   │   │   └── (time and difficulty per game)
│   │   │
│   │   ├── topics/
│   │   │   ├── interactive_topic_[topic_name].mp3
│   │   │   └── (common topics)
│   │   │
│   │   ├── goals/
│   │   │   ├── interactive_goal_[game_id]_[index].mp3
│   │   │   └── (goals per game)
│   │   │
│   │   ├── explanations/
│   │   │   ├── interactive_explanation_[game_id].mp3
│   │   │   └── (one per game)
│   │   │
│   │   └── warnings/
│   │       ├── interactive_warning_[game_id].mp3
│   │       └── (only for games with warnings)
│   │
│   ├── simulations/
│   │   ├── headers/
│   │   │   ├── sim_topics_header.mp3
│   │   │   ├── sim_learning_goals_header.mp3
│   │   │   ├── sim_scientific_explanation_header.mp3
│   │   │   └── sim_warning_header.mp3
│   │   │
│   │   ├── titles/
│   │   │   ├── sim_title_[simulation_id].mp3
│   │   │   └── (one file per simulation)
│   │   │
│   │   ├── meta/
│   │   │   ├── sim_meta_[simulation_id].mp3
│   │   │   └── (time and difficulty per simulation)
│   │   │
│   │   ├── topics/
│   │   │   ├── sim_topic_[topic_name].mp3
│   │   │   └── (common topics)
│   │   │
│   │   ├── goals/
│   │   │   ├── sim_goal_[simulation_id]_[index].mp3
│   │   │   └── (goals per simulation)
│   │   │
│   │   ├── explanations/
│   │   │   ├── sim_explanation_[simulation_id].mp3
│   │   │   └── (one per simulation)
│   │   │
│   │   └── warnings/
│   │       ├── sim_warning_[simulation_id].mp3
│   │       └── (one per simulation)
│   │
│   ├── buttons/
│   │   ├── button_previous.mp3
│   │   ├── button_next.mp3
│   │   ├── button_start_game.mp3
│   │   └── button_start_sim.mp3
│   │
│   └── completion/
│       ├── completion_interactive_game.mp3
│       ├── completion_interactive_game_short.mp3
│       ├── completion_simulation.mp3
│       └── completion_simulation_short.mp3
```

---

## Implementation Notes

### Dynamic Content Strategy:
1. **Static Content:** Headers, button labels, welcome messages - create once
2. **Semi-Dynamic Content:** Game/simulation titles - create per game/simulation
3. **Highly Dynamic Content:** Learning goals, explanations, topics - consider:
   - Creating audio files for each (recommended for quality)
   - Using Text-to-Speech (TTS) as fallback
   - Hybrid approach: TTS for dynamic content, recorded audio for static

### Gender-Neutral Language:
All texts use gender-neutral language suitable for both boys and girls:
- "You" instead of "he/she"
- "Your" instead of "his/her"
- No gender-specific pronouns
- Inclusive and encouraging tone

### Timing Considerations:
- Welcome message: ~3-5 seconds
- Page headers: ~1-2 seconds
- Learning goals: ~5-10 seconds each (depending on length)
- Explanations: ~15-30 seconds (depending on length)
- Completion messages: ~4-6 seconds

### Audio Quality:
- Format: MP3
- Sample Rate: 44.1 kHz recommended
- Bitrate: 128 kbps minimum, 192 kbps recommended
- Mono or Stereo: Mono is sufficient for voice
- Voice: Friendly, clear, age-appropriate (6-12 years)

---

## Quick Reference Checklist

### Static Files to Create (One-time):
- [ ] `welcome_dashboard.mp3`
- [ ] `interactive_topics_header.mp3`
- [ ] `interactive_learning_goals_header.mp3`
- [ ] `interactive_about_header.mp3`
- [ ] `interactive_warning_header.mp3`
- [ ] `sim_topics_header.mp3`
- [ ] `sim_learning_goals_header.mp3`
- [ ] `sim_scientific_explanation_header.mp3`
- [ ] `sim_warning_header.mp3`
- [ ] `button_previous.mp3`
- [ ] `button_next.mp3`
- [ ] `button_start_game.mp3`
- [ ] `button_start_sim.mp3`
- [ ] `completion_interactive_game.mp3`
- [ ] `completion_simulation.mp3`

### Dynamic Files (Per Game/Simulation):
- [ ] Game titles (interactive)
- [ ] Simulation titles (sim)
- [ ] Game meta info (time + difficulty)
- [ ] Simulation meta info (time + difficulty)
- [ ] Learning goals (per game/simulation)
- [ ] Explanations (per game/simulation)
- [ ] Warnings (per game/simulation that has them)
- [ ] Topics (common ones can be reused)

---

## Example Texts for Common Scenarios

### Example: Math Adventure Game
**Title:** "Math Adventure"
**Topics:** "Addition, Subtraction, Numbers"
**Learning Goal 1:** "Practice adding numbers up to 20"
**Learning Goal 2:** "Learn to subtract single-digit numbers"
**Explanation:** "In this game, you'll help characters solve math problems..."

### Example: States of Matter Simulation
**Title:** "States of Matter"
**Topics:** "Physics, Matter, Temperature"
**Learning Goal 1:** "Understand the three states of matter"
**Learning Goal 2:** "See how temperature affects matter"
**Explanation:** "This simulation lets you explore how matter changes..."

---

**Last Updated:** [Current Date]
**Version:** 1.0

