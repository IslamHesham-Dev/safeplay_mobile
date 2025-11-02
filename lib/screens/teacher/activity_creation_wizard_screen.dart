import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../design_system/colors.dart';
import '../../models/question_template.dart';
import '../../models/user_type.dart';
import '../../models/activity.dart';
import '../../models/game_activity.dart';
import '../../utils/publishing_constraints_utils.dart';
import '../../utils/template_metadata_utils.dart';
import '../../providers/auth_provider.dart';
import '../../services/activity_service.dart';
import '../../services/publishing_service.dart';
import 'activity_published_success_screen.dart';
import 'template_browser_screen.dart';

/// Multi-page wizard for activity creation
/// Similar style to parent auth/child creation screens
class ActivityCreationWizardScreen extends StatefulWidget {
  const ActivityCreationWizardScreen({super.key});

  @override
  State<ActivityCreationWizardScreen> createState() =>
      _ActivityCreationWizardScreenState();
}

class _ActivityCreationWizardScreenState
    extends State<ActivityCreationWizardScreen> {
  int _currentStep =
      0; // 0: Filters, 1: Browse Templates, 2: Configure, 3: Review
  bool _showConstraints = false;

  // Filters state
  ActivitySubject? _selectedSubject;
  AgeGroup _selectedAgeGroup = AgeGroup.junior;
  bool _includeBreakActivities = false;

  // Selected templates from Browse Templates screen
  List<QuestionTemplate> _selectedTemplates = [];

  // Form controllers (passed to Activity Builder)
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectivesController = TextEditingController();
  int _pointsPerQuestion = 15;
  int _durationMinutesPerQuestion = 2;
  bool _creating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    super.dispose();
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showConstraints ? Icons.visibility_off : Icons.rule),
            tooltip: _showConstraints ? 'Hide Guidelines' : 'Show Guidelines',
            onPressed: () {
              setState(() => _showConstraints = !_showConstraints);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator (like auth screens)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                    backgroundColor: SafePlayColors.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      SafePlayColors.brandTeal500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStepIndicator('1', 'Filters', _currentStep >= 0),
                      _buildStepIndicator('2', 'Choose', _currentStep >= 1),
                      _buildStepIndicator('3', 'Configure', _currentStep >= 2),
                      _buildStepIndicator('4', 'Review', _currentStep >= 3),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable content area (includes guidelines if shown + step content)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Guidelines display (if shown) - takes full size
                    if (_showConstraints)
                      Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: SafePlayColors.brandTeal500.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header (no close button)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    SafePlayColors.brandTeal500
                                        .withOpacity(0.9),
                                    SafePlayColors.brandTeal500,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.rule,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Publishing Guidelines',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Content - takes natural size
                            Container(
                              color: Colors.grey[50],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: PublishingConstraintsUtils
                                        .getAllConstraints()
                                    .map((constraint) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Card(
                                      elevation: 0,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color:
                                              constraint.color.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: constraint.color
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Icon(
                                                    constraint.icon,
                                                    color: constraint.color,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    constraint.category,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            ...constraint.constraints
                                                .map((item) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 36, bottom: 8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 6),
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        color: constraint.color
                                                            .withOpacity(0.6),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        item,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[700],
                                                          height: 1.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Step content
                    _buildCurrentStep(),
                  ],
                ),
              ),
            ),

            // Navigation buttons (like auth screens)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_canProceed() && !_creating) ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SafePlayColors.brandTeal500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _creating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_getNextButtonText()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? SafePlayColors.brandTeal500
                : SafePlayColors.neutral300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? SafePlayColors.brandTeal500 : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildFiltersStep();
      case 1:
        return _buildBrowseTemplatesStep();
      case 2:
        return _buildConfigureStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFiltersStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Filters',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose subject, age group, and content type',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SafePlayColors.neutral600,
                ),
          ),
          const SizedBox(height: 32),

          // Subject filter
          DropdownButtonFormField<ActivitySubject?>(
            value: _selectedSubject,
            decoration: const InputDecoration(
              labelText: 'Subject',
              prefixIcon: Icon(Icons.book),
              border: OutlineInputBorder(),
              helperText: 'Select a subject or leave as "All"',
            ),
            items: [
              const DropdownMenuItem<ActivitySubject?>(
                value: null,
                child: Text('All Subjects'),
              ),
              ...[
                ActivitySubject.math,
                ActivitySubject.science,
                ActivitySubject.reading, // English
              ].map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(
                    subject == ActivitySubject.reading
                        ? 'English'
                        : subject.displayName,
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() => _selectedSubject = value);
            },
          ),

          const SizedBox(height: 24),

          // Age group filter
          DropdownButtonFormField<AgeGroup>(
            value: _selectedAgeGroup,
            decoration: const InputDecoration(
              labelText: 'Age Group',
              prefixIcon: Icon(Icons.people),
              border: OutlineInputBorder(),
            ),
            items: AgeGroup.values.map((ageGroup) {
              return DropdownMenuItem(
                value: ageGroup,
                child: Text(ageGroup == AgeGroup.junior
                    ? 'Junior Explorer (6-8)'
                    : 'Bright Minds (9-12)'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedAgeGroup = value);
              }
            },
          ),

          const SizedBox(height: 24),

          // Include Break Activities checkbox
          Card(
            child: CheckboxListTile(
              title: const Text('Include Break Activities'),
              subtitle: const Text('Mindful games and relaxation activities'),
              value: _includeBreakActivities,
              onChanged: (value) {
                setState(() => _includeBreakActivities = value ?? false);
              },
              secondary: const Icon(Icons.self_improvement),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseTemplatesStep() {
    return TemplateBrowserScreen(
      selectedSubject: _selectedSubject,
      selectedAgeGroup: _selectedAgeGroup,
      includeBreakActivities: _includeBreakActivities,
      selectedTemplates: _selectedTemplates,
      onTemplatesSelected: (templates) {
        setState(() {
          _selectedTemplates = templates;
          // Auto-generate content when templates are selected
          if (templates.isNotEmpty && _titleController.text.isEmpty) {
            _generateDefaultContent();
          }
        });
      },
    );
  }

  void _generateDefaultContent() {
    if (_selectedTemplates.isEmpty) return;

    // Generate title
    if (_titleController.text.isEmpty) {
      final subject = _selectedSubject ??
          (_selectedTemplates.first.subjects.isNotEmpty
              ? _selectedTemplates.first.subjects.first
              : ActivitySubject.math);
      final subjectName =
          subject == ActivitySubject.reading ? 'English' : subject.displayName;
      final gameType = TemplateMetadataUtils.getRecommendedGameType(
          _selectedTemplates.first);
      _titleController.text = gameType != null
          ? '$subjectName - ${gameType.displayName}'
          : '$subjectName Activity';
    }

    // Generate description
    if (_descriptionController.text.isEmpty) {
      _descriptionController.text =
          TemplateMetadataUtils.generateActivityDescription(
        _selectedTemplates,
        _selectedAgeGroup,
      );
    }

    // Generate learning objectives
    if (_objectivesController.text.isEmpty) {
      final objectives =
          TemplateMetadataUtils.generateLearningObjectives(_selectedTemplates);
      _objectivesController.text = objectives.join('\n');
    }
  }

  Widget _buildConfigureStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set title, description, and learning objectives',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SafePlayColors.neutral600,
                  ),
            ),
            const SizedBox(height: 32),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title *',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description *',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                helperText: 'Friendly description for children',
              ),
            ),

            const SizedBox(height: 20),

            // Learning objectives
            TextFormField(
              controller: _objectivesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Learning Objectives',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
                helperText: 'One objective per line',
              ),
            ),

            const SizedBox(height: 32),

            // Points and duration per question
            Text(
              'Question Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _pointsPerQuestion.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Points Per Question',
                      prefixIcon: Icon(Icons.stars),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _pointsPerQuestion = int.tryParse(value) ?? 15;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _durationMinutesPerQuestion.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minutes Per Question',
                      prefixIcon: Icon(Icons.timer),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _durationMinutesPerQuestion = int.tryParse(value) ?? 2;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Publish',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewRow('Title', _titleController.text),
                  _buildReviewRow('Description', _descriptionController.text),
                  _buildReviewRow('Subject',
                      _selectedSubject?.displayName ?? 'All Subjects'),
                  _buildReviewRow(
                      'Age Group',
                      _selectedAgeGroup == AgeGroup.junior
                          ? 'Junior Explorer (6-8)'
                          : 'Bright Minds (9-12)'),
                  _buildReviewRow(
                      'Total Questions', '${_selectedTemplates.length}'),
                  _buildReviewRow(
                      'Questions Breakdown', _buildQuestionBreakdownRow()),
                  _buildReviewRow('Points Per Question', '$_pointsPerQuestion'),
                  _buildReviewRow('Total Points',
                      '${_pointsPerQuestion * _selectedTemplates.length}'),
                  _buildReviewRow('Duration Per Question',
                      '$_durationMinutesPerQuestion minutes'),
                  _buildReviewRow('Total Duration', _buildDurationRow()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _buildDurationRow() {
    // Identify break activities
    final breakActivityTemplates = _selectedTemplates.where((template) {
      return template.id.startsWith('break_') ||
          template.subjects.any((s) =>
              s.name.toLowerCase().contains('wellbeing') ||
              s.name.toLowerCase().contains('mindfulness')) ||
          (template.subjects.isEmpty &&
              (template.title.toLowerCase().contains('breathing') ||
                  template.title.toLowerCase().contains('yoga') ||
                  template.title.toLowerCase().contains('mindful') ||
                  template.title.toLowerCase().contains('break')));
    }).toList();

    final curriculumTemplates =
        _selectedTemplates.length - breakActivityTemplates.length;
    final breakTemplatesCount = breakActivityTemplates.length;

    // Duration for curriculum questions only (excluding break games)
    final durationWithoutBreakGames =
        _durationMinutesPerQuestion * curriculumTemplates;

    // Total duration including break games
    final durationWithBreakGames =
        _durationMinutesPerQuestion * _selectedTemplates.length;

    if (breakTemplatesCount > 0) {
      return '$durationWithoutBreakGames minutes (without break games)\n'
          '$durationWithBreakGames minutes (with break games)';
    } else {
      return '$durationWithBreakGames minutes (excluding game play time)';
    }
  }

  String _buildQuestionBreakdownRow() {
    // Identify break activities
    final breakActivityTemplates = _selectedTemplates.where((template) {
      return template.id.startsWith('break_') ||
          template.subjects.any((s) =>
              s.name.toLowerCase().contains('wellbeing') ||
              s.name.toLowerCase().contains('mindfulness')) ||
          (template.subjects.isEmpty &&
              (template.title.toLowerCase().contains('breathing') ||
                  template.title.toLowerCase().contains('yoga') ||
                  template.title.toLowerCase().contains('mindful') ||
                  template.title.toLowerCase().contains('break')));
    }).toList();

    final curriculumCount =
        _selectedTemplates.length - breakActivityTemplates.length;
    final breakCount = breakActivityTemplates.length;

    if (breakCount > 0) {
      return '$curriculumCount curriculum questions\n'
          '$breakCount break game questions';
    } else {
      return '${curriculumCount} curriculum questions\n'
          '0 break game questions';
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Can always proceed from filters
      case 1:
        return _selectedTemplates.isNotEmpty;
      case 2:
        return _titleController.text.trim().isNotEmpty &&
            _descriptionController.text.trim().isNotEmpty;
      case 3:
        // On review step, navigate to Activity Builder to complete publishing
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedTemplates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one template'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_titleController.text.trim().isEmpty ||
          _descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      // Complete & Publish - Navigate to Activity Builder
      _completeAndPublish();
    }
  }

  Future<void> _completeAndPublish() async {
    setState(() => _creating = true);

    try {
      // Create and publish activity using Activity Builder logic
      final auth = context.read<AuthProvider>();
      final teacherId = auth.currentUser?.id;

      if (teacherId == null) {
        throw Exception('No teacher ID found');
      }

      // Import required services
      final activityService = ActivityService();
      final publishingService = PublishingService();

      // Create questions from templates
      final questions = _selectedTemplates.asMap().entries.map((entry) {
        final index = entry.key;
        final template = entry.value;
        return template.instantiate(
          questionId: 'q_${index + 1}',
          overridePoints: _pointsPerQuestion,
        );
      }).toList();

      // Get game types for each template
      final gameTypesForQuestions = _selectedTemplates.map((template) {
        return TemplateMetadataUtils.getRecommendedGameType(template) ??
            GameType.memoryMatch;
      }).toList();

      // Parse learning objectives
      final objectives = _objectivesController.text
          .split('\n')
          .map((obj) => obj.trim())
          .where((obj) => obj.isNotEmpty)
          .toList();

      // Determine subject for activity
      final activitySubject = _selectedSubject ??
          (_selectedTemplates.isNotEmpty &&
                  _selectedTemplates.first.subjects.isNotEmpty
              ? ActivitySubject.fromRaw(_selectedTemplates.first.subjects.first)
              : ActivitySubject.math);

      // Get primary game type
      final primaryGameType = gameTypesForQuestions.isNotEmpty
          ? gameTypesForQuestions.first
          : GameType.memoryMatch;

      // Identify break activities to calculate duration correctly
      final breakActivityTemplates = _selectedTemplates.where((template) {
        return template.id.startsWith('break_') ||
            template.subjects.any((s) =>
                s.name.toLowerCase().contains('wellbeing') ||
                s.name.toLowerCase().contains('mindfulness')) ||
            (template.subjects.isEmpty &&
                (template.title.toLowerCase().contains('breathing') ||
                    template.title.toLowerCase().contains('yoga') ||
                    template.title.toLowerCase().contains('mindful') ||
                    template.title.toLowerCase().contains('break')));
      }).toList();

      final curriculumTemplatesCount =
          _selectedTemplates.length - breakActivityTemplates.length;

      // Calculate total points and duration
      // Duration excludes break games time (only curriculum questions count)
      final totalPoints = _pointsPerQuestion * questions.length;
      final totalDurationMinutes =
          _durationMinutesPerQuestion * curriculumTemplatesCount;

      // Create game config
      final gameConfig = GameConfig(
        gameType: primaryGameType,
        settings: _getGameSettings(primaryGameType),
        questionTemplateIds: _selectedTemplates.map((t) => t.id).toList(),
        timeLimitSeconds: totalDurationMinutes * 60,
        maxAttempts: 3,
        allowHints: true,
        showProgress: true,
        accessibilityOptions: _getAccessibilityOptions(),
      );

      // Create activity
      final now = DateTime.now();
      final baseActivity = Activity(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: activitySubject,
        ageGroup: _selectedAgeGroup,
        difficulty: Difficulty.easy,
        durationMinutes: totalDurationMinutes,
        points: totalPoints,
        learningObjectives: objectives.isEmpty
            ? TemplateMetadataUtils.generateLearningObjectives(
                _selectedTemplates)
            : objectives,
        questions: questions,
        createdBy: teacherId,
        published: false,
        publishState: PublishState.draft,
        skills: _selectedTemplates.expand((t) => t.skills).toSet().toList(),
        tags: [
          primaryGameType.name,
          activitySubject.name,
          _selectedAgeGroup.name,
        ],
        createdAt: now,
        updatedAt: now,
      );

      // Create game activity
      final gameActivity = GameActivity.fromActivity(
        baseActivity,
        gameConfig: gameConfig,
        gameMetadata: {
          'createdAt': now.toIso8601String(),
          'teacherId': teacherId,
          'gameType': primaryGameType.name,
          'gameTypesPerQuestion':
              gameTypesForQuestions.map((gt) => gt.name).toList(),
          'pointsPerQuestion': _pointsPerQuestion,
          'durationMinutesPerQuestion': _durationMinutesPerQuestion,
          'templateCount': _selectedTemplates.length,
        },
      );

      // Save activity
      final activityId = await activityService.upsertActivity(
        activity: gameActivity,
        actorRole: UserType.teacher,
      );

      // Publish activity (with validation)
      final publishResult = await publishingService.publishActivity(
        activityId: activityId,
        teacherId: teacherId,
        actorRole: UserType.teacher,
      );

      if (!publishResult.isSuccess) {
        // Update to draft if publishing failed
        // Update the activity document directly to set draft state
        try {
          await FirebaseFirestore.instance
              .collection('activities')
              .doc(activityId)
              .update({
            'published': false,
            'publishState': 'draft',
            'updatedAt': FieldValue.serverTimestamp(),
            'validationErrors': publishResult.message,
          });
        } catch (e) {
          debugPrint('Error updating activity to draft: $e');
        }

        // Format error message
        final formattedError = PublishingConstraintsUtils.formatValidationError(
          publishResult.message,
        );

        // Show error dialog
        if (mounted) {
          await _showPublishingError(formattedError);
        }
        return;
      }

      // Load the full activity for success screen
      final activityDoc = await FirebaseFirestore.instance
          .collection('activities')
          .doc(activityId)
          .get();

      final publishedActivity = Activity.fromJson({
        'id': activityDoc.id,
        ...activityDoc.data()!,
      });

      // Navigate to success screen - pass template IDs for break game detection
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityPublishedSuccessScreen(
              activity: publishedActivity,
              activityId: activityId,
              questionTemplateIds: _selectedTemplates.map((t) => t.id).toList(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  Future<void> _showPublishingError(String errorMessage) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            const Text('Publishing Requirements Not Met'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your activity was saved as a draft, but could not be published because:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showConstraintsDialog();
            },
            child: const Text('View Guidelines'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.brandTeal500,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showConstraintsDialog() {
    // Show constraints dialog (same as Activity Builder)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - Light and friendly
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SafePlayColors.brandTeal500.withOpacity(0.9),
                      SafePlayColors.brandTeal500,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Icon(Icons.rule, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Publishing Guidelines',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: PublishingConstraintsUtils.getAllConstraints()
                          .map((constraint) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: constraint.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              constraint.color.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          constraint.icon,
                                          color: constraint.color,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          constraint.category,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...constraint.constraints.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 36, bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 6),
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: constraint.color
                                                  .withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SafePlayColors.brandTeal500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Got it'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getGameSettings(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
        return {
          'gridSize': 10,
          'missingCount': 10,
          'skipPattern': 'random',
        };
      default:
        return {};
    }
  }

  Map<String, dynamic> _getAccessibilityOptions() {
    return {
      'highContrast': false,
      'largeText': false,
      'audioFeedback': true,
      'hapticFeedback': true,
      'voiceOver': false,
    };
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Next: Choose Templates';
      case 1:
        return 'Next: Configure';
      case 2:
        return 'Next: Review';
      case 3:
        return 'Complete & Publish';
      default:
        return 'Next';
    }
  }
}
