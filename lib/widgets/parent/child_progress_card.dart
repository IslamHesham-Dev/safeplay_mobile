import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';

/// Child progress card for parent dashboard
class ChildProgressCard extends StatelessWidget {
  final ChildProfile child;

  const ChildProgressCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to child detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing ${child.name}\'s profile')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and name
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: child.ageGroup == AgeGroup.junior
                        ? SafePlayColors.juniorPurple
                        : SafePlayColors.brightIndigo,
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${child.age != null ? '${child.age} years old  ' : ''}Level ${child.level}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: SafePlayColors.neutral700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    context,
                    'XP',
                    '${child.xp}',
                    Icons.star,
                    SafePlayColors.brandOrange500,
                  ),
                  _buildStat(
                    context,
                    'Streak',
                    '${child.streakDays}',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  _buildStat(
                    context,
                    'Achievements',
                    '${child.achievements.length}',
                    Icons.emoji_events,
                    SafePlayColors.success,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Recent activity indicator
              if (child.lastLoginAt != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SafePlayColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: SafePlayColors.info,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last active: ${_formatLastActive(child.lastLoginAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SafePlayColors.info,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SafePlayColors.neutral700,
              ),
        ),
      ],
    );
  }

  String _formatLastActive(DateTime date) {
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
