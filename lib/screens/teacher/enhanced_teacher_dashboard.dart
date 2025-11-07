import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/teacher_service.dart';
import '../../services/simple_template_service.dart';
import '../../services/break_activities_service.dart';
import '../../models/teacher_profile.dart' as teacher;
import '../../models/activity.dart';
import '../../models/question_template.dart';
import '../../models/user_type.dart';
import '../../design_system/colors.dart';
import 'activity_builder_screen.dart';
import 'activity_creation_wizard_screen.dart';
import 'teacher_activities_management_screen.dart';

class EnhancedTeacherDashboard extends StatefulWidget {
  const EnhancedTeacherDashboard({super.key});

  @override
  State<EnhancedTeacherDashboard> createState() =>
      _EnhancedTeacherDashboardState();
}

class _EnhancedTeacherDashboardState extends State<EnhancedTeacherDashboard> {
  late final TeacherService _teacherService;
  late final SimpleTemplateService _simpleTemplateService;
  late final BreakActivitiesService _breakActivitiesService;

  int _currentIndex = 0;

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
    _breakActivitiesService = BreakActivitiesService();
    _loadDashboardData();
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

      // Load all templates (curriculum questions + break activities)
      debugPrint('Loading all templates...');
      try {
        final allTemplates = <QuestionTemplate>[];

        // Load curriculum questions
        final curriculumTemplates = await _simpleTemplateService
            .getAllTemplates()
            .timeout(const Duration(seconds: 10));
        allTemplates.addAll(curriculumTemplates);

        // Load break activities for both age groups
        final juniorBreakActivities =
            await _breakActivitiesService.getBreakActivities(
          ageGroup: AgeGroup.junior,
          activeOnly: true,
        );
        allTemplates.addAll(juniorBreakActivities);

        final brightBreakActivities =
            await _breakActivitiesService.getBreakActivities(
          ageGroup: AgeGroup.bright,
          activeOnly: true,
        );
        allTemplates.addAll(brightBreakActivities);

        _templates = allTemplates;
        _filteredTemplates = List.from(_templates); // Initialize filtered list
        _templateError = null;
        debugPrint(
            'Loaded ${_templates.length} templates (${curriculumTemplates.length} curriculum + ${juniorBreakActivities.length + brightBreakActivities.length} break activities)');
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

      // Load teacher's published activities (optional - don't block on this)
      try {
        debugPrint('📝 Loading teacher published activities...');
        _activities =
            await _teacherService.getTeacherActivities(teacherId: teacherId);
        // Filter to only published activities
        _activities = _activities.where((a) => a.published == true).toList();
        debugPrint('📝 Loaded ${_activities.length} published activities');
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
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom Header with Teacher Info - extends to top
          _buildCustomHeader(),

          // Stats Overview Cards (only on Dashboard)
          if (_currentIndex == 0) _buildStatsOverview(),

          // Main Content with SafeArea
          Expanded(
            child: SafeArea(
              top: false,
              child: _buildCurrentPage(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getTeacherDisplayName() {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;

    // Try to get name from teacher profile first
    if (_teacherProfile?.name != null && _teacherProfile!.name.isNotEmpty) {
      return _teacherProfile!.name;
    }

    // Fallback to current user name
    if (currentUser?.name != null && currentUser!.name.isNotEmpty) {
      return currentUser.name;
    }

    // Final fallback
    return 'Teacher';
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildCreateActivityTab();
      case 2:
        return _buildMyActivitiesTab();
      case 3:
        return _buildTemplatesTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: SafePlayColors.brandTeal500,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            activeIcon: Icon(Icons.list),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Templates',
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SafePlayColors.brandTeal500,
            SafePlayColors.brandTeal500.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: SafePlayColors.brandTeal500.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Teacher info
              Expanded(
                child: Row(
                  children: [
                    // Teacher Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _teacherProfile?.profileImageUrl != null
                          ? NetworkImage(_teacherProfile!.profileImageUrl!)
                          : null,
                      child: _teacherProfile?.profileImageUrl == null
                          ? Text(
                              _getTeacherDisplayName()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getTeacherDisplayName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => context.read<AuthProvider>().signOut(),
                  tooltip: 'Sign Out',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (_stats == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
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
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SafePlayColors.brandTeal500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: SafePlayColors.brandTeal500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Teaching Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  _stats!.totalActivities.toString(),
                  Icons.assignment_outlined,
                  SafePlayColors.brandTeal500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Published',
                  _stats!.publishedActivities.toString(),
                  Icons.publish_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Drafts',
                  _stats!.draftActivities.toString(),
                  Icons.edit_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions Section
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on,
                        color: SafePlayColors.brandTeal500,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Create New Activity',
                          'Build activities from templates',
                          Icons.add_circle_outline,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ActivityCreationWizardScreen(),
                              ),
                            ).then((_) {
                              // Refresh data when returning
                              _loadDashboardData();
                            });
                          },
                          gradient: LinearGradient(
                            colors: [
                              SafePlayColors.brandTeal500,
                              SafePlayColors.brandTeal500.withOpacity(0.8)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          'Browse Templates',
                          'Explore question templates',
                          Icons.library_books_outlined,
                          () => setState(() => _currentIndex = 3),
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple,
                              Colors.purple.withOpacity(0.8)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Activities Section
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: SafePlayColors.brandTeal500,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_activities.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No activities created yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by creating your first activity!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._activities
                        .take(3)
                        .map((activity) => _buildActivityCard(activity)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {Color? color, Gradient? gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: [
                color ?? SafePlayColors.brandTeal500,
                (color ?? SafePlayColors.brandTeal500).withOpacity(0.8)
              ],
            ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (color ?? SafePlayColors.brandTeal500).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getSubjectColor(activity.subject).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to activity details
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getSubjectColor(activity.subject).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _getSubjectColor(activity.subject).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getSubjectIcon(activity.subject),
                    color: _getSubjectColor(activity.subject),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getSubjectColor(activity.subject)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              activity.ageGroup.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getSubjectColor(activity.subject),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activity.subject.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildPublishStateChip(activity.publishState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPublishStateChip(PublishState state) {
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case PublishState.published:
        color = Colors.green;
        text = 'Published';
        icon = Icons.check_circle;
        break;
      case PublishState.draft:
        color = Colors.orange;
        text = 'Draft';
        icon = Icons.edit;
        break;
      case PublishState.pendingReview:
        color = Colors.blue;
        text = 'Review';
        icon = Icons.schedule;
        break;
      case PublishState.archived:
        color = Colors.grey;
        text = 'Archived';
        icon = Icons.archive;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateActivityTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SafePlayColors.brandTeal500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.add_circle_outline,
                size: 64,
                color: SafePlayColors.brandTeal500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create New Activity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build engaging activities from templates!\nSelect questions, choose game type, and publish for children.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityCreationWizardScreen(),
                  ),
                ).then((_) {
                  // Refresh data when returning
                  _loadDashboardData();
                });
              },
              icon: const Icon(Icons.add_circle, size: 24),
              label: const Text(
                'Start Activity Creation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: SafePlayColors.brandTeal500,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyActivitiesTab() {
    return TeacherActivitiesManagementView(
      embedded: true,
      onCreateActivity: () => setState(() => _currentIndex = 1),
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

        // Templates Grid/List with RefreshIndicator
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: _buildTemplatesContent(),
          ),
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
        case 'Science':
          return template.subjects.contains(ActivitySubject.science);
        case 'Break Activities':
          // Check if template is a break activity
          final json = template.toJson();
          return json['isBreakActivity'] == true ||
              template.subjects.isEmpty ||
              (template.subjects.length == 1 &&
                  template.subjects.first.displayName
                      .toLowerCase()
                      .contains('wellbeing'));
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
                _buildFilterChip('Science', _currentFilter == 'Science'),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Break Activities', _currentFilter == 'Break Activities'),
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = _filteredTemplates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(QuestionTemplate template) {
    // Get background color based on subject (similar to junior cards)
    final backgroundColor = _getTemplateBackgroundColor(template);
    final textColor = _getTemplateTextColor(template);

    return GestureDetector(
      onTap: () => _showTemplateDetails(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 180, // Fixed height like junior cards
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              BorderRadius.circular(24), // Large border radius like junior
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
            // Content positioned like junior cards
            Positioned(
              left: 20,
              top: 20,
              right: 120, // Space for icon
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (large, bold)
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
                  // Description/prompt (smaller, muted)
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
                  // Tags row (subject, age group - compact for card)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Subject tags (compact for card)
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
                              Icon(
                                _getSubjectIcon(subject),
                                size: 12,
                                color: color,
                              ),
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

                      // Age group (compact)
                      if (template.ageGroups.isNotEmpty)
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
                    ],
                  ),

                  // Points indicator
                  if (template.defaultPoints > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: textColor.withOpacity(0.6),
                        ),
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
            // Icon/Illustration in bottom-right (like junior cards)
            Positioned(
              right: -10,
              bottom: -10,
              child: _buildTemplateIcon(template, backgroundColor, textColor),
            ),
            // Add to Activity button (top-right corner)
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _addTemplateToActivity(template),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle,
                          size: 18,
                          color: SafePlayColors.brandTeal500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: SafePlayColors.brandTeal500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get background color for template card (pastel based on subject)
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

  /// Get text color for template card (dark for readability)
  Color _getTemplateTextColor(QuestionTemplate template) {
    return Colors.black87; // Dark text for good contrast
  }

  /// Build template icon (similar to junior cards)
  Widget _buildTemplateIcon(
      QuestionTemplate template, Color bgColor, Color textColor) {
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
      child: Icon(
        icon,
        size: 50,
        color: iconColor,
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
    // Navigate to Activity Builder with template pre-selected
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityBuilderScreen(
          preSelectedTemplates: [template],
        ),
      ),
    ).then((_) {
      // Refresh data when returning
      _loadDashboardData();
    });
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

  IconData _getSubjectIcon(ActivitySubject subject) {
    switch (subject) {
      case ActivitySubject.math:
        return Icons.calculate;
      case ActivitySubject.reading:
        return Icons.menu_book;
      case ActivitySubject.writing:
        return Icons.edit;
      case ActivitySubject.science:
        return Icons.science;
      case ActivitySubject.social:
        return Icons.people;
      case ActivitySubject.art:
        return Icons.palette;
      case ActivitySubject.music:
        return Icons.music_note;
      case ActivitySubject.coding:
        return Icons.code;
    }
  }
}
