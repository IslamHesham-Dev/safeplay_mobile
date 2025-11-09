import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/question_template.dart';
import '../../models/activity.dart';
import '../../models/user_type.dart';
import '../../services/simple_template_service.dart';
import '../../services/break_activities_service.dart';

/// Dedicated Browse Templates screen for activity creation
/// Can be embedded in wizard or used standalone
class TemplateBrowserScreen extends StatefulWidget {
  final ActivitySubject? selectedSubject;
  final AgeGroup selectedAgeGroup;
  final bool includeBreakActivities;
  final List<QuestionTemplate> selectedTemplates;
  final Function(List<QuestionTemplate>) onTemplatesSelected;

  const TemplateBrowserScreen({
    super.key,
    required this.selectedSubject,
    required this.selectedAgeGroup,
    required this.includeBreakActivities,
    required this.selectedTemplates,
    required this.onTemplatesSelected,
  });

  @override
  State<TemplateBrowserScreen> createState() => _TemplateBrowserScreenState();
}

class _TemplateBrowserScreenState extends State<TemplateBrowserScreen> {
  late final SimpleTemplateService _simpleTemplateService;
  late final BreakActivitiesService _breakActivitiesService;

  List<QuestionTemplate> _allTemplates = [];
  List<QuestionTemplate> _filteredTemplates = [];
  List<QuestionTemplate> _selectedTemplates = [];
  String _searchQuery = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _simpleTemplateService = SimpleTemplateService();
    _breakActivitiesService = BreakActivitiesService();
    _selectedTemplates = List.from(widget.selectedTemplates);
    _loadTemplates();
  }

  @override
  void didUpdateWidget(TemplateBrowserScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload templates if filters changed
    if (oldWidget.selectedSubject != widget.selectedSubject ||
        oldWidget.selectedAgeGroup != widget.selectedAgeGroup ||
        oldWidget.includeBreakActivities != widget.includeBreakActivities) {
      _loadTemplates();
    }
    // Update selected templates if they changed externally
    if (widget.selectedTemplates != oldWidget.selectedTemplates) {
      _selectedTemplates = List.from(widget.selectedTemplates);
    }
  }

  Future<void> _loadTemplates() async {
    debugPrint('📚 TemplateBrowserScreen: Loading templates...');
    debugPrint('📚 Subject: ${widget.selectedSubject}');
    debugPrint('📚 Age Group: ${widget.selectedAgeGroup}');
    debugPrint('📚 Include Break Activities: ${widget.includeBreakActivities}');

    setState(() => _loading = true);

    try {
      final allTemplates = <QuestionTemplate>[];

      // Load curriculum questions
      debugPrint('📚 Loading curriculum templates...');
      final curriculumTemplates =
          await _simpleTemplateService.getAllTemplates();
      debugPrint(
          '📚 Loaded ${curriculumTemplates.length} curriculum templates');
      allTemplates.addAll(curriculumTemplates);

      // Load break activities if needed
      if (widget.includeBreakActivities) {
        debugPrint('📚 Loading break activities for Junior...');
        final juniorBreaks = await _breakActivitiesService.getBreakActivities(
          ageGroup: AgeGroup.junior,
          activeOnly: true,
        );
        debugPrint('📚 Loaded ${juniorBreaks.length} Junior break activities');
        allTemplates.addAll(juniorBreaks);

        debugPrint('📚 Loading break activities for Bright...');
        final brightBreaks = await _breakActivitiesService.getBreakActivities(
          ageGroup: AgeGroup.bright,
          activeOnly: true,
        );
        debugPrint('📚 Loaded ${brightBreaks.length} Bright break activities');
        allTemplates.addAll(brightBreaks);
      }

      // Filter by subject and age group
      _filteredTemplates = allTemplates.where((template) {
        // Check if this is a break activity
        // Break activities come from breakActivities collection and may have:
        // - isBreakActivity: true in metadata
        // - subjects containing 'wellbeing' or 'mindfulness'
        // - empty subjects array
        final isBreakActivity = template.id.startsWith('break_') ||
            template.subjects.any((s) =>
                s.name.toLowerCase().contains('wellbeing') ||
                s.name.toLowerCase().contains('mindfulness')) ||
            (template.subjects.isEmpty &&
                (template.title.toLowerCase().contains('breathing') ||
                    template.title.toLowerCase().contains('yoga') ||
                    template.title.toLowerCase().contains('mindful') ||
                    template.title.toLowerCase().contains('break')));

        debugPrint(
            'Template: ${template.title}, isBreak: $isBreakActivity, subjects: ${template.subjects.map((s) => s.name)}');

        // If NOT including break activities, filter them out
        if (!widget.includeBreakActivities && isBreakActivity) {
          debugPrint('⏭️ Filtering out break activity: ${template.title}');
          return false;
        }

        // If break activities are included and this is one, skip subject filter
        // But still apply age group filter
        if (widget.includeBreakActivities && isBreakActivity) {
          // Age group filter still applies
          if (!template.ageGroups.contains(widget.selectedAgeGroup)) {
            debugPrint(
                '⏭️ Skipping break activity ${template.title} - age group mismatch (${template.ageGroups} vs ${widget.selectedAgeGroup})');
            return false;
          }
          debugPrint('✅ Including break activity: ${template.title}');
          return true; // Break activities pass through (subject doesn't apply)
        }

        // For regular curriculum templates, apply subject filter
        if (widget.selectedSubject != null) {
          if (!template.subjects.contains(widget.selectedSubject!)) {
            debugPrint(
                '⏭️ Skipping template ${template.title} - subject mismatch');
            return false;
          }
        }

        // Age group filter (applies to all)
        if (!template.ageGroups.contains(widget.selectedAgeGroup)) {
          debugPrint(
              '⏭️ Skipping template ${template.title} - age group mismatch');
          return false;
        }

        debugPrint('✅ Including template: ${template.title}');
        return true;
      }).toList();

      debugPrint(
          '📊 Filtered templates: ${_filteredTemplates.length} out of ${allTemplates.length}');
      debugPrint(
          '📊 Break activities included: ${widget.includeBreakActivities}');

      _allTemplates = _filteredTemplates;
      _applySearchFilter();

      debugPrint(
          '✅ TemplateBrowserScreen: Loading complete. Showing ${_filteredTemplates.length} templates');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading templates: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      // Show error in empty state
      _filteredTemplates = [];
      _allTemplates = [];
    } finally {
      setState(() {
        _loading = false;
        debugPrint('🔄 TemplateBrowserScreen: Loading state set to false');
      });
    }
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredTemplates = List.from(_allTemplates);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredTemplates = _allTemplates.where((template) {
        return template.title.toLowerCase().contains(query) ||
            template.prompt.toLowerCase().contains(query) ||
            template.skills.any((skill) => skill.toLowerCase().contains(query));
      }).toList();
    }

    // Update parent
    widget.onTemplatesSelected(_selectedTemplates);
  }

  void _toggleTemplate(QuestionTemplate template) {
    setState(() {
      if (_selectedTemplates.contains(template)) {
        _selectedTemplates.remove(template);
      } else {
        _selectedTemplates.add(template);
      }
      widget.onTemplatesSelected(_selectedTemplates);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search templates...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _applySearchFilter();
                  });
                },
              ),
              if (_selectedTemplates.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success.withOpacity(0.1),
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
        ),

        // Templates list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filteredTemplates.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final template = _filteredTemplates[index];
                        final isSelected =
                            _selectedTemplates.contains(template);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTemplateCard(template, isSelected),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _loading ? 'Loading templates...' : 'No templates found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _loading
                  ? 'Please wait while we fetch available templates'
                  : 'Try adjusting your filters or search query',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (!_loading) ...[
              const SizedBox(height: 16),
              Text(
                'Current filters:\n'
                'Subject: ${widget.selectedSubject?.name ?? "All"}\n'
                'Age Group: ${widget.selectedAgeGroup.name}\n'
                'Break Activities: ${widget.includeBreakActivities ? "Included" : "Excluded"}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(QuestionTemplate template, bool isSelected) {
    // Check if this is a break activity
    final isBreakActivity = template.id.startsWith('break_') ||
        template.subjects.any((s) =>
            s.name.toLowerCase().contains('wellbeing') ||
            s.name.toLowerCase().contains('mindfulness')) ||
        (template.subjects.isEmpty &&
            (template.title.toLowerCase().contains('breathing') ||
                template.title.toLowerCase().contains('yoga') ||
                template.title.toLowerCase().contains('mindful') ||
                template.title.toLowerCase().contains('break')));

    // Distinct styling for break activities
    final backgroundColor = isBreakActivity
        ? Colors.purple.withOpacity(0.08) // Light purple for break activities
        : _getTemplateBackgroundColor(template);
    final textColor = isBreakActivity
        ? Colors.purple[900]! // Dark purple text
        : _getTemplateTextColor(template);

    return GestureDetector(
      onTap: () => _toggleTemplate(template),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: isBreakActivity && isSelected
              ? Border.all(
                  color: Colors.purple,
                  width: 3,
                )
              : isSelected
                  ? Border.all(
                      color: SafePlayColors.brandTeal500,
                      width: 3,
                    )
                  : Border.all(
                      color: isBreakActivity
                          ? Colors.purple.withOpacity(0.3)
                          : Colors.transparent,
                      width: isBreakActivity ? 2 : 0,
                    ),
          boxShadow: [
            BoxShadow(
              color: isBreakActivity
                  ? Colors.purple.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isBreakActivity ? 16 : 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Positioned(
              left: 20,
              top: 20,
              right: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.prompt,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: textColor.withOpacity(0.7),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Break Activity tag (if applicable) - beside other tags
                      if (isBreakActivity)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple,
                                Colors.pink,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.self_improvement,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Break Activity',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Subject tags (only if not a break activity)
                      if (!isBreakActivity)
                        ...template.subjects.take(1).map((subject) {
                          final color = _getSubjectColor(subject);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getSubjectIcon(subject),
                                    size: 12, color: color),
                                const SizedBox(width: 4),
                                Text(
                                  subject == ActivitySubject.reading
                                      ? 'English'
                                      : subject.displayName,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      // Age group tag
                      if (template.ageGroups.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (template.ageGroups.first == AgeGroup.junior
                                    ? Colors.orange
                                    : Colors.purple)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            template.ageGroups.first == AgeGroup.junior
                                ? 'Junior'
                                : 'Bright',
                            style: TextStyle(
                              color: template.ageGroups.first == AgeGroup.junior
                                  ? Colors.orange
                                  : Colors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Game name tag (for BubblePop Grammar templates)
                      if (_isBubblePopGrammarTemplate(template.id)) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.games,
                                size: 12,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'BubblePop Grammar',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Game name tag (for Seashell Quiz templates)
                      if (_isSeashellQuizTemplate(template.id)) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.games,
                                size: 12,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Seashell Game',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Game name tag (for FishTank Quiz templates)
                      if (_isFishTankQuizTemplate(template.id)) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.games,
                                size: 12,
                                color: Colors.cyan,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'FishTank Game',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Game name tag (for Add Equations templates)
                      // Only show if not already a FishTank Game
                      if (!_isFishTankQuizTemplate(template.id) &&
                          _isAddEquationsTemplate(template.id)) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.games,
                                size: 12,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Add Equations',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                  if (template.defaultPoints > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.monetization_on,
                            size: 16, color: textColor.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(
                          '${template.defaultPoints} points',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Icon - Different style for break activities
            Positioned(
              right: -10,
              bottom: -10,
              child: isBreakActivity
                  ? Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.pink.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.self_improvement,
                        size: 50,
                        color: Colors.purple[700],
                      ),
                    )
                  : _buildTemplateIcon(template),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SafePlayColors.brandTeal500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTemplateBackgroundColor(QuestionTemplate template) {
    if (template.subjects.isEmpty) {
      return Colors.blue.withOpacity(0.15);
    }
    final subject = template.subjects.first;
    switch (subject) {
      case ActivitySubject.math:
        return Colors.blue.withOpacity(0.15);
      case ActivitySubject.science:
        return Colors.orange.withOpacity(0.15);
      case ActivitySubject.reading:
      case ActivitySubject.writing:
        return Colors.green.withOpacity(0.15);
      default:
        return Colors.purple.withOpacity(0.15);
    }
  }

  Color _getTemplateTextColor(QuestionTemplate template) {
    return Colors.black87;
  }

  Color _getSubjectColor(ActivitySubject subject) {
    switch (subject) {
      case ActivitySubject.math:
        return Colors.blue;
      case ActivitySubject.science:
        return Colors.orange;
      case ActivitySubject.reading:
      case ActivitySubject.writing:
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  IconData _getSubjectIcon(ActivitySubject subject) {
    switch (subject) {
      case ActivitySubject.math:
        return Icons.calculate;
      case ActivitySubject.science:
        return Icons.science;
      case ActivitySubject.reading:
        return Icons.menu_book;
      case ActivitySubject.writing:
        return Icons.edit;
      default:
        return Icons.school;
    }
  }

  Widget _buildTemplateIcon(QuestionTemplate template) {
    final icon = _getSubjectIcon(template.subjects.isNotEmpty
        ? template.subjects.first
        : ActivitySubject.math);
    final iconColor = _getSubjectColor(template.subjects.isNotEmpty
        ? template.subjects.first
        : ActivitySubject.math);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 50, color: iconColor),
    );
  }

  /// Check if template is a BubblePop Grammar template
  bool _isBubblePopGrammarTemplate(String templateId) {
    const bubblePopGrammarTemplates = [
      'english_junior_001_spelling_suffixes_ing',
      'english_junior_003_vocabulary_plurals_f_to_v',
      'english_junior_004_adverbs_how',
      'english_junior_007_spelling_ed_endings',
      'english_junior_008_grammar_nouns',
      'english_junior_009_grammar_verbs',
      'english_junior_010_grammar_adjectives',
      'english_junior_011_grammar_pronouns',
      'english_junior_012_grammar_plurals',
    ];
    return bubblePopGrammarTemplates.contains(templateId);
  }

  /// Check if template is a Seashell Quiz template
  bool _isSeashellQuizTemplate(String templateId) {
    const seashellQuizTemplates = [
      'english_junior_002_grammar_adverbs',
      'english_junior_005_language_strands_oral',
      'english_junior_006_comprehension_fact',
      'english_junior_013_vocabulary_antonyms',
      'english_junior_014_vocabulary_rhyming',
      'english_junior_015_vocabulary_categories',
      'english_junior_016_vocabulary_compound_words',
      'english_junior_017_vocabulary_sight_words',
    ];
    return seashellQuizTemplates.contains(templateId);
  }

  /// Check if template is a FishTank Quiz template
  bool _isFishTankQuizTemplate(String templateId) {
    const fishTankQuizTemplates = [
      'math_junior_003_addition_basic',
      'math_junior_004_subtraction_basic',
      'math_junior_008_data_handling',
      'math_junior_011_shapes_triangle',
      'math_junior_012_comparing_numbers',
      'math_junior_017_addition_within_20',
      'math_junior_018_subtraction_within_20',
      'math_junior_019_number_comparison',
      'math_junior_020_place_value_tens',
      'math_junior_021_doubles_facts',
    ];
    return fishTankQuizTemplates.contains(templateId);
  }

  /// Check if template is an Add Equations template
  /// Returns true if the template is for Add Equations game, but NOT if it's already a FishTank Game
  bool _isAddEquationsTemplate(String templateId) {
    // New Add Equations questions (24 questions)
    if (templateId.startsWith('math_junior_add_') ||
        templateId.startsWith('math_junior_sub_')) {
      return true;
    }

    // Updated questions that are now Add Equations
    const addEquationsTemplates = [
      'math_junior_013_patterns_skip_counting',
      'math_junior_014_patterns_skip_counting_5s',
      'math_junior_015_patterns_missing_numbers',
      'math_junior_016_mental_strategies_counting_on',
    ];
    return addEquationsTemplates.contains(templateId);
  }
}
