import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../localization/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';

/// Add Child screen for parents to create new child profiles
class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  AgeGroup _selectedAgeGroup = AgeGroup.junior;
  String? _selectedGender; // 'male' or 'female'
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final loc = context.loc;
    if (!_formKey.currentState!.validate()) return;

    // Validate gender selection
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('child.form.gender_missing')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Date of birth is optional; age is required via form validator

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final childProvider = context.read<ChildProvider>();

      if (authProvider.currentUser == null) {
        throw Exception('No parent logged in');
      }

      // Get age from input
      final age = int.tryParse(_ageController.text.trim());
      final parentEmail = authProvider.currentUser!.email?.trim().toLowerCase();

      // Create child profile
      final childProfile = ChildProfile(
        id: '', // Will be set by Firestore
        name: _nameController.text.trim(),
        userType: _selectedAgeGroup == AgeGroup.junior
            ? UserType.juniorChild
            : UserType.brightChild,
        ageGroup: _selectedAgeGroup,
        createdAt: DateTime.now(),
        parentIds: [authProvider.currentUser!.id],
        age: age,
        stats: const ChildStats(),
        achievements: const [],
        favoriteSubjects: const [],
        learningModes: const [],
        updatedAt: DateTime.now(),
        gender: _selectedGender,
        parentEmail: parentEmail,
      );

      // Add child to Firestore
      final newChild = await childProvider.addChild(childProfile);

      if (newChild != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.t('child.add.success')),
              backgroundColor: SafePlayColors.success,
            ),
          );

          // Navigate to authentication setup based on age group
          if (newChild.ageGroup == AgeGroup.junior) {
            context.push(RouteNames.juniorAuthSetup, extra: newChild);
          } else {
            context.push(RouteNames.brightAuthSetup, extra: newChild);
          }
        }
      } else {
        throw Exception(
            childProvider.error ?? 'Failed to create child profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('child.add.title')),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Header
                Text(
                  loc.t('child.add.header'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.t('child.add.subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SafePlayColors.neutral600,
                      ),
                ),
                const SizedBox(height: 32),

                // Child Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: loc.t('child.form.name_label'),
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.t('child.form.name_error');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Age (Required)
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: loc.t('child.form.age_label'),
                    prefixIcon: const Icon(Icons.child_care_outlined),
                    border: const OutlineInputBorder(),
                    helperText: loc.t('child.form.age_helper'),
                  ),
                  onChanged: (value) {
                    final age = int.tryParse(value.trim());
                    if (age != null) {
                      setState(() {
                        if (age >= 6 && age <= 8) {
                          _selectedAgeGroup = AgeGroup.junior;
                        } else if (age >= 9 && age <= 12) {
                          _selectedAgeGroup = AgeGroup.bright;
                        }
                        // Trigger rebuild to update dimming/disabled state
                      });
                    } else {
                      setState(() {});
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.t('child.form.age_error');
                    }
                    final age = int.tryParse(value.trim());
                    if (age == null || age < 6 || age > 12) {
                      return loc.t('child.form.age_range_error');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Gender Selection
                Text(
                  loc.t('child.form.gender_label'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderCard(
                          'male',
                          loc.t('child.form.gender_male'),
                          Icons.boy,
                          SafePlayColors.brandTeal500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderCard(
                          'female',
                          loc.t('child.form.gender_female'),
                          Icons.girl,
                          SafePlayColors.brandOrange500),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Age Group Selection
                Text(
                  loc.t('child.form.age_group_label'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAgeGroupCard(
                        AgeGroup.junior,
                        loc.t('child.form.age_group_junior'),
                        loc.t('child.form.age_group_junior_desc'),
                        Icons.child_care,
                        SafePlayColors.brandTeal500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAgeGroupCard(
                        AgeGroup.bright,
                        loc.t('child.form.age_group_bright'),
                        loc.t('child.form.age_group_bright_desc'),
                        Icons.school,
                        SafePlayColors.brandOrange500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SafePlayColors.brandTeal500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          loc.t('child.add.submit'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgeGroupCard(
    AgeGroup ageGroup,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedAgeGroup == ageGroup;
    final typedAge = int.tryParse(_ageController.text.trim());
    final isValidForAge =
        typedAge != null ? ageGroup.isValidAge(typedAge) : true;
    final isDisabled = typedAge != null && !isValidForAge;

    return InkWell(
      onTap: () {
        if (isDisabled) {
          _showAgeMismatchAlert(ageGroup, typedAge);
          return;
        }
        setState(() => _selectedAgeGroup = ageGroup);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? color
                : isDisabled
                    ? SafePlayColors.neutral200
                    : SafePlayColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : isDisabled
                  ? SafePlayColors.neutral100
                  : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? color
                  : isDisabled
                      ? SafePlayColors.neutral300
                      : SafePlayColors.neutral500,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? color
                    : isDisabled
                        ? SafePlayColors.neutral400
                        : SafePlayColors.neutral700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? color
                    : isDisabled
                        ? SafePlayColors.neutral400
                        : SafePlayColors.neutral500,
              ),
            ),
            if (isDisabled) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.loc
                      .t('child.age_value')
                      .replaceFirst('{age}', '$typedAge'),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(
      String gender, String title, IconData icon, Color color) {
    final isSelected = _selectedGender == gender;

    return InkWell(
      onTap: () {
        setState(() => _selectedGender = gender);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : SafePlayColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withValues(alpha: 0.1) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : SafePlayColors.neutral500,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : SafePlayColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgeMismatchAlert(AgeGroup selectedGroup, int childAge) {
    final loc = context.loc;
    final groupName = selectedGroup == AgeGroup.junior
        ? loc.t('child.form.age_group_junior')
        : loc.t('child.form.age_group_bright');
    final ageRange = selectedGroup == AgeGroup.junior ? '6-8' : '9-12';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(loc.t('child.form.age_mismatch_title')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc
                  .t('child.form.age_mismatch_body')
                  .replaceFirst('{age}', '$childAge')
                  .replaceFirst('{group}', groupName)
                  .replaceFirst('{range}', ageRange),
            ),
            const SizedBox(height: 12),
            Text(
              loc.t('child.form.age_mismatch_hint'),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.t('action.ok')),
          ),
        ],
      ),
    );
  }
}
