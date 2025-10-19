import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../providers/child_provider.dart';

/// Modern hamburger-style settings menu for parent dashboard
class ParentSettingsMenu extends StatefulWidget {
  const ParentSettingsMenu({super.key});

  @override
  State<ParentSettingsMenu> createState() => _ParentSettingsMenuState();
}

class _ParentSettingsMenuState extends State<ParentSettingsMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSettingsMenu() {
    _animationController.forward();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildSettingsSheet(),
    ).then((_) {
      _animationController.reverse();
    });
  }

  Widget _buildSettingsSheet() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: SafePlayColors.neutral300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: SafePlayColors.brandTeal500.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: SafePlayColors.brandTeal500,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: SafePlayColors.neutral900,
                                ),
                              ),
                              Text(
                                'Manage your account and preferences',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: SafePlayColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: SafePlayColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your account password',
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push(RouteNames.parentChangePassword);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          onTap: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Notifications settings coming soon'),
                                backgroundColor: SafePlayColors.info,
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy & Security',
                          subtitle: 'Manage your privacy settings',
                          onTap: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Privacy settings coming soon'),
                                backgroundColor: SafePlayColors.info,
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get help and contact support',
                          onTap: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Help & support coming soon'),
                                backgroundColor: SafePlayColors.info,
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          subtitle: 'App version and information',
                          onTap: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('About section coming soon'),
                                backgroundColor: SafePlayColors.info,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Demo section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SafePlayColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: SafePlayColors.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.science_outlined,
                                    color: SafePlayColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Demo Features',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: SafePlayColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildMenuItem(
                                icon: Icons.warning_amber_rounded,
                                title: 'Send Incident Alert',
                                subtitle: 'Demo incident notification',
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  final notificationService =
                                      context.read<NotificationService>();
                                  final childProvider =
                                      context.read<ChildProvider>();
                                  final child = childProvider.selectedChild;
                                  await notificationService.showIncidentAlert(
                                    incidentId:
                                        'incident-${DateTime.now().millisecondsSinceEpoch}',
                                    childName: child?.name ?? 'Learner',
                                    summary:
                                        'Requested a break after a challenging activity.',
                                  );
                                },
                                isDemo: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Danger Zone
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Danger Zone',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildMenuItem(
                                icon: Icons.delete_forever_outlined,
                                title: 'Delete Account',
                                subtitle:
                                    'Permanently delete your account and all data',
                                onTap: () {
                                  Navigator.of(context).pop();
                                  context.push(RouteNames.parentDeleteAccount);
                                },
                                isDanger: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Logout button
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 24),
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              final authProvider = context.read<AuthProvider>();
                              await authProvider.signOut();
                              if (context.mounted) {
                                context.go(RouteNames.login);
                              }
                            },
                            icon: const Icon(Icons.logout, size: 20),
                            label: const Text('Sign Out'),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDemo = false,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDanger
                    ? Colors.red.withOpacity(0.3)
                    : isDemo
                        ? SafePlayColors.warning.withOpacity(0.2)
                        : SafePlayColors.neutral200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDanger
                        ? Colors.red.withOpacity(0.1)
                        : isDemo
                            ? SafePlayColors.warning.withOpacity(0.1)
                            : SafePlayColors.brandTeal500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDanger
                        ? Colors.red
                        : isDemo
                            ? SafePlayColors.warning
                            : SafePlayColors.brandTeal500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDanger
                              ? Colors.red
                              : isDemo
                                  ? SafePlayColors.warning
                                  : SafePlayColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDanger
                              ? Colors.red.withOpacity(0.8)
                              : isDemo
                                  ? SafePlayColors.warning.withOpacity(0.8)
                                  : SafePlayColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDanger
                      ? Colors.red.withOpacity(0.6)
                      : isDemo
                          ? SafePlayColors.warning.withOpacity(0.6)
                          : SafePlayColors.neutral400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showSettingsMenu,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: SafePlayColors.neutral100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.menu,
          color: SafePlayColors.neutral700,
          size: 20,
        ),
      ),
    );
  }
}
