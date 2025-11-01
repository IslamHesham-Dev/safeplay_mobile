import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/teacher_service.dart';
import '../../services/activity_service.dart';
import '../../models/activity.dart';
import '../../models/question_template.dart';
import '../../models/game_activity.dart';
import '../../models/user_type.dart';
import '../../design_system/colors.dart';

class EnhancedActivityCreationScreen extends StatefulWidget {
  const EnhancedActivityCreationScreen({super.key});

  @override
  State<EnhancedActivityCreationScreen> createState() =>
      _EnhancedActivityCreationScreenState();
}

class _EnhancedActivityCreationScreenState
    extends State<EnhancedActivityCreationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectivesController = TextEditingController();

  late final TeacherService _teacherService;
  late final ActivityService _activityService;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  List<QuestionTemplate> _availableTemplates = [];
  List<QuestionTemplate> _selectedTemplates = [];
  List<GameType> _availableGames = [];
  GameType? _selectedGameType;
  GameConfig? _gameConfig;

  ActivitySubject _selectedSubject = ActivitySubject.math;
  AgeGroup _selectedAgeGroup = AgeGroup.junior;
  Difficulty _selectedDifficulty = Difficulty.easy;
  int _durationMinutes = 5;
  int _points = 100;

  bool _loading = false;
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _teacherService = TeacherService();
    _activityService = ActivityService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadInitialData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Load teacher profile (not used in this screen but kept for future use)
      await _teacherService.getTeacherProfile(currentUser.id);

      // Load available templates
      _availableTemplates = await _teacherService.getQuestionTemplates(
        teacherId: currentUser.id,
        subjects: [_selectedSubject],
        ageGroups: [_selectedAgeGroup],
      );

      // Set available games based on age group
      _updateAvailableGames();

      // Set default values
      _setDefaultValues();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _updateAvailableGames() {
    _availableGames = GameType.values
        .where((game) => game.supportedAgeGroups.contains(_selectedAgeGroup))
        .where((game) => game.supportedSubjects.contains(_selectedSubject))
        .toList();
  }

  void _setDefaultValues() {
    final gameType = _availableGames.isNotEmpty ? _availableGames.first : null;
    _selectedGameType = gameType;

    if (gameType != null) {
      _gameConfig = _createDefaultGameConfig(gameType);
    }

    // Set friendly default title and description
    _titleController.text = _generateFriendlyTitle();
    _descriptionController.text = _generateFriendlyDescription();
  }

  String _generateFriendlyTitle() {
    if (_selectedGameType == null) return '';

    final gameName = _selectedGameType!.displayName;
    final subject = _selectedSubject.displayName;
    final ageGroup = _selectedAgeGroup == AgeGroup.junior ? 'Junior' : 'Bright';

    return '$gameName - $subject Fun for $ageGroup Minds!';
  }

  String _generateFriendlyDescription() {
    if (_selectedGameType == null) return '';

    final gameDesc = _selectedGameType!.description;
    final subject = _selectedSubject.displayName;

    return 'Join us for an exciting $subject adventure! $gameDesc Perfect for learning while having fun!';
  }

  GameConfig _createDefaultGameConfig(GameType gameType) {
    return GameConfig(
      gameType: gameType,
      settings: _getDefaultGameSettings(gameType),
      questionTemplateIds: _selectedTemplates.map((t) => t.id).toList(),
      timeLimitSeconds: _durationMinutes * 60,
      maxAttempts: 3,
      allowHints: true,
      showProgress: true,
      accessibilityOptions: _getDefaultAccessibilityOptions(),
    );
  }

  Map<String, dynamic> _getDefaultGameSettings(GameType gameType) {
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
      case GameType.inverseOperationChain:
        return {
          'maxOperations': 3,
          'numberRange': [1, 100],
        };
      default:
        return {};
    }
  }

  Map<String, dynamic> _getDefaultAccessibilityOptions() {
    return {
      'highContrast': false,
      'largeText': false,
      'audioFeedback': true,
      'hapticFeedback': true,
      'voiceOver': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Activity')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitialData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Game Activity'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Game Type Selection
                _buildGameTypeSelection(),

                const SizedBox(height: 24),

                // Basic Information
                _buildBasicInformation(),

                const SizedBox(height: 24),

                // Question Templates Selection
                _buildTemplateSelection(),

                const SizedBox(height: 24),

                // Game Configuration
                if (_selectedGameType != null) _buildGameConfiguration(),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameTypeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Game Type',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SafePlayColors.brandTeal500,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableGames.map((game) {
                final isSelected = _selectedGameType == game;
                return FilterChip(
                  label: Text(game.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGameType = selected ? game : null;
                      if (selected) {
                        _gameConfig = _createDefaultGameConfig(game);
                      }
                    });
                  },
                  selectedColor:
                      SafePlayColors.brandTeal500.withValues(alpha: 0.2),
                  checkmarkColor: SafePlayColors.brandTeal500,
                );
              }).toList(),
            ),
            if (_selectedGameType != null) ...[
              const SizedBox(height: 12),
              Text(
                _selectedGameType!.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SafePlayColors.neutral600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SafePlayColors.brandTeal500,
                  ),
            ),
            const SizedBox(height: 16),

            // Subject and Age Group
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ActivitySubject>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    items: ActivitySubject.values.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSubject = value;
                          _updateAvailableGames();
                          _setDefaultValues();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<AgeGroup>(
                    value: _selectedAgeGroup,
                    decoration: const InputDecoration(
                      labelText: 'Age Group',
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
                        setState(() {
                          _selectedAgeGroup = value;
                          _updateAvailableGames();
                          _setDefaultValues();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
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
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Learning Objectives
            TextFormField(
              controller: _objectivesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Learning Objectives (comma-separated)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
                hintText:
                    'e.g., Count to 100, Add single digits, Identify patterns',
              ),
            ),

            const SizedBox(height: 16),

            // Duration and Points
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _durationMinutes.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    onChanged: (value) {
                      _durationMinutes = int.tryParse(value) ?? 5;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _points.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Points',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.stars),
                    ),
                    onChanged: (value) {
                      _points = int.tryParse(value) ?? 100;
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

  Widget _buildTemplateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Question Templates',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SafePlayColors.brandTeal500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose from ${_availableTemplates.length} available templates',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SafePlayColors.neutral600,
                  ),
            ),
            const SizedBox(height: 16),
            if (_availableTemplates.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SafePlayColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No templates available for the selected subject and age group.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SafePlayColors.neutral600,
                      ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableTemplates.length,
                itemBuilder: (context, index) {
                  final template = _availableTemplates[index];
                  final isSelected = _selectedTemplates.contains(template);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      title: Text(template.title),
                      subtitle: Text(template.prompt),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedTemplates.add(template);
                          } else {
                            _selectedTemplates.remove(template);
                          }
                        });
                      },
                      secondary: Icon(
                        _getTemplateIcon(template.type),
                        color: SafePlayColors.brandTeal500,
                      ),
                    ),
                  );
                },
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
                    Text(
                      '${_selectedTemplates.length} template(s) selected',
                      style: TextStyle(
                        color: SafePlayColors.success,
                        fontWeight: FontWeight.bold,
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

  Widget _buildGameConfiguration() {
    if (_selectedGameType == null || _gameConfig == null)
      return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Configuration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SafePlayColors.brandTeal500,
                  ),
            ),
            const SizedBox(height: 16),

            // Time Limit
            TextFormField(
              initialValue: (_gameConfig!.timeLimitSeconds / 60).toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Time Limit (minutes)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              onChanged: (value) {
                final minutes = int.tryParse(value) ?? 5;
                setState(() {
                  _gameConfig = _gameConfig!.copyWith(
                    timeLimitSeconds: minutes * 60,
                  );
                });
              },
            ),

            const SizedBox(height: 16),

            // Max Attempts
            TextFormField(
              initialValue: _gameConfig!.maxAttempts.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Attempts',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              onChanged: (value) {
                final attempts = int.tryParse(value) ?? 3;
                setState(() {
                  _gameConfig = _gameConfig!.copyWith(
                    maxAttempts: attempts,
                  );
                });
              },
            ),

            const SizedBox(height: 16),

            // Accessibility Options
            Text(
              'Accessibility Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Allow Hints'),
              subtitle: const Text('Show helpful hints during gameplay'),
              value: _gameConfig!.allowHints,
              onChanged: (value) {
                setState(() {
                  _gameConfig = _gameConfig!.copyWith(allowHints: value);
                });
              },
            ),

            SwitchListTile(
              title: const Text('Show Progress'),
              subtitle: const Text('Display progress indicators'),
              value: _gameConfig!.showProgress,
              onChanged: (value) {
                setState(() {
                  _gameConfig = _gameConfig!.copyWith(showProgress: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isCreating ? null : _createActivity,
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.brandTeal500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Create & Publish'),
          ),
        ),
      ],
    );
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

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one question template'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGameType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a game type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final auth = context.read<AuthProvider>();
      final currentUser = auth.currentUser!;

      // Create questions from templates
      final questions = _selectedTemplates.map((template) {
        return template.instantiate(
          questionId: 'q_${_selectedTemplates.indexOf(template) + 1}',
        );
      }).toList();

      // Create learning objectives list
      final objectives = _objectivesController.text
          .split(',')
          .map((obj) => obj.trim())
          .where((obj) => obj.isNotEmpty)
          .toList();

      // Create base activity
      final now = DateTime.now();
      final activity = Activity(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: _selectedSubject,
        ageGroup: _selectedAgeGroup,
        difficulty: _selectedDifficulty,
        durationMinutes: _durationMinutes,
        points: _points,
        learningObjectives: objectives,
        questions: questions,
        createdBy: currentUser.id,
        published: true,
        publishState: PublishState.published,
        skills: _selectedTemplates.expand((t) => t.skills).toList(),
        tags: [_selectedGameType!.name, _selectedSubject.name],
        createdAt: now,
        updatedAt: now,
      );

      // Create game activity
      final gameActivity = GameActivity.fromActivity(
        activity,
        gameConfig: _gameConfig!,
        gameMetadata: {
          'createdAt': now.toIso8601String(),
          'teacherId': currentUser.id,
          'gameType': _selectedGameType!.name,
        },
      );

      // Save to Firestore
      await _activityService.upsertActivity(
        activity: gameActivity,
        actorRole: UserType.teacher,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Activity "${gameActivity.title}" created and published successfully!'),
            backgroundColor: SafePlayColors.success,
          ),
        );
        Navigator.of(context).pop();
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
      setState(() => _isCreating = false);
    }
  }
}

// Extension to add copyWith method to GameConfig
extension GameConfigCopyWith on GameConfig {
  GameConfig copyWith({
    GameType? gameType,
    Map<String, dynamic>? settings,
    List<String>? questionTemplateIds,
    int? timeLimitSeconds,
    int? maxAttempts,
    bool? allowHints,
    bool? showProgress,
    Map<String, dynamic>? accessibilityOptions,
  }) {
    return GameConfig(
      gameType: gameType ?? this.gameType,
      settings: settings ?? this.settings,
      questionTemplateIds: questionTemplateIds ?? this.questionTemplateIds,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      allowHints: allowHints ?? this.allowHints,
      showProgress: showProgress ?? this.showProgress,
      accessibilityOptions: accessibilityOptions ?? this.accessibilityOptions,
    );
  }
}
