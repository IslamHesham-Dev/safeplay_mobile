import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../localization/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../navigation/route_names.dart';
import '../../providers/child_provider.dart';

/// Edit Child screen for parents to modify child profiles
class EditChildScreen extends StatefulWidget {
  final ChildProfile child;

  const EditChildScreen({
    super.key,
    required this.child,
  });

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  AgeGroup _selectedAgeGroup = AgeGroup.junior;
  String? _selectedGender; // 'male' or 'female'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.child.name;
    _ageController.text = widget.child.age?.toString() ?? '';
    _selectedAgeGroup = widget.child.ageGroup ?? AgeGroup.junior;
    _selectedGender = widget.child.gender;
  }

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

    setState(() => _isLoading = true);

    try {
      final childProvider = context.read<ChildProvider>();

      // Get age from input
      final age = int.tryParse(_ageController.text.trim());

      // Create updated child profile
      final updatedChild = widget.child.copyWith(
        name: _nameController.text.trim(),
        ageGroup: _selectedAgeGroup,
        userType: _selectedAgeGroup == AgeGroup.junior
            ? UserType.juniorChild
            : UserType.brightChild,
        age: age,
        gender: _selectedGender,
        updatedAt: DateTime.now(),
      );

      // Update child in Firestore
      final success = await childProvider.updateChild(updatedChild);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.t('child.edit.success')),
              backgroundColor: SafePlayColors.success,
            ),
          );
          context.pop();
        }
      } else {
        throw Exception(
            childProvider.error ?? 'Failed to update child profile');
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
        title: Text(loc.t('child.edit.title')),
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
                  loc
                      .t('child.edit.header')
                      .replaceFirst('{name}', widget.child.name),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.t('child.edit.subtitle'),
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

                // Authentication Section
                _buildAuthenticationSection(),

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
                              loc.t('child.edit.submit'),
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

  Widget _buildAuthenticationSection() {
    final loc = context.loc;
    final hasAuth =
        widget.child.authData != null && widget.child.authData!.isNotEmpty;
    final authType = widget.child.authData?['authType'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SafePlayColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SafePlayColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: SafePlayColors.brandTeal500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                loc.t('child.auth.section_title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasAuth) ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: SafePlayColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
              Text(
                authType == 'emoji' || authType == 'picture'
                    ? loc.t('child.auth.junior')
                    : loc.t('child.auth.bright'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SafePlayColors.success,
                      fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to appropriate auth setup
                      if (widget.child.ageGroup == AgeGroup.junior) {
                        context.push(RouteNames.juniorAuthSetup,
                            extra: widget.child);
                      } else {
                        context.push(RouteNames.brightAuthSetup,
                            extra: widget.child);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(loc.t('child.auth.change')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SafePlayColors.brandTeal500,
                      side: BorderSide(color: SafePlayColors.brandTeal500),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: SafePlayColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
              Text(
                loc.t('child.auth.none'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SafePlayColors.warning,
                      fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to appropriate auth setup
                      if (widget.child.ageGroup == AgeGroup.junior) {
                        context.push(RouteNames.juniorAuthSetup,
                            extra: widget.child);
                      } else {
                        context.push(RouteNames.brightAuthSetup,
                            extra: widget.child);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(loc.t('child.auth.setup')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SafePlayColors.brandTeal500,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
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

  void _showAgeMismatchAlert(AgeGroup selectedGroup, int? childAge) {
    if (childAge == null) return;

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
