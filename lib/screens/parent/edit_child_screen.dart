import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
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
  final _gradeController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  AgeGroup _selectedAgeGroup = AgeGroup.junior;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.child.name;
    _gradeController.text = widget.child.grade?.toString() ?? '';
    _selectedDateOfBirth = widget.child.dateOfBirth;
    _selectedAgeGroup = widget.child.ageGroup ?? AgeGroup.junior;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date of birth'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final childProvider = context.read<ChildProvider>();

      // Create updated child profile
      final updatedChild = widget.child.copyWith(
        name: _nameController.text.trim(),
        ageGroup: _selectedAgeGroup,
        userType: _selectedAgeGroup == AgeGroup.junior
            ? UserType.juniorChild
            : UserType.brightChild,
        grade: int.tryParse(_gradeController.text.trim()),
        dateOfBirth: _selectedDateOfBirth,
        updatedAt: DateTime.now(),
      );

      // Update child in Firestore
      final success = await childProvider.updateChild(updatedChild);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Child profile updated successfully!'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Child Profile'),
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
                  'Edit ${widget.child.name}\'s Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Update your child\'s information',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SafePlayColors.neutral600,
                      ),
                ),
                const SizedBox(height: 32),

                // Child Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Child\'s Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your child\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date of Birth
                InkWell(
                  onTap: _selectDateOfBirth,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: Icon(Icons.cake_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedDateOfBirth != null
                          ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                          : 'Select date of birth',
                      style: TextStyle(
                        color: _selectedDateOfBirth != null
                            ? null
                            : SafePlayColors.neutral500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Grade (Optional)
                TextFormField(
                  controller: _gradeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Grade (Optional)',
                    prefixIcon: Icon(Icons.school_outlined),
                    border: OutlineInputBorder(),
                    helperText: 'e.g., 1, 2, 3, etc.',
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final grade = int.tryParse(value.trim());
                      if (grade == null || grade < 1 || grade > 12) {
                        return 'Please enter a valid grade (1-12)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Age Group Selection
                Text(
                  'Age Group',
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
                        'Junior Explorer',
                        'Ages 4-7',
                        Icons.child_care,
                        SafePlayColors.brandTeal500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAgeGroupCard(
                        AgeGroup.bright,
                        'Bright Minds',
                        'Ages 8-12',
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
                      : const Text(
                          'Update Child Profile',
                          style: TextStyle(
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

    return InkWell(
      onTap: () => setState(() => _selectedAgeGroup = ageGroup),
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
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : SafePlayColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 12, 1, 1);
    final lastDate = DateTime(now.year - 4, 12, 31);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 6, 1, 1),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: SafePlayColors.brandTeal500,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDateOfBirth = selectedDate;
        // Auto-select age group based on age
        final age = _calculateAge(selectedDate);
        if (age >= 4 && age <= 7) {
          _selectedAgeGroup = AgeGroup.junior;
        } else if (age >= 8 && age <= 12) {
          _selectedAgeGroup = AgeGroup.bright;
        }
      });
    }
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    var age = now.year - dateOfBirth.year;
    final birthdayPassed = (now.month > dateOfBirth.month) ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);
    if (!birthdayPassed) {
      age -= 1;
    }
    return age;
  }
}
