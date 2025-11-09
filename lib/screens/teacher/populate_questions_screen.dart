import 'package:flutter/material.dart';
import '../../services/question_template_populator.dart';
import '../../services/break_activities_populator.dart';
import '../../design_system/colors.dart';

/// Admin screen to populate question templates in Firebase
/// Accessible to teachers for initial setup
class PopulateQuestionsScreen extends StatefulWidget {
  const PopulateQuestionsScreen({super.key});

  @override
  State<PopulateQuestionsScreen> createState() =>
      _PopulateQuestionsScreenState();
}

class _PopulateQuestionsScreenState extends State<PopulateQuestionsScreen> {
  final QuestionTemplatePopulator _populator = QuestionTemplatePopulator();
  final BreakActivitiesPopulator _breakPopulator = BreakActivitiesPopulator();

  bool _populating = false;
  String? _status;
  int _questionsAdded = 0;

  Future<void> _populateMathQuestions() async {
    setState(() {
      _populating = true;
      _status = 'Starting Math population...';
      _questionsAdded = 0;
    });

    try {
      await _populator.populateMathQuestions();

      setState(() {
        _status = '✅ Successfully populated Math questions!';
        _questionsAdded = 29; // 14 Junior + 15 Bright
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully added $_questionsAdded Math question templates!'),
            backgroundColor: SafePlayColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error populating Math questions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _populateEnglishQuestions() async {
    setState(() {
      _populating = true;
      _status = 'Starting English population...';
      _questionsAdded = 0;
    });

    try {
      await _populator.populateEnglishQuestions();

      setState(() {
        _status = '✅ Successfully populated English questions!';
        _questionsAdded = 17; // 7 Junior + 10 Bright
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully added $_questionsAdded English question templates!'),
            backgroundColor: SafePlayColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error populating English questions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _populateScienceQuestions() async {
    setState(() {
      _populating = true;
      _status = 'Starting Science population...';
      _questionsAdded = 0;
    });

    try {
      await _populator.populateScienceQuestions();

      setState(() {
        _status = '✅ Successfully populated Science questions!';
        _questionsAdded = 16; // 8 Junior + 8 Bright
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully added $_questionsAdded Science question templates!'),
            backgroundColor: SafePlayColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error populating Science questions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _populateBreakActivities() async {
    setState(() {
      _populating = true;
      _status = 'Starting Break Activities population...';
      _questionsAdded = 0;
    });

    try {
      await _breakPopulator.populateBreakActivities();

      setState(() {
        _status = '✅ Successfully populated Break Activities!';
        _questionsAdded = 22; // 10 Junior + 12 Bright
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully added $_questionsAdded break activity templates!'),
            backgroundColor: SafePlayColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error populating Break Activities: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _updateQuestionTemplate() async {
    setState(() {
      _populating = true;
      _status = 'Updating question template...';
      _questionsAdded = 0;
    });

    try {
      await _populator
          .updateQuestionTemplate('english_junior_006_comprehension_fact');

      setState(() {
        _status = '✅ Successfully updated question template!';
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Successfully updated english_junior_006_comprehension_fact template!'),
            backgroundColor: SafePlayColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _populating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating question template: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Populate Question Templates'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: SafePlayColors.brandTeal500,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Question Templates Setup',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This tool populates the "curriculumQuestionTemplates" collection in Firebase with structured questions for Math, English, and Science, designed for Junior (6-8) and Bright (9-12) age groups.\n\nThis is a new collection separate from the old "questionTemplates" collection for better organization.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Each template includes:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...[
                      '• Complete question content (prompt, options, answers)',
                      '• Game type mapping (best games for each question)',
                      '• Points and difficulty levels',
                      '• Skills and topics for tracking',
                      '• Age-appropriate metadata'
                    ].map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Math Questions Section
            Card(
              color: SafePlayColors.brandTeal500.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calculate,
                          color: SafePlayColors.brandTeal500,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Math Questions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Populate Math question templates:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          _buildQuestionCountRow('Junior (6-8)', 14),
                          const Divider(height: 16),
                          _buildQuestionCountRow('Bright (9-12)', 15),
                          const Divider(height: 16),
                          _buildQuestionCountRow('Total', 29, isTotal: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_status != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _status!.startsWith('✅')
                              ? SafePlayColors.success.withValues(alpha: 0.1)
                              : _status!.startsWith('❌')
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _status!.startsWith('✅')
                                ? SafePlayColors.success
                                : _status!.startsWith('❌')
                                    ? Colors.red
                                    : Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _status!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _status!.startsWith('✅')
                                      ? SafePlayColors.success
                                      : _status!.startsWith('❌')
                                          ? Colors.red
                                          : Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _populating ? null : _populateMathQuestions,
                        icon: _populating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: Text(
                          _populating
                              ? 'Populating...'
                              : 'Populate Math Questions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SafePlayColors.brandTeal500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // English Questions Section
            Card(
              color: Colors.blue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, color: Colors.blue, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'English Questions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Populate English question templates:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          _buildQuestionCountRow('Junior (6-8)', 7,
                              color: Colors.blue),
                          const Divider(height: 16),
                          _buildQuestionCountRow('Bright (9-12)', 10,
                              color: Colors.blue),
                          const Divider(height: 16),
                          _buildQuestionCountRow('Total', 17,
                              isTotal: true, color: Colors.blue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_status != null &&
                        (_status!.contains('English') ||
                            _status!.contains('updated'))) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _status!.startsWith('✅')
                              ? SafePlayColors.success.withValues(alpha: 0.1)
                              : _status!.startsWith('❌')
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _status!.startsWith('✅')
                                ? SafePlayColors.success
                                : _status!.startsWith('❌')
                                    ? Colors.red
                                    : Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _status!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _status!.startsWith('✅')
                                      ? SafePlayColors.success
                                      : _status!.startsWith('❌')
                                          ? Colors.red
                                          : Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _populating ? null : _populateEnglishQuestions,
                        icon: _populating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: Text(
                          _populating
                              ? 'Populating...'
                              : 'Populate English Questions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _populating ? null : _updateQuestionTemplate,
                        icon: _populating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                              )
                            : const Icon(Icons.update),
                        label: const Text(
                          'Update Vocabulary Question',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Science Questions Section
            _buildSubjectCard(
              'Science Questions',
              Icons.science,
              Colors.green,
              8, // Junior
              8, // Bright
              16, // Total
              _populateScienceQuestions,
            ),

            const SizedBox(height: 24),

            // Break Activities Section
            Card(
              color: Colors.purple.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.self_improvement,
                            color: Colors.purple, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Break Activities & Mindful Games',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Populate mindful and fun break activities:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          _buildQuestionCountRow('Junior (6-8)', 10,
                              color: Colors.purple),
                          const Divider(height: 16),
                          _buildQuestionCountRow('Bright (9-12)', 12,
                              color: Colors.purple),
                          const Divider(height: 16),
                          _buildQuestionCountRow('Total', 22,
                              isTotal: true, color: Colors.purple),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.purple, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Break Activities Include:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...[
                            'Breathing exercises',
                            'Coloring & creative activities',
                            'Yoga & movement',
                            'Mindfulness & meditation',
                            'Emotional awareness games',
                            'Music & rhythm',
                            'Puzzles & challenges',
                            'Gratitude exercises'
                          ].map((item) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 4, left: 8),
                                child: Text(
                                  '• $item',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_status != null && _status!.contains('Break')) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _status!.startsWith('✅')
                              ? SafePlayColors.success.withValues(alpha: 0.1)
                              : _status!.startsWith('❌')
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _status!.startsWith('✅')
                                ? SafePlayColors.success
                                : _status!.startsWith('❌')
                                    ? Colors.red
                                    : Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _status!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _status!.startsWith('✅')
                                      ? SafePlayColors.success
                                      : _status!.startsWith('❌')
                                          ? Colors.red
                                          : Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _populating ? null : _populateBreakActivities,
                        icon: _populating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.self_improvement),
                        label: Text(
                          _populating
                              ? 'Populating...'
                              : 'Populate Break Activities',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Templates will be created with proper game type mappings\n'
                      '• Each question includes points, difficulty, and skills\n'
                      '• Questions are optimized for Junior vs Bright age groups\n'
                      '• All templates will be marked as active (isActive: true)\n'
                      '• You can disable templates later from the Templates tab',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCountRow(String label, int count,
      {bool isTotal = false, Color? color}) {
    final displayColor = color ?? SafePlayColors.brandTeal500;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isTotal
                ? displayColor.withValues(alpha: 0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count questions',
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? displayColor : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(
    String title,
    IconData icon,
    Color color,
    int juniorCount,
    int brightCount,
    int totalCount,
    Future<void> Function() onPopulate,
  ) {
    return Card(
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Populate $title templates:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _buildQuestionCountRow('Junior (6-8)', juniorCount,
                      color: color),
                  const Divider(height: 16),
                  _buildQuestionCountRow('Bright (9-12)', brightCount,
                      color: color),
                  const Divider(height: 16),
                  _buildQuestionCountRow('Total', totalCount,
                      isTotal: true, color: color),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_status != null &&
                _status!.contains(title.split(' ').first)) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _status!.startsWith('✅')
                      ? SafePlayColors.success.withValues(alpha: 0.1)
                      : _status!.startsWith('❌')
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _status!.startsWith('✅')
                        ? SafePlayColors.success
                        : _status!.startsWith('❌')
                            ? Colors.red
                            : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _status!,
                        style: TextStyle(
                          fontSize: 13,
                          color: _status!.startsWith('✅')
                              ? SafePlayColors.success
                              : _status!.startsWith('❌')
                                  ? Colors.red
                                  : Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _populating ? null : onPopulate,
                icon: _populating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _populating ? 'Populating...' : 'Populate $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
