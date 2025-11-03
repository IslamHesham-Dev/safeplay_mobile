import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/colors.dart';
import '../../models/activity.dart';
import '../../models/game_activity.dart';
import '../../models/user_type.dart';
import '../../services/activity_service.dart';
import '../../navigation/route_names.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'teacher_activities_management_screen.dart';

/// Success screen shown after activity is published
/// Shows activity details and options to view/delete
class ActivityPublishedSuccessScreen extends StatefulWidget {
  final Activity activity;
  final String activityId;
  final List<String>?
      questionTemplateIds; // Store template IDs for break game detection

  const ActivityPublishedSuccessScreen({
    super.key,
    required this.activity,
    required this.activityId,
    this.questionTemplateIds,
  });

  @override
  State<ActivityPublishedSuccessScreen> createState() =>
      _ActivityPublishedSuccessScreenState();
}

class _ActivityPublishedSuccessScreenState
    extends State<ActivityPublishedSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _deleteActivity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text(
          'Are you sure you want to delete "${widget.activity.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _deleting = true);

    try {
      final auth = context.read<AuthProvider>();
      final teacherId = auth.currentUser?.id;

      if (teacherId == null) {
        throw Exception('No teacher ID found');
      }

      final activityService = ActivityService();
      await activityService.deleteActivity(
        activityId: widget.activityId,
        actorRole: UserType.teacher,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity deleted successfully'),
            backgroundColor: SafePlayColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Activity Published'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Success animation - Impressive celebration
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SafePlayColors.success,
                        SafePlayColors.success.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SafePlayColors.success.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Success message - Friendly and impressive
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      '🎉 Awesome! Your Activity is Live!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: SafePlayColors.brandTeal500,
                                fontSize: 24,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: SafePlayColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: SafePlayColors.success.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Children can now discover and play your activity!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: SafePlayColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Activity details card - Enhanced UI
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        SafePlayColors.brandTeal500.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.activity.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: SafePlayColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: SafePlayColors.success,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: SafePlayColors.success,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Published',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: SafePlayColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.activity.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Activity stats
                        _buildInfoRow(
                          Icons.book,
                          'Subject',
                          widget.activity.subject.displayName,
                          SafePlayColors.brandTeal500,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.people,
                          'Age Group',
                          widget.activity.ageGroup == AgeGroup.junior
                              ? 'Junior Explorer (6-8)'
                              : 'Bright Minds (9-12)',
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.quiz,
                          'Total Questions',
                          '${widget.activity.questions.length} questions',
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.quiz,
                          'Questions Breakdown',
                          _buildQuestionBreakdown(),
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.stars,
                          'Total Points',
                          '${widget.activity.points} points',
                          Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.timer,
                          'Duration',
                          '${widget.activity.durationMinutes} minutes (excluding game play time)',
                          Colors.green,
                        ),

                        // Learning objectives if available
                        if (widget.activity.learningObjectives.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: SafePlayColors.brandTeal500
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.flag,
                                    color: SafePlayColors.brandTeal500,
                                    size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Learning Objectives',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...widget.activity.learningObjectives.map((obj) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10, left: 40),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: SafePlayColors.brandTeal500,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      obj,
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
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to activities management screen
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TeacherActivitiesManagementScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('View All Activities'),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleting ? null : _deleteActivity,
                        icon: _deleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_outline),
                        label:
                            Text(_deleting ? 'Deleting...' : 'Delete Activity'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
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

              const SizedBox(height: 24),

              // Done button - redirects to dashboard
              FadeTransition(
                opacity: _fadeAnimation,
                child: TextButton(
                  onPressed: () {
                    // Navigate back to teacher dashboard
                    context.go(RouteNames.teacherDashboard);
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildQuestionBreakdown() {
    // Try to identify break activities from activity metadata or question template IDs
    int breakCount = 0;
    int curriculumCount = 0;

    // First, check if we have template IDs passed directly
    if (widget.questionTemplateIds != null &&
        widget.questionTemplateIds!.isNotEmpty) {
      for (final templateId in widget.questionTemplateIds!) {
        final isBreak = templateId.startsWith('break_') ||
            templateId.toLowerCase().contains('break') ||
            templateId.toLowerCase().contains('wellbeing') ||
            templateId.toLowerCase().contains('mindfulness');
        if (isBreak) {
          breakCount++;
        } else {
          curriculumCount++;
        }
      }
    }
    // Check if activity has game metadata with template IDs
    else if (widget.activity is GameActivity) {
      final gameActivity = widget.activity as GameActivity;
      final templateIds = gameActivity.gameConfig.questionTemplateIds;

      for (final templateId in templateIds) {
        final isBreak = templateId.startsWith('break_') ||
            templateId.toLowerCase().contains('break') ||
            templateId.toLowerCase().contains('wellbeing') ||
            templateId.toLowerCase().contains('mindfulness');
        if (isBreak) {
          breakCount++;
        } else {
          curriculumCount++;
        }
      }
    }

    // If we couldn't determine from template IDs (or not GameActivity), check questions directly
    if (breakCount == 0 && curriculumCount == 0) {
      // Check question IDs or structure for break activity indicators
      for (final question in widget.activity.questions) {
        if (_isBreakQuestion(question)) {
          breakCount++;
        } else {
          curriculumCount++;
        }
      }
    }

    // Final fallback: all curriculum if still unknown
    if (breakCount == 0 && curriculumCount == 0) {
      curriculumCount = widget.activity.questions.length;
    }

    return '$curriculumCount curriculum questions\n'
        '$breakCount break game questions';
  }

  bool _isBreakQuestion(ActivityQuestion question) {
    final questionId = question.id.toLowerCase();
    final questionText = question.question.toLowerCase();
    return questionId.contains('break') ||
        questionText.contains('breathing') ||
        questionText.contains('mindful') ||
        questionText.contains('yoga') ||
        questionText.contains('wellbeing') ||
        questionText.contains('relaxation') ||
        questionText.contains('meditation');
  }
}
