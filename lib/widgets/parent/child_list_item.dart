import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/colors.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../navigation/route_names.dart';
import '../avatar_widget.dart';

/// Widget for displaying a child in the parent dashboard list
class ChildListItem extends StatelessWidget {
  final ChildProfile child;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onSetupLogin;
  final VoidCallback? onDelete;

  const ChildListItem({
    super.key,
    required this.child,
    this.onTap,
    this.onEdit,
    this.onSetupLogin,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              AvatarWidget(
                name: child.name,
                size: 60,
                backgroundColor: _getAgeGroupColor().withValues(alpha: 0.1),
                textColor: _getAgeGroupColor(),
              ),
              const SizedBox(width: 16),

              // Child Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildAgeGroupBadge(),
                            if (onSetupLogin != null) _buildSetupLoginButton(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: 16,
                          color: SafePlayColors.neutral500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          child.age != null
                              ? 'Age ${child.age}'
                              : 'Age not set',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: SafePlayColors.neutral600,
                                  ),
                        ),
                        if (child.grade != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: SafePlayColors.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Grade ${child.grade}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: SafePlayColors.neutral600,
                                    ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.star,
                          'Level ${child.level}',
                          SafePlayColors.brandOrange500,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          Icons.local_fire_department,
                          '${child.streakDays} day streak',
                          SafePlayColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Edit Button
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    color: SafePlayColors.neutral500,
                    iconSize: 20,
                  ),
                  // Delete Button
                  if (onDelete != null)
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(context),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      iconSize: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeGroupBadge() {
    final isJunior = child.ageGroup == AgeGroup.junior;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isJunior
            ? SafePlayColors.brandTeal500.withValues(alpha: 0.1)
            : SafePlayColors.brandOrange500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isJunior
              ? SafePlayColors.brandTeal500
              : SafePlayColors.brandOrange500,
          width: 1,
        ),
      ),
      child: Text(
        isJunior ? 'Junior' : 'Bright',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isJunior
              ? SafePlayColors.brandTeal500
              : SafePlayColors.brandOrange500,
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupLoginButton() {
    // Check if authData exists and has the required fields
    final authData = child.authData;
    final hasAuthSetup = authData != null &&
        authData.isNotEmpty &&
        authData['authType'] != null &&
        authData['authType'].toString().isNotEmpty;

    print('[ChildListItem]: Building setup button for ${child.name}');
    print('[ChildListItem]: Child authData: $authData');
    print('[ChildListItem]: Has auth setup: $hasAuthSetup');

    if (hasAuthSetup) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: SafePlayColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SafePlayColors.success),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: SafePlayColors.success,
            ),
            const SizedBox(width: 4),
            Text(
              'Login Ready',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SafePlayColors.success,
              ),
            ),
          ],
        ),
      );
    } else {
      return InkWell(
        onTap: onSetupLogin,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getAgeGroupColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getAgeGroupColor()),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: _getAgeGroupColor(),
              ),
              const SizedBox(width: 4),
              Text(
                'Setup Login',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getAgeGroupColor(),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Child Profile'),
          content: Text(
            'Are you sure you want to delete ${child.name}\'s profile? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Color _getAgeGroupColor() {
    return child.ageGroup == AgeGroup.junior
        ? SafePlayColors.brandTeal500
        : SafePlayColors.brandOrange500;
  }
}

/// Widget for displaying children in a list with edit functionality
class ChildrenListWidget extends StatelessWidget {
  final List<ChildProfile> children;
  final Function(ChildProfile)? onChildTap;
  final Function(ChildProfile)? onChildEdit;
  final Function(ChildProfile)? onChildSetupLogin;
  final Function(ChildProfile)? onChildDelete;

  const ChildrenListWidget({
    super.key,
    required this.children,
    this.onChildTap,
    this.onChildEdit,
    this.onChildSetupLogin,
    this.onChildDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Children (${children.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () => context.push(RouteNames.parentAddChild),
              icon: const Icon(Icons.add),
              label: const Text('Add Child'),
              style: TextButton.styleFrom(
                foregroundColor: SafePlayColors.brandTeal500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Children List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final child = children[index];
            return ChildListItem(
              child: child,
              onTap: () => onChildTap?.call(child),
              onEdit: () => onChildEdit?.call(child),
              onSetupLogin: () => onChildSetupLogin?.call(child),
              onDelete: () => onChildDelete?.call(child),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 80,
            color: SafePlayColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'No children added yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SafePlayColors.neutral600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first child to start tracking their learning journey',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SafePlayColors.neutral500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(RouteNames.parentAddChild),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Child'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.brandTeal500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
