import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

/// Activity timeline widget showing recent activities
class ActivityTimelineWidget extends StatelessWidget {
  const ActivityTimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Load actual activity data
    final activities = [
      {
        'title': 'Letter Sound Adventure',
        'child': 'Emma',
        'score': 85,
        'time': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'title': 'Animal Sound Safari',
        'child': 'Liam',
        'score': 100,
        'time': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'title': 'Picture Story Builder',
        'child': 'Emma',
        'score': 90,
        'time': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 80,
              color: SafePlayColors.neutral500,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SafePlayColors.neutral500,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) => _buildActivityItem(context, activity)),
      ],
    );
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity) {
    final score = activity['score'] as int;
    final color = score >= 80
        ? SafePlayColors.success
        : score >= 60
            ? SafePlayColors.brandOrange500
            : SafePlayColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.school, color: color),
        ),
        title: Text(
          activity['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${activity['child']} • ${_formatTime(activity['time'] as DateTime)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
