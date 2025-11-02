import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../design_system/colors.dart';
import '../../models/activity.dart';
import '../../models/user_type.dart';
import '../../providers/auth_provider.dart';
import '../../services/activity_service.dart';

/// Screen for teachers to view and manage all their activities
class TeacherActivitiesManagementScreen extends StatefulWidget {
  const TeacherActivitiesManagementScreen({super.key});

  @override
  State<TeacherActivitiesManagementScreen> createState() =>
      _TeacherActivitiesManagementScreenState();
}

class _TeacherActivitiesManagementScreenState
    extends State<TeacherActivitiesManagementScreen> {
  final ActivityService _activityService = ActivityService();
  final TextEditingController _searchController = TextEditingController();

  List<Activity> _allActivities = [];
  List<Activity> _filteredActivities = [];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  AgeGroup? _selectedAgeGroup; // Filter by age group (null = all)
  Set<String> _expandedActivities = {}; // Track which activities are expanded
  Map<String, Map<String, dynamic>> _activityRawData =
      {}; // Store raw data for accessing gameConfig

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadActivities();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  Future<void> _loadActivities() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final teacherId = auth.currentUser?.id;

      if (teacherId == null) {
        throw Exception('No teacher ID found');
      }

      // Load only published activities created by this teacher
      // Try multiple query strategies for better compatibility
      QuerySnapshot snapshot;

      // Strategy 1: Try with both filters and orderBy
      try {
        snapshot = await FirebaseFirestore.instance
            .collection('activities')
            .where('createdBy', isEqualTo: teacherId)
            .where('published', isEqualTo: true)
            .orderBy('updatedAt', descending: true)
            .get();
        debugPrint('✅ Loaded with orderBy');
      } catch (e) {
        debugPrint('⚠️ OrderBy with two filters failed: $e');
        // Strategy 2: Try with one filter and orderBy
        try {
          snapshot = await FirebaseFirestore.instance
              .collection('activities')
              .where('createdBy', isEqualTo: teacherId)
              .orderBy('updatedAt', descending: true)
              .get();
          debugPrint('✅ Loaded with orderBy (single filter)');
        } catch (e2) {
          debugPrint('⚠️ OrderBy with single filter failed: $e2');
          // Strategy 3: Load without orderBy
          snapshot = await FirebaseFirestore.instance
              .collection('activities')
              .where('createdBy', isEqualTo: teacherId)
              .where('published', isEqualTo: true)
              .get();
          debugPrint('✅ Loaded without orderBy');
        }
      }

      // Store raw data for accessing gameConfig
      _activityRawData.clear();
      for (final doc in snapshot.docs) {
        final docData = doc.data() as Map<String, dynamic>?;
        if (docData != null && docData['published'] == true) {
          _activityRawData[doc.id] = docData;
        }
      }

      _allActivities = snapshot.docs
          .map((doc) {
            try {
              final docData = doc.data() as Map<String, dynamic>?;
              if (docData == null) {
                debugPrint('❌ Activity ${doc.id} has null data');
                return null;
              }
              // Client-side filter for published
              if (docData['published'] != true) {
                return null;
              }
              return Activity.fromJson({
                'id': doc.id,
                ...docData,
              });
            } catch (e) {
              debugPrint('❌ Error parsing activity ${doc.id}: $e');
              return null;
            }
          })
          .whereType<Activity>()
          .where((activity) =>
              activity.published == true) // Double-check published
          .toList();

      // Sort manually if orderBy failed
      _allActivities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      debugPrint(
          '📊 Loaded ${_allActivities.length} published activities out of ${snapshot.docs.length} total');

      _applyFilters();
    } catch (e) {
      debugPrint('Error loading activities: $e');
      setState(() {
        _error = 'Failed to load activities: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase();
    setState(() {
      _filteredActivities = _allActivities.where((activity) {
        // Only show published activities
        if (!activity.published) {
          return false;
        }

        // Search filter
        if (query.isNotEmpty &&
            !activity.title.toLowerCase().contains(query) &&
            !activity.description.toLowerCase().contains(query) &&
            !activity.learningObjectives
                .any((obj) => obj.toLowerCase().contains(query)) &&
            !activity.skills
                .any((skill) => skill.toLowerCase().contains(query))) {
          return false;
        }

        // Age group filter
        if (_selectedAgeGroup != null &&
            activity.ageGroup != _selectedAgeGroup) {
          return false;
        }

        return true;
      }).toList();

      debugPrint('📊 Filtered to ${_filteredActivities.length} activities');
    });
  }

  Future<void> _deleteActivity(Activity activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text(
          'Are you sure you want to delete "${activity.title}"? This action cannot be undone.',
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

    try {
      await _activityService.deleteActivity(
        activityId: activity.id,
        actorRole: UserType.teacher,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity deleted successfully'),
            backgroundColor: SafePlayColors.success,
          ),
        );
        _loadActivities(); // Reload activities
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
    }
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

  Color _getActivityBackgroundColor(ActivitySubject subject) {
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

  IconData _getSubjectIcon(ActivitySubject subject) {
    switch (subject) {
      case ActivitySubject.math:
        return Icons.calculate;
      case ActivitySubject.science:
        return Icons.science;
      case ActivitySubject.reading:
      case ActivitySubject.writing:
        return Icons.book;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Published Activities'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search activities...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                // Age group filter chips (only Junior/Bright, no subject filters)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedAgeGroup == null),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Junior (6-8)', _selectedAgeGroup == AgeGroup.junior),
                      const SizedBox(width: 8),
                      _buildFilterChip('Bright (9-12)',
                          _selectedAgeGroup == AgeGroup.bright),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_filteredActivities.length} activity(ies)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Activities list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadActivities,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredActivities.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_outlined,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No activities found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _searchQuery.isNotEmpty ||
                                            _selectedAgeGroup != null
                                        ? 'Try adjusting your search or filters'
                                        : 'No published activities yet. Publish an activity to see it here!',
                                    style: TextStyle(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadActivities,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredActivities.length,
                              itemBuilder: (context, index) {
                                final activity = _filteredActivities[index];
                                return _buildActivityCard(activity);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    AgeGroup? ageGroup;
    if (label == 'Junior (6-8)') {
      ageGroup = AgeGroup.junior;
    } else if (label == 'Bright (9-12)') {
      ageGroup = AgeGroup.bright;
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedAgeGroup = selected ? ageGroup : null;
          _applyFilters();
        });
      },
      selectedColor: SafePlayColors.brandTeal500.withOpacity(0.2),
      checkmarkColor: SafePlayColors.brandTeal500,
      labelStyle: TextStyle(
        color: isSelected ? SafePlayColors.brandTeal500 : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? SafePlayColors.brandTeal500 : Colors.grey[300]!,
        width: 1,
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final subjectColor = _getSubjectColor(activity.subject);
    final isExpanded = _expandedActivities.contains(activity.id);
    final backgroundColor = _getActivityBackgroundColor(activity.subject);
    final textColor = Colors.black87;

    return Column(
      children: [
        // Main card - same design as Browse Templates
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedActivities.remove(activity.id);
              } else {
                _expandedActivities.add(activity.id);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: isExpanded
                  ? Border.all(
                      color: SafePlayColors.brandTeal500,
                      width: 3,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
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
                        activity.title,
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
                        activity.description,
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
                          // Subject tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: subjectColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getSubjectIcon(activity.subject),
                                    size: 12, color: subjectColor),
                                const SizedBox(width: 4),
                                Text(
                                  activity.subject == ActivitySubject.reading
                                      ? 'English'
                                      : activity.subject.displayName,
                                  style: TextStyle(
                                    color: subjectColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Age group tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (activity.ageGroup == AgeGroup.junior
                                      ? Colors.orange
                                      : Colors.purple)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              activity.ageGroup == AgeGroup.junior
                                  ? 'Junior'
                                  : 'Bright',
                              style: TextStyle(
                                color: activity.ageGroup == AgeGroup.junior
                                    ? Colors.orange
                                    : Colors.purple,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.monetization_on,
                              size: 16, color: textColor.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.points} points',
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
                  ),
                ),
                // Icon - bottom right
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: _buildActivityIcon(activity.subject),
                ),
                // Expand indicator - top right
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: activity.published
                          ? SafePlayColors.success.withOpacity(0.9)
                          : Colors.orange.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          activity.published
                              ? Icons.check_circle
                              : Icons.edit_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.published ? 'Published' : 'Draft',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expanded details (if expanded) - below the card
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SafePlayColors.brandTeal500.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivityDetails(activity),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _deleteActivity(activity),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityIcon(ActivitySubject subject) {
    final color = _getSubjectColor(subject);
    IconData icon;
    switch (subject) {
      case ActivitySubject.math:
        icon = Icons.calculate;
        break;
      case ActivitySubject.science:
        icon = Icons.science;
        break;
      case ActivitySubject.reading:
      case ActivitySubject.writing:
        icon = Icons.book;
        break;
      default:
        icon = Icons.category;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 50,
        color: color,
      ),
    );
  }

  Widget _buildActivityDetails(Activity activity) {
    // Get question breakdown
    final breakdown = _getQuestionBreakdown(activity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Activity summary info
        Row(
          children: [
            Expanded(
              child: _buildDetailRow(
                Icons.quiz,
                'Total Questions',
                '${activity.questions.length}',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailRow(
                Icons.quiz,
                'Questions Breakdown',
                breakdown,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDetailRow(
                Icons.stars,
                'Total Points',
                '${activity.points}',
                Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailRow(
                Icons.timer,
                'Duration',
                '${activity.durationMinutes} min',
                Colors.green,
              ),
            ),
          ],
        ),

        // Learning objectives
        if (activity.learningObjectives.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.flag, color: SafePlayColors.brandTeal500, size: 20),
              const SizedBox(width: 8),
              Text(
                'Learning Objectives',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activity.learningObjectives.map((objective) {
            return Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 8),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      objective,
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

        // Questions list
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.list, color: SafePlayColors.brandTeal500, size: 20),
            const SizedBox(width: 8),
            Text(
              'Questions (${activity.questions.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...activity.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return _buildQuestionCard(question, index + 1);
        }),
      ],
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
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
                  style: TextStyle(
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
      ),
    );
  }

  Widget _buildQuestionCard(ActivityQuestion question, int questionNumber) {
    // Determine if this is a break activity question
    final isBreakQuestion = _isBreakQuestion(question);
    final questionColor =
        isBreakQuestion ? Colors.purple : SafePlayColors.brandTeal500;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isBreakQuestion ? Colors.purple.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: questionColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: questionColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isBreakQuestion)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.pink],
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: questionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getQuestionTypeIcon(question.type),
                      size: 14,
                      color: questionColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getQuestionTypeLabel(question.type),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: questionColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
          if (question.hint != null && question.hint!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hint: ${question.hint}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.stars, size: 14, color: Colors.amber[700]),
              const SizedBox(width: 4),
              Text(
                '${question.points} points',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (question.media.imageUrl != null ||
                  question.media.audioUrl != null ||
                  question.media.videoUrl != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.attach_file, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Has Media',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getQuestionBreakdown(Activity activity) {
    // Try to get template IDs from raw data
    int breakCount = 0;
    int curriculumCount = 0;

    // Check if we have raw data with gameConfig
    final rawData = _activityRawData[activity.id];
    if (rawData != null && rawData.containsKey('gameConfig')) {
      final gameConfigData = rawData['gameConfig'] as Map<String, dynamic>?;
      if (gameConfigData != null &&
          gameConfigData.containsKey('questionTemplateIds')) {
        final templateIds =
            List<String>.from(gameConfigData['questionTemplateIds'] ?? []);
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
    }

    // If we couldn't determine from template IDs, check questions directly
    if (breakCount == 0 && curriculumCount == 0) {
      for (final question in activity.questions) {
        if (_isBreakQuestion(question)) {
          breakCount++;
        } else {
          curriculumCount++;
        }
      }
    }

    // Final fallback
    if (breakCount == 0 && curriculumCount == 0) {
      curriculumCount = activity.questions.length;
    }

    return '$curriculumCount curriculum\n'
        '$breakCount break games';
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

  IconData _getQuestionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Icons.radio_button_checked;
      case QuestionType.textInput:
        return Icons.text_fields;
      case QuestionType.dragDrop:
        return Icons.drag_handle;
      case QuestionType.matching:
        return Icons.link;
      case QuestionType.sequencing:
        return Icons.sort;
      case QuestionType.trueFalse:
        return Icons.check_circle_outline;
    }
  }

  String _getQuestionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.textInput:
        return 'Text Input';
      case QuestionType.dragDrop:
        return 'Drag & Drop';
      case QuestionType.matching:
        return 'Matching';
      case QuestionType.sequencing:
        return 'Sequencing';
      case QuestionType.trueFalse:
        return 'True/False';
    }
  }
}
