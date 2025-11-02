# Curriculum Question Templates Collection

## Collection Name: `curriculumQuestionTemplates`

This is a **new collection** specifically designed for structured, curriculum-aligned question templates for Math, English, and Science subjects.

### Why a New Collection?

- **Better Organization**: Separates structured curriculum questions from other templates
- **Clear Purpose**: Specifically for Math, English, and Science curriculum questions
- **Future-Proof**: Allows for better organization and management
- **Backwards Compatibility**: The old `questionTemplates` collection remains for existing data

### Collection Structure

Each document in `curriculumQuestionTemplates` follows the schema defined in `QUESTION_TEMPLATES_SCHEMA.md`.

### Questions Included

#### Math Questions
- **Junior (6-8)**: 14 questions
  - Counting, Place Value, Addition, Subtraction, Division, Fractions, Data Handling, Measurement, Shapes, Comparing, Patterns, Probability
- **Bright (9-12)**: 15 questions
  - Divisibility, Even Numbers, Mental Strategies, Fractions, Multiplication, Division, Decimals, Percentages, Area, Capacity, Time, Geometry, Graphs, Probability, Algebra

#### English Questions
- **Junior (6-8)**: 7 questions
  - Spelling (-ing, -ed), Grammar (Adverbs), Vocabulary (Plurals), Language Strands, Comprehension
- **Bright (9-12)**: 10 questions
  - Grammar (Connectives, Modals, Pronouns), Vocabulary (Prefixes, Suffixes, Roots), Spelling, Figurative Language, Language Strands

#### Science Questions
- **Junior (6-8)**: 8 questions
  - Materials, Living Things, Forces, State Changes, Electricity, Measurement, Light
- **Bright (9-12)**: 8 questions
  - States of Matter, Magnetism, Circuits, Sound, Habitats/Ecology

### Total Questions
- **Math**: 29 questions (14 Junior + 15 Bright)
- **English**: 17 questions (7 Junior + 10 Bright)
- **Science**: 16 questions (8 Junior + 8 Bright)
- **Grand Total**: **62 questions**

### How to Populate

Use the **Populate Questions Screen** in the Teacher Dashboard:

1. Go to Teacher Dashboard
2. Click "Populate Questions" (purple card in Quick Actions)
3. Select the subject:
   - **Populate Math Questions** (29 questions)
   - **Populate English Questions** (17 questions)
   - **Populate Science Questions** (16 questions)

### How Teachers Use This Collection

The Activity Builder automatically loads templates from `curriculumQuestionTemplates`:

1. Go to Teacher Dashboard → Create tab → "Start Activity Builder"
2. Filter by Subject (Math, English, Science) and Age Group (Junior, Bright)
3. Select templates from the results
4. Configure and publish activities

### Collection Features

- **Game Type Mapping**: Each question includes compatible game types
- **Points System**: Pre-configured points for each question
- **Difficulty Levels**: Easy, Medium, Hard ratings
- **Skills Tracking**: Skills tags for progress tracking
- **Topics**: Curriculum topics for organization
- **Metadata**: Citations, learning objectives, prerequisite skills

### Migration from Old Collection

The old `questionTemplates` collection remains for backwards compatibility. New structured curriculum questions should be added to `curriculumQuestionTemplates` going forward.

### Services Using This Collection

- `QuestionTemplatePopulator`: Populates the collection with Math, English, Science questions
- `TeacherService`: Loads templates for Activity Builder (uses `curriculumQuestionTemplates`)
- Activity Builder: Filters and displays templates from this collection

### Future Extensions

This collection structure supports:
- Adding more subjects (e.g., Social Studies, Art, Music)
- Expanding age groups
- Adding more question types
- Tracking child progress by question
- Analytics and reporting

