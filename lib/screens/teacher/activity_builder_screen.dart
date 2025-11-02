import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/teacher_service.dart';
import '../../services/activity_service.dart';
import '../../services/publishing_service.dart';
import '../../services/break_activities_service.dart';
import '../../utils/template_metadata_utils.dart';
import '../../utils/publishing_constraints_utils.dart';
import '../../models/activity.dart';
import '../../models/publishing_exception.dart';
import '../../models/question_template.dart';
import '../../models/game_activity.dart';
import '../../models/user_type.dart';
import '../../design_system/colors.dart';

/// Comprehensive Teacher Activity Builder
/// Allows teachers to filter templates, select questions, configure games, and publish
class ActivityBuilderScreen extends StatefulWidget {
  final List<QuestionTemplate>? preSelectedTemplates;
  final Map<String, dynamic>? preFilledData;

  const ActivityBuilderScreen({
    super.key,
    this.preSelectedTemplates,
    this.preFilledData,
  });

  @override
  State<ActivityBuilderScreen> createState() => _ActivityBuilderScreenState();
}

class _ActivityBuilderScreenState extends State<ActivityBuilderScreen>
    with TickerProviderStateMixin {
  // Services
  late final TeacherService _teacherService;
  late final ActivityService _activityService;
  late final PublishingService _publishingService;
  late final BreakActivitiesService _breakActivitiesService;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectivesController = TextEditingController();

  // Filters
  ActivitySubject? _selectedSubject; // null = All Subjects
  AgeGroup _selectedAgeGroup = AgeGroup.junior;
  String _contentType = 'curriculum'; // 'curriculum', 'break', or 'both'

  // Templates
  List<QuestionTemplate> _availableTemplates = [];
  List<QuestionTemplate> _selectedTemplates = [];
  String _searchQuery = '';

  // Points and duration are per-question (not whole activity)
  int _pointsPerQuestion = 15;
  int _durationMinutesPerQuestion = 2;

  // UI state
  int _currentStep =
      0; // 0: Filter, 1: Select Templates, 2: Configure, 3: Review
  bool _loading = false;
  bool _creating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _teacherService = TeacherService();
    _activityService = ActivityService();
    _publishingService = PublishingService();
    _breakActivitiesService = BreakActivitiesService();

    // If templates were pre-selected, add them and set defaults
    if (widget.preSelectedTemplates != null &&
        widget.preSelectedTemplates!.isNotEmpty) {
      _selectedTemplates.addAll(widget.preSelectedTemplates!);

      // Set age group and subject from first template
      if (widget.preSelectedTemplates!.first.ageGroups.isNotEmpty) {
        _selectedAgeGroup = widget.preSelectedTemplates!.first.ageGroups.first;
      }
      if (widget.preSelectedTemplates!.first.subjects.isNotEmpty) {
        _selectedSubject = widget.preSelectedTemplates!.first.subjects.first;
      }

      // Auto-generate title, description, and learning objectives
      _generateDefaultContent();
    }

    _loadTemplates();
  }

  /// Generate default title, description, and learning objectives from templates
  void _generateDefaultContent() {
    if (_selectedTemplates.isEmpty) return;

    // Generate title
    if (_titleController.text.isEmpty) {
      final subject = _selectedTemplates.first.subjects.isNotEmpty
          ? _selectedTemplates.first.subjects.first
          : ActivitySubject.math;
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

    // Set default points per question (average from templates)
    if (_selectedTemplates.isNotEmpty) {
      final totalPoints = _selectedTemplates.fold<int>(
        0,
        (sum, t) => sum + t.defaultPoints,
      );
      _pointsPerQuestion = (totalPoints / _selectedTemplates.length).round();
      if (_pointsPerQuestion == 0) _pointsPerQuestion = 15; // Default
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    super.dispose();
  }

  /// Load templates based on current filters
  Future<void> _loadTemplates() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final teacherId = auth.currentUser?.id;

      final allTemplates = <QuestionTemplate>[];

      // Load curriculum questions if needed
      if (_contentType == 'curriculum' || _contentType == 'both') {
        final subjects = _selectedSubject != null
            ? [_selectedSubject!]
            : [
                ActivitySubject.math,
                ActivitySubject.science,
                ActivitySubject.reading
              ];

        final curriculumTemplates = await _teacherService.getQuestionTemplates(
          teacherId: teacherId,
          subjects:
              _selectedSubject != null ? subjects : null, // null = all subjects
          ageGroups: [_selectedAgeGroup],
        );

        allTemplates.addAll(curriculumTemplates);
      }

      // Load break activities if needed
      if (_contentType == 'break' || _contentType == 'both') {
        final breakTemplates = await _breakActivitiesService.getBreakActivities(
          ageGroup: _selectedAgeGroup,
          activeOnly: true,
        );

        allTemplates.addAll(breakTemplates);
      }

      // Filter by search query if provided
      final filteredTemplates = _searchQuery.isEmpty
          ? allTemplates
          : allTemplates.where((template) {
              return template.title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  template.prompt
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  template.skills.any((skill) =>
                      skill.toLowerCase().contains(_searchQuery.toLowerCase()));
            }).toList();

      setState(() {
        _availableTemplates = filteredTemplates;
      });

      // Auto-generate content when templates change
      if (_selectedTemplates.isNotEmpty) {
        _generateDefaultContent();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Toggle template selection
  void _toggleTemplate(QuestionTemplate template) {
    setState(() {
      if (_selectedTemplates.contains(template)) {
        _selectedTemplates.remove(template);
      } else {
        _selectedTemplates.add(template);
      }
      // Auto-generate content when templates are selected
      if (_selectedTemplates.isNotEmpty) {
        _generateDefaultContent();
      }
    });
  }

  /// Create and publish activity
  Future<void> _createAndPublish() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTemplates.isEmpty) {
      _showError('Please select at least one question template');
      return;
    }

    setState(() => _creating = true);

    try {
      final auth = context.read<AuthProvider>();
      final teacherId = auth.currentUser?.id;

      if (teacherId == null) {
        throw Exception('No teacher ID found');
      }

      // Create questions from templates with per-question points and duration
      final questions = _selectedTemplates.asMap().entries.map((entry) {
        final index = entry.key;
        final template = entry.value;
        return template.instantiate(
          questionId: 'q_${index + 1}',
          overridePoints: _pointsPerQuestion, // Use per-question points
        );
      }).toList();

      // Get game types for each template (each question has its own game type)
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

      // Determine subject for activity (use first template's subject, or default)
      final activitySubject = _selectedSubject ??
          (_selectedTemplates.isNotEmpty &&
                  _selectedTemplates.first.subjects.isNotEmpty
              ? ActivitySubject.fromRaw(_selectedTemplates.first.subjects.first)
              : ActivitySubject.math);

      // Get primary game type for activity (most common one, or first)
      final primaryGameType = gameTypesForQuestions.isNotEmpty
          ? gameTypesForQuestions.first
          : GameType.memoryMatch;

      // Calculate total points and duration (per-question basis)
      final totalPoints = _pointsPerQuestion * questions.length;
      final totalDurationMinutes =
          _durationMinutesPerQuestion * questions.length;

      // Create game config with primary game type
      final gameConfig = GameConfig(
        gameType: primaryGameType,
        settings: _getGameSettings(primaryGameType),
        questionTemplateIds: _selectedTemplates.map((t) => t.id).toList(),
        timeLimitSeconds:
            totalDurationMinutes * 60, // Total time for all questions
        maxAttempts: 3,
        allowHints: true,
        showProgress: true,
        accessibilityOptions: _getAccessibilityOptions(),
      );

      // Create activity (no difficulty field)
      final now = DateTime.now();
      final activity = Activity(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: activitySubject,
        ageGroup: _selectedAgeGroup,
        difficulty: Difficulty.easy, // Required field, but we don't use it
        durationMinutes:
            totalDurationMinutes, // Total duration for all questions
        points: totalPoints, // Total points for all questions
        learningObjectives: objectives.isEmpty
            ? TemplateMetadataUtils.generateLearningObjectives(
                _selectedTemplates)
            : objectives,
        questions: questions,
        createdBy: teacherId,
        published: false, // Will be published after validation
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

      // Create game activity with config
      // Store game types per question in metadata
      final gameActivity = GameActivity.fromActivity(
        activity,
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

      // IMPORTANT: Validate BEFORE saving to prevent publishing invalid activities
      // Create a temporary activity for validation (don't save yet)

      // Perform pre-validation using the publishing service logic
      // We'll validate the activity structure first, then save and publish if valid

      // Save activity as DRAFT first
      final activityId = await _activityService.upsertActivity(
        activity: gameActivity,
        actorRole: UserType.teacher,
      );

      // NOW validate and publish (this will update to published if valid, or leave as draft if invalid)
      final publishResult = await _publishingService.publishActivity(
        activityId: activityId,
        teacherId: teacherId,
        actorRole: UserType.teacher,
      );

      if (!publishResult.isSuccess) {
        // If publishing failed, ensure activity stays as draft
        // Update activity to explicitly mark as draft (already saved above)
        try {
          // Use activity service to update to draft state
          final draftActivity = Activity.fromJson({
            'id': activityId,
            ...gameActivity.toJson(),
            'published': false,
            'publishState': 'draft',
            'updatedAt': DateTime.now().toIso8601String(),
          });
          final draftGameActivity = GameActivity.fromActivity(
            draftActivity,
            gameConfig: gameActivity.gameConfig,
            gameMetadata: gameActivity.gameMetadata,
          );
          await _activityService.upsertActivity(
            activity: draftGameActivity,
            actorRole: UserType.teacher,
          );
        } catch (e) {
          debugPrint('Error updating activity to draft: $e');
        }

        // Format error message for better UX
        final formattedError = PublishingConstraintsUtils.formatValidationError(
          publishResult.message,
        );

        throw PublishingException(
          message: formattedError,
          activityId: activityId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Activity "${activity.title}" created and published successfully!'),
            backgroundColor: SafePlayColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(true); // Return success to wizard
      }
    } on PublishingException catch (e) {
      // Show user-friendly error for publishing failures
      _showPublishingError(e.message);
    } catch (e) {
      _showError('Error creating activity: $e');
    } finally {
      setState(() => _creating = false);
    }
  }

  /// Show publishing error in a user-friendly dialog
  void _showPublishingError(String errorMessage) {
    showDialog(
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
              const SizedBox(height: 16),
              Text(
                'Please review the publishing guidelines and adjust your activity accordingly.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close error dialog
              _showConstraintsDialog(); // Show guidelines
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

  /// Show constraints dialog
  void _showConstraintsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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

              // Content - Light background with cards
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

              // Close button - Light background
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

  /// Get game-specific settings
  Map<String, dynamic> _getGameSettings(GameType gameType) {
    switch (gameType) {
      case GameType.numberGridRace:
        return {
          'gridSize': 10,
          'missingCount': 10,
          'skipPattern': 'random',
        };
      case GameType.koalaCounterAdventure:
        return {
          'numberLineRange': [0, 100],
          'jumpSize': 1,
        };
      case GameType.fractionNavigator:
        return {
          'valueCount': 6,
          'includePercentages': true,
          'includeDecimals': true,
        };
      default:
        return {};
    }
  }

  /// Get accessibility options
  Map<String, dynamic> _getAccessibilityOptions() {
    return {
      'highContrast': false,
      'largeText': false,
      'audioFeedback': true,
      'hapticFeedback': true,
      'voiceOver': false,
    };
  }

  void _showError(String message) {
    setState(() => _error = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Build constraints info card
  Widget _buildConstraintsCard() {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(Icons.rule, color: SafePlayColors.brandTeal500, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Publishing Guidelines',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      subtitle: Text(
        'View requirements for publishing activities',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      initiallyExpanded: false,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: PublishingConstraintsUtils.getAllConstraints()
                .map((constraint) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(constraint.icon,
                            color: constraint.color, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          constraint.category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: constraint.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...constraint.constraints.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 28, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(color: constraint.color),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Activity Builder'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildStepper(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error ?? 'Unknown error',
              style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => _error = null);
              _loadTemplates();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Stepper(
      currentStep: _currentStep,
      onStepTapped: (step) {
        setState(() => _currentStep = step);
      },
      onStepContinue: _currentStep < 3 ? _nextStep : null,
      onStepCancel: _currentStep > 0 ? _previousStep : null,
      steps: [
        _buildFilterStep(),
        _buildTemplateSelectionStep(),
        _buildConfigurationStep(),
        _buildReviewStep(),
      ],
    );
  }

  Step _buildFilterStep() {
    return Step(
      title: const Text('Filter Templates'),
      subtitle: const Text('Select subject and age group'),
      isActive: _currentStep == 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Content type filter
          DropdownButtonFormField<String>(
            value: _contentType,
            decoration: const InputDecoration(
              labelText: 'Content Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
              helperText: 'Choose what to include in your activity',
            ),
            items: [
              DropdownMenuItem(
                value: 'curriculum',
                child: Row(
                  children: [
                    const Icon(Icons.school, size: 20),
                    const SizedBox(width: 8),
                    const Text('Curriculum Questions'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'break',
                child: Row(
                  children: [
                    const Icon(Icons.self_improvement, size: 20),
                    const SizedBox(width: 8),
                    const Text('Break Activities'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'both',
                child: Row(
                  children: [
                    const Icon(Icons.layers, size: 20),
                    const SizedBox(width: 8),
                    const Text('Both'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _contentType = value;
                  _selectedTemplates.clear();
                  // Reset subject filter if switching to break activities
                  if (value == 'break') {
                    _selectedSubject = null;
                  }
                });
                _loadTemplates();
              }
            },
          ),

          const SizedBox(height: 16),

          // Subject filter (only for curriculum questions)
          if (_contentType == 'curriculum' || _contentType == 'both')
            DropdownButtonFormField<ActivitySubject?>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
                helperText: 'Select a specific subject or "All"',
              ),
              items: [
                const DropdownMenuItem<ActivitySubject?>(
                  value: null,
                  child: Text('All Subjects'),
                ),
                ...[
                  ActivitySubject.math,
                  ActivitySubject.science,
                  ActivitySubject.reading, // English/Reading
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
                setState(() {
                  _selectedSubject = value;
                  _selectedTemplates.clear();
                });
                _loadTemplates();
              },
            ),

          if (_contentType == 'curriculum' || _contentType == 'both')
            const SizedBox(height: 16),

          // Age group filter
          DropdownButtonFormField<AgeGroup>(
            value: _selectedAgeGroup,
            decoration: const InputDecoration(
              labelText: 'Age Group',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people),
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
                setState(() {
                  _selectedAgeGroup = value;
                  _selectedTemplates.clear();
                });
                _loadTemplates();
              }
            },
          ),

          const SizedBox(height: 24),

          // Template count
          Card(
            color: SafePlayColors.brandTeal500.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: SafePlayColors.brandTeal500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_availableTemplates.length} template(s) available',
                      style: TextStyle(
                        color: SafePlayColors.brandTeal500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Step _buildTemplateSelectionStep() {
    return Step(
      title: const Text('Select Templates'),
      subtitle: Text('${_selectedTemplates.length} selected'),
      isActive: _currentStep == 1,
      state: _currentStep > 1
          ? StepState.complete
          : _selectedTemplates.isNotEmpty
              ? StepState.complete
              : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              labelText: 'Search templates',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _loadTemplates();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _loadTemplates();
            },
          ),

          const SizedBox(height: 16),

          // Template list
          if (_availableTemplates.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SafePlayColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.search_off,
                      size: 48, color: SafePlayColors.neutral400),
                  const SizedBox(height: 16),
                  Text(
                    'No templates found for the selected filters.',
                    style: TextStyle(color: SafePlayColors.neutral600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableTemplates.length,
                itemBuilder: (context, index) {
                  final template = _availableTemplates[index];
                  final isSelected = _selectedTemplates.contains(template);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected
                        ? SafePlayColors.brandTeal500.withValues(alpha: 0.1)
                        : null,
                    child: CheckboxListTile(
                      title: Text(
                        template.title,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            template.prompt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: SafePlayColors.neutral600,
                            ),
                          ),
                          // Tags: Subject, Age Group, Game Type
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              // Subject tags
                              ...template.subjects.map((subject) {
                                final color = subject == ActivitySubject.math
                                    ? Colors.blue
                                    : subject == ActivitySubject.science
                                        ? Colors.orange
                                        : Colors.green;
                                return Chip(
                                  label: Text(
                                    subject == ActivitySubject.reading
                                        ? 'English'
                                        : subject.displayName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: color.withOpacity(0.15),
                                  labelStyle: TextStyle(color: color),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }),

                              // Age group tags
                              ...template.ageGroups.map((ageGroup) {
                                final color = ageGroup == AgeGroup.junior
                                    ? Colors.orange
                                    : Colors.purple;
                                return Chip(
                                  label: Text(
                                    ageGroup == AgeGroup.junior
                                        ? 'Junior'
                                        : 'Bright',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: color.withOpacity(0.15),
                                  labelStyle: TextStyle(color: color),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }),

                              // Game type tag
                              if (TemplateMetadataUtils.getRecommendedGameType(
                                      template) !=
                                  null)
                                Chip(
                                  label: Text(
                                    TemplateMetadataUtils
                                            .getRecommendedGameType(template)!
                                        .displayName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  avatar: Icon(Icons.videogame_asset,
                                      size: 14, color: Colors.indigo),
                                  backgroundColor:
                                      Colors.indigo.withOpacity(0.15),
                                  labelStyle:
                                      const TextStyle(color: Colors.indigo),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                            ],
                          ),

                          // Skills tags (if any)
                          if (template.skills.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: template.skills.take(3).map((skill) {
                                return Chip(
                                  label: Text(
                                    skill,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: SafePlayColors.brandTeal500
                                      .withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: SafePlayColors.brandTeal500,
                                  ),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                      value: isSelected,
                      onChanged: (value) => _toggleTemplate(template),
                      secondary: Icon(
                        _getTemplateIcon(template.type),
                        color: isSelected
                            ? SafePlayColors.brandTeal500
                            : SafePlayColors.neutral400,
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_selectedTemplates.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SafePlayColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SafePlayColors.success),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: SafePlayColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedTemplates.length} template(s) selected',
                      style: TextStyle(
                        color: SafePlayColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Step _buildConfigurationStep() {
    return Step(
      title: const Text('Configure Activity'),
      subtitle: const Text('Set details and game type'),
      isActive: _currentStep == 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Publishing Constraints Info Card
            _buildConstraintsCard(),

            const SizedBox(height: 16),
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
                hintText: 'e.g., Number Grid Race - Counting Patterns',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Fun and engaging description for children...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Learning objectives
            TextFormField(
              controller: _objectivesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Learning Objectives (one per line)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
                hintText: 'Count to 100\nAdd single digits\nIdentify patterns',
              ),
            ),

            const SizedBox(height: 24),

            // Game types assigned to templates (read-only info)
            if (_selectedTemplates.isNotEmpty) ...[
              Text(
                'Game Types Assigned',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedTemplates.map((template) {
                  final gameType =
                      TemplateMetadataUtils.getRecommendedGameType(template) ??
                          GameType.memoryMatch;
                  return Chip(
                    label: Text(gameType.displayName),
                    avatar: Icon(Icons.videogame_asset, size: 18),
                    backgroundColor: Colors.indigo.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Points and duration per question
            Text(
              'Question Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _pointsPerQuestion.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Points Per Question',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.stars),
                      helperText: 'Points awarded for each question',
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
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                      helperText: 'Time allocated per question',
                    ),
                    onChanged: (value) {
                      _durationMinutesPerQuestion = int.tryParse(value) ?? 2;
                    },
                  ),
                ),
              ],
            ),

            if (_selectedTemplates.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total: ${_pointsPerQuestion * _selectedTemplates.length} points, ${_durationMinutesPerQuestion * _selectedTemplates.length} minutes',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Step _buildReviewStep() {
    // Determine subject for display
    final reviewSubject = _selectedSubject ??
        (_selectedTemplates.isNotEmpty &&
                _selectedTemplates.first.subjects.isNotEmpty
            ? ActivitySubject.fromRaw(_selectedTemplates.first.subjects.first)
            : ActivitySubject.math);

    return Step(
      title: const Text('Review & Publish'),
      subtitle: const Text('Final review before publishing'),
      isActive: _currentStep == 3,
      state: StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Activity summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Title', _titleController.text),
                  _buildSummaryRow('Description', _descriptionController.text),
                  _buildSummaryRow(
                    'Subject',
                    reviewSubject.displayName,
                  ),
                  _buildSummaryRow(
                    'Age Group',
                    _selectedAgeGroup == AgeGroup.junior
                        ? 'Junior Explorer (6-8)'
                        : 'Bright Minds (9-12)',
                  ),
                  _buildSummaryRow('Questions', '${_selectedTemplates.length}'),
                  _buildSummaryRow(
                    'Game Types',
                    _selectedTemplates
                        .map((t) =>
                            TemplateMetadataUtils.getRecommendedGameType(t)
                                ?.displayName ??
                            'N/A')
                        .toSet()
                        .join(', '),
                  ),
                  _buildSummaryRow(
                      'Points Per Question', '$_pointsPerQuestion'),
                  _buildSummaryRow(
                    'Total Points',
                    '${_pointsPerQuestion * _selectedTemplates.length}',
                  ),
                  _buildSummaryRow(
                    'Duration Per Question',
                    '$_durationMinutesPerQuestion minutes',
                  ),
                  _buildSummaryRow(
                    'Total Duration',
                    '${_durationMinutesPerQuestion * _selectedTemplates.length} minutes (excluding game play time)',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selected templates preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Questions (${_selectedTemplates.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ..._selectedTemplates.take(5).map((template) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${template.title}',
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }),
                  if (_selectedTemplates.length > 5)
                    Text(
                      '... and ${_selectedTemplates.length - 5} more',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: SafePlayColors.neutral600,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Publish button
          ElevatedButton.icon(
            onPressed: _creating ? null : _createAndPublish,
            icon: _creating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.publish),
            label: Text(_creating ? 'Publishing...' : 'Create & Publish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.brandTeal500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: SafePlayColors.neutral600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Filter step - just move to next
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      // Template selection - check if at least one selected
      if (_selectedTemplates.isEmpty) {
        _showError('Please select at least one question template');
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      // Configuration - validate form
      if (!_formKey.currentState!.validate()) return;
      setState(() => _currentStep = 3);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  IconData _getTemplateIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Icons.quiz;
      case QuestionType.textInput:
        return Icons.edit;
      case QuestionType.dragDrop:
        return Icons.drag_indicator;
      case QuestionType.matching:
        return Icons.compare_arrows;
      case QuestionType.sequencing:
        return Icons.sort;
      case QuestionType.trueFalse:
        return Icons.check_circle_outline;
    }
  }
}
