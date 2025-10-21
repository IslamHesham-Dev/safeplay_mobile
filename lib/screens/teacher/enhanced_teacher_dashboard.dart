import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/teacher_service.dart';
import '../../services/simple_template_service.dart';
import '../../models/teacher_profile.dart' as teacher;
import '../../models/activity.dart';
import '../../models/question_template.dart';
import '../../models/user_type.dart';
import '../../design_system/colors.dart';

class EnhancedTeacherDashboard extends StatefulWidget {
  const EnhancedTeacherDashboard({super.key});

  @override
  State<EnhancedTeacherDashboard> createState() =>
      _EnhancedTeacherDashboardState();
}

class _EnhancedTeacherDashboardState extends State<EnhancedTeacherDashboard>
    with TickerProviderStateMixin {
  late final TeacherService _teacherService;
  late final SimpleTemplateService _simpleTemplateService;
  late final TabController _tabController;

  teacher.TeacherProfile? _teacherProfile;
  List<QuestionTemplate> _templates = [];
  List<QuestionTemplate> _filteredTemplates = [];
  List<Activity> _activities = [];
  TeacherPublishingStats? _stats;
  bool _loading = false;
  String? _error;
  String? _templateError;
  String _currentFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _teacherService = TeacherService();
    _simpleTemplateService = SimpleTemplateService();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _templateError = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final teacherId = auth.currentUser?.id;

      if (teacherId == null) {
        if (mounted) {
          setState(() => _error = 'No teacher ID found');
        }
        return;
      }

      debugPrint('Loading dashboard data for teacher: $teacherId');

      // Load all templates first (this is the most important part)
      debugPrint('Loading all templates...');
      try {
        final templates = await _simpleTemplateService
            .getAllTemplates()
            .timeout(const Duration(seconds: 10));
        _templates = templates;
        _filteredTemplates = List.from(_templates); // Initialize filtered list
        _templateError = null;
        debugPrint('Loaded ${_templates.length} templates');
      } on TimeoutException catch (error) {
        debugPrint('Template load timed out: $error');
        _templates = [];
        _templateError =
            'Template loading timed out. Please check your connection and try again.';
      } on FirebaseException catch (error) {
        debugPrint(
            'Firestore error loading templates: ${error.message ?? error.code}');
        _templates = [];
        _templateError = error.message ??
            'We could not load templates due to a Firestore permission or index issue.';
      } catch (error) {
        debugPrint('Unexpected error loading templates: $error');
        _templates = [];
        _templateError =
            'Something went wrong while loading templates. Please try again.';
      }

      // Load teacher profile (optional - don't block on this)
      try {
        _teacherProfile = await _teacherService.getTeacherProfile(teacherId);
        debugPrint(
            '👨‍🏫 Teacher profile loaded: ${_teacherProfile?.name ?? 'Unknown'}');
      } catch (e) {
        debugPrint('⚠️ Could not load teacher profile: $e');
        // Continue without profile
      }

      // Load teacher's activities (optional - don't block on this)
      try {
        debugPrint('📝 Loading teacher activities...');
        _activities =
            await _teacherService.getTeacherActivities(teacherId: teacherId);
        debugPrint('📝 Loaded ${_activities.length} activities');
      } catch (e) {
        debugPrint('⚠️ Could not load teacher activities: $e');
        _activities = []; // Set empty list if failed
      }

      // Load publishing stats (optional - don't block on this)
      try {
        debugPrint('📊 Loading publishing stats...');
        _stats = await _teacherService.getPublishingStats(teacherId);
        debugPrint(
            '📊 Stats loaded: ${_stats?.totalActivities ?? 0} total activities');
      } catch (e) {
        debugPrint('⚠️ Could not load publishing stats: $e');
        // Continue without stats
      }

      debugPrint('✅ Dashboard data loading complete!');
    } catch (e) {
      debugPrint('❌ Error loading dashboard data: $e');
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
        appBar: AppBar(title: const Text('Teacher Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${_teacherProfile?.name ?? 'Teacher'}'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview Cards
          _buildStatsOverview(),

          // Tab Bar
          Container(
            color: SafePlayColors.brandTeal500,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
                Tab(text: 'Create Activity', icon: Icon(Icons.add_circle)),
                Tab(text: 'My Activities', icon: Icon(Icons.list)),
                Tab(text: 'Templates', icon: Icon(Icons.library_books)),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildCreateActivityTab(),
                _buildMyActivitiesTab(),
                _buildTemplatesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (_stats == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: SafePlayColors.brandTeal500.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Activities',
              _stats!.totalActivities.toString(),
              Icons.assignment,
              SafePlayColors.brandTeal500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Published',
              _stats!.publishedActivities.toString(),
              Icons.publish,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Drafts',
              _stats!.draftActivities.toString(),
              Icons.edit,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Publish Rate',
              '${(_stats!.publishRate * 100).toStringAsFixed(0)}%',
              Icons.trending_up,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Create New Activity',
                  'Build activities from templates',
                  Icons.add_circle_outline,
                  () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Browse Templates',
                  'Explore question templates',
                  Icons.library_books,
                  () => _tabController.animateTo(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'View Analytics',
                  'Check child progress and performance',
                  Icons.analytics,
                  () => _tabController
                      .animateTo(3), // Navigate to templates tab for now
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Refresh Data',
                  'Reload dashboard information',
                  Icons.refresh,
                  _loadDashboardData,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activities
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_activities.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No activities created yet'),
                ),
              ),
            )
          else
            ..._activities
                .take(3)
                .map((activity) => _buildActivityCard(activity)),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {Color? color}) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color ?? SafePlayColors.brandTeal500),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSubjectColor(activity.subject),
          child: Text(
            activity.subject.displayName[0],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(activity.title),
        subtitle: Text(
            '${activity.ageGroup.name.toUpperCase()} • ${activity.subject.displayName}'),
        trailing: _buildPublishStateChip(activity.publishState),
        onTap: () {
          // Navigate to activity details
        },
      ),
    );
  }

  Widget _buildPublishStateChip(PublishState state) {
    Color color;
    String text;

    switch (state) {
      case PublishState.published:
        color = Colors.green;
        text = 'Published';
        break;
      case PublishState.draft:
        color = Colors.orange;
        text = 'Draft';
        break;
      case PublishState.pendingReview:
        color = Colors.blue;
        text = 'Review';
        break;
      case PublishState.archived:
        color = Colors.grey;
        text = 'Archived';
        break;
    }

    return Chip(
      label:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCreateActivityTab() {
    return const Center(
      child: Text('Create Activity Tab - To be implemented'),
    );
  }

  Widget _buildMyActivitiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildTemplatesTab() {
    if (_templateError != null) {
      return _buildTemplatesPlaceholder(
        icon: Icons.error_outline,
        title: 'Unable to load templates',
        description: _templateError!,
        action: ElevatedButton(
          onPressed: _loadDashboardData,
          child: const Text('Retry'),
        ),
      );
    }

    if (_templates.isEmpty) {
      return _buildTemplatesPlaceholder(
        icon: Icons.library_books_outlined,
        title: 'No curriculum templates available',
        description:
            'We could not find any active templates right now. Please try again in a moment.',
        action: TextButton(
          onPressed: _loadDashboardData,
          child: const Text('Reload'),
        ),
      );
    }

    return Column(
      children: [
        // Search and Filter Bar
        _buildTemplatesHeader(),

        // Templates Grid/List
        Expanded(
          child: _buildTemplatesContent(),
        ),
      ],
    );
  }

  Widget _buildTemplatesPlaceholder({
    required IconData icon,
    required String title,
    required String description,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action,
          ],
        ],
      ),
    );
  }

  void _applyFilters() {
    _filteredTemplates = _templates.where((template) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!template.title.toLowerCase().contains(query) &&
            !template.prompt.toLowerCase().contains(query) &&
            !template.skills
                .any((skill) => skill.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Apply category filter
      switch (_currentFilter) {
        case 'All':
          return true;
        case 'Math':
          return template.subjects.contains(ActivitySubject.math);
        case 'English':
          return template.subjects.contains(ActivitySubject.reading) ||
              template.subjects.contains(ActivitySubject.writing);
        case 'Mindful':
          return template.skills.any((skill) =>
              skill.toLowerCase().contains('mindful') ||
              skill.toLowerCase().contains('relaxation') ||
              skill.toLowerCase().contains('breathing') ||
              skill.toLowerCase().contains('meditation') ||
              skill.toLowerCase().contains('reflection') ||
              skill.toLowerCase().contains('wellness'));
        case 'Junior (6-8)':
          return template.ageGroups.contains(AgeGroup.junior);
        case 'Bright (9-12)':
          return template.ageGroups.contains(AgeGroup.bright);
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildTemplatesHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search templates...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          const SizedBox(height: 12),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', _currentFilter == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Math', _currentFilter == 'Math'),
                const SizedBox(width: 8),
                _buildFilterChip('English', _currentFilter == 'English'),
                const SizedBox(width: 8),
                _buildFilterChip('Mindful', _currentFilter == 'Mindful'),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Junior (6-8)', _currentFilter == 'Junior (6-8)'),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Bright (9-12)', _currentFilter == 'Bright (9-12)'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredTemplates.length} templates available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.grid_view, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Icon(Icons.list,
                      size: 20, color: SafePlayColors.brandTeal500),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = label;
          _applyFilters();
        });
      },
      backgroundColor: Colors.grey[100],
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

  Widget _buildTemplatesContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = _filteredTemplates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(QuestionTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTemplateDetails(template),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type and points
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getQuestionTypeColor(template.type)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getQuestionTypeIcon(template.type),
                            size: 16,
                            color: _getQuestionTypeColor(template.type),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getQuestionTypeDisplayName(template.type),
                            style: TextStyle(
                              color: _getQuestionTypeColor(template.type),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${template.defaultPoints} pts',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  template.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  template.prompt,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Skills tags
                if (template.skills.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: template.skills
                        .take(3)
                        .map((skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: SafePlayColors.brandTeal500
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  color: SafePlayColors.brandTeal500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  if (template.skills.length > 3) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+${template.skills.length - 3} more',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 16),

                // Footer with action button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addTemplateToActivity(template),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add to Activity'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SafePlayColors.brandTeal500,
                          side: BorderSide(color: SafePlayColors.brandTeal500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _showTemplateDetails(template),
                      icon: Icon(Icons.info_outline, color: Colors.grey[600]),
                      tooltip: 'View Details',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTemplateDetails(QuestionTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTemplateDetailsSheet(template),
    );
  }

  Widget _buildTemplateDetailsSheet(QuestionTemplate template) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getQuestionTypeColor(template.type)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getQuestionTypeIcon(template.type),
                          color: _getQuestionTypeColor(template.type),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getQuestionTypeDisplayName(template.type),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Question prompt
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question Prompt',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          template.prompt,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Skills
                  if (template.skills.isNotEmpty) ...[
                    Text(
                      'Skills Covered',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: template.skills
                          .map((skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: SafePlayColors.brandTeal500
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  skill,
                                  style: TextStyle(
                                    color: SafePlayColors.brandTeal500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _addTemplateToActivity(template);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add to Activity'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SafePlayColors.brandTeal500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTemplateToActivity(QuestionTemplate template) {
    // TODO: Implement adding template to activity creation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${template.title}" to activity'),
        backgroundColor: SafePlayColors.brandTeal500,
      ),
    );
  }

  String _getQuestionTypeDisplayName(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.textInput:
        return 'Text Input';
      case QuestionType.dragDrop:
        return 'Drag & Drop';
      case QuestionType.matching:
        return 'Matching';
      case QuestionType.sequencing:
        return 'Sequencing';
    }
  }

  IconData _getQuestionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Icons.quiz;
      case QuestionType.trueFalse:
        return Icons.check_circle;
      case QuestionType.textInput:
        return Icons.edit;
      case QuestionType.dragDrop:
        return Icons.drag_handle;
      case QuestionType.matching:
        return Icons.link;
      case QuestionType.sequencing:
        return Icons.sort;
    }
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Colors.blue;
      case QuestionType.trueFalse:
        return Colors.green;
      case QuestionType.textInput:
        return Colors.purple;
      case QuestionType.dragDrop:
        return Colors.orange;
      case QuestionType.matching:
        return Colors.teal;
      case QuestionType.sequencing:
        return Colors.pink;
    }
  }

  Color _getSubjectColor(ActivitySubject subject) {
    switch (subject) {
      case ActivitySubject.math:
        return Colors.blue;
      case ActivitySubject.reading:
        return Colors.green;
      case ActivitySubject.writing:
        return Colors.purple;
      case ActivitySubject.science:
        return Colors.orange;
      case ActivitySubject.social:
        return Colors.brown;
      case ActivitySubject.art:
        return Colors.pink;
      case ActivitySubject.music:
        return Colors.indigo;
      case ActivitySubject.coding:
        return Colors.teal;
    }
  }
}
