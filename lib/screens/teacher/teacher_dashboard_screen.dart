import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../models/question_template.dart';
import '../../models/user_type.dart';
import '../../providers/auth_provider.dart';
import '../../services/activity_service.dart';
import 'enhanced_teacher_dashboard.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late final ActivityService _activityService;
  List<QuestionTemplate> _templates = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _loading = true);
    try {
      final templates = await _activityService.listTemplates();
      setState(() => _templates = templates);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _publishSample(Activity activity) async {
    final auth = context.read<AuthProvider>();
    await _activityService.upsertActivity(
      activity: activity,
      actorRole: auth.currentUser?.userType ?? UserType.teacher,
    );
    await _activityService.setPublishState(
      activityId: activity.id.isEmpty ? 'temp' : activity.id,
      newState: PublishState.published,
      actorRole: auth.currentUser?.userType ?? UserType.teacher,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity saved/published (if valid).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the enhanced dashboard instead
    return const EnhancedTeacherDashboard();
  }
}
