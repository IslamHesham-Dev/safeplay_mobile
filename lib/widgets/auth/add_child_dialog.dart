import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../../constants/authentication_options.dart';
import '../../design_system/colors.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../services/local_child_storage.dart';
import '../avatar_widget.dart';

/// Dialog for adding a new child with authentication setup
class AddChildDialog extends StatefulWidget {
  final Function(ChildProfile) onChildAdded;
  final String? parentEmail; // Pre-verified parent email

  const AddChildDialog({
    super.key,
    required this.onChildAdded,
    this.parentEmail,
  });

  @override
  State<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _parentEmailController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  Future<bool> _validateParentEmail(String email) async {
    return LocalChildStorage.validateParentEmail(email.trim());
  }

  void _failValidation(String message) {
    if (!mounted) {
      _isLoading = false;
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.child_care,
                    color: SafePlayColors.brandTeal500,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Your Child',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: SafePlayColors.neutral700,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Child\'s Name',
                  hintText: 'Enter your child\'s name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your child\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age field
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter your child\'s age',
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your child\'s age';
                  }
                  final age = int.tryParse(value.trim());
                  if (age == null || age < 6 || age > 12) {
                    return 'Age must be between 6 and 12';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Parent email field (only show if not pre-verified)
              if (widget.parentEmail == null) ...[
                TextFormField(
                  controller: _parentEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Your Email (Parent)',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Show verified parent email
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SafePlayColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SafePlayColors.success),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: SafePlayColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verified Parent: ${widget.parentEmail}',
                          style: TextStyle(
                            color: SafePlayColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Gender selection
              Text(
                'Gender',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Boy'),
                      value: 'male',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Girl'),
                      value: 'female',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SafePlayColors.brandTeal500,
                        foregroundColor: Colors.white,
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
                          : const Text('Add Child'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your child\'s gender'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final ageText = _ageController.text.trim();
      final age = int.tryParse(ageText);
      if (age == null || age < 6 || age > 12) {
        _failValidation(
          'Child age must be between 6 and 12 years old.',
        );
        return;
      }

      final parentEmail =
          (widget.parentEmail ?? _parentEmailController.text).trim();
      if (!await _validateParentEmail(parentEmail)) {
        _failValidation(
          'Parent email $parentEmail does not exist. Please check your email or contact support.',
        );
        return;
      }

      final childName = _nameController.text.trim();
      final normalizedGender = (_selectedGender ?? '').toLowerCase();

      // Validate that this child belongs to the verified parent and fetch canonical profile
      final childProfileFromFirestore =
          await LocalChildStorage.fetchChildForParent(
        parentEmail: parentEmail,
        childName: childName,
        childAge: age,
        childGender: normalizedGender,
      );

      if (childProfileFromFirestore == null) {
        _failValidation(
          'Child "$childName" (age $age, ${normalizedGender.isEmpty ? 'unspecified gender' : normalizedGender}) does not belong to parent $parentEmail. Please verify the child information or contact support.',
        );
        return;
      }

      // Normalize and merge remote profile
      final normalizedEmail = parentEmail.toLowerCase();
      final resolvedAgeGroup = childProfileFromFirestore.ageGroup ??
          (age >= 6 && age <= 8 ? AgeGroup.junior : AgeGroup.bright);
      final resolvedGender = (childProfileFromFirestore.gender ?? '')
              .trim()
              .toLowerCase()
              .isNotEmpty
          ? childProfileFromFirestore.gender
          : (normalizedGender.isEmpty ? null : normalizedGender);

      var localChild = childProfileFromFirestore.copyWith(
        age: childProfileFromFirestore.age ?? age,
        gender: resolvedGender,
        ageGroup: resolvedAgeGroup,
        parentEmail: normalizedEmail,
        updatedAt: DateTime.now(),
      );

      final existingChild = await LocalChildStorage.getChildById(localChild.id);
      if (existingChild != null) {
        localChild = existingChild.copyWith(
          name: childProfileFromFirestore.name,
          age: localChild.age,
          gender: localChild.gender,
          ageGroup: localChild.ageGroup,
          parentEmail: normalizedEmail,
          parentIds: childProfileFromFirestore.parentIds,
          updatedAt: DateTime.now(),
        );
        await LocalChildStorage.updateChild(localChild);
      } else {
        await LocalChildStorage.addChild(localChild);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Navigate to authentication setup
      Navigator.of(context).pop();

      if (localChild.ageGroup == AgeGroup.junior) {
        _showJuniorAuthSetup(localChild);
      } else {
        _showBrightAuthSetup(localChild);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding child: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showJuniorAuthSetup(ChildProfile child) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JuniorAuthSetupDialog(
        child: child,
        onComplete: (child) {
          widget.onChildAdded(child);
        },
      ),
    );
  }

  void _showBrightAuthSetup(ChildProfile child) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BrightAuthSetupDialog(
        child: child,
        onComplete: (child) {
          widget.onChildAdded(child);
        },
      ),
    );
  }
}

/// Dialog for Junior authentication setup (4 emojis)
class JuniorAuthSetupDialog extends StatefulWidget {
  final ChildProfile child;
  final Function(ChildProfile) onComplete;

  const JuniorAuthSetupDialog({
    super.key,
    required this.child,
    required this.onComplete,
  });

  @override
  State<JuniorAuthSetupDialog> createState() => _JuniorAuthSetupDialogState();
}

class _JuniorAuthSetupDialogState extends State<JuniorAuthSetupDialog> {
  final List<String> _selectedEmojis = [];
  final List<String> _juniorEmojis = juniorEmojiOptions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.emoji_emotions,
                  color: SafePlayColors.juniorPurple,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Set Up ${widget.child.name}\'s Login',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: SafePlayColors.neutral700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Choose 4 emojis that ${widget.child.name} will use to log in.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: SafePlayColors.neutral600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Emoji selection
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _juniorEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _juniorEmojis[index];
                  final isSelected = _selectedEmojis.contains(emoji);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEmojis.remove(emoji);
                        } else if (_selectedEmojis.length < 4) {
                          _selectedEmojis.add(emoji);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SafePlayColors.juniorPurple
                            : SafePlayColors.neutral100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? SafePlayColors.juniorPurple
                              : SafePlayColors.neutral300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Selected emojis display
            if (_selectedEmojis.isNotEmpty) ...[
              Text(
                'Selected: ${_selectedEmojis.join(' ')}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SafePlayColors.juniorPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
            ],

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedEmojis.length == 4
                        ? _saveAuthentication
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SafePlayColors.juniorPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _selectedEmojis.length == 4
                          ? 'Save Login'
                          : 'Select 4 emojis (${_selectedEmojis.length}/4)',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAuthentication() async {
    try {
      // Validate credentials first
      if (_selectedEmojis.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please select exactly 4 emojis for your child\'s login.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create auth data for local storage
      final authData = {
        'authType': 'emoji',
        'pictureSequenceHash': _hashPictureSequence(_selectedEmojis),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Update child with auth data
      final updatedChild = widget.child.copyWith(
        authData: authData,
      );

      // Save to local storage
      await LocalChildStorage.updateChild(updatedChild);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login setup completed for ${widget.child.name}!'),
            backgroundColor: SafePlayColors.success,
          ),
        );
      }

      Navigator.of(context).pop();
      widget.onComplete(updatedChild);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up login: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _hashPictureSequence(List<String> sequence) {
    final combined = sequence.join('|');
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Dialog for Bright authentication setup (3 letters + PIN)
class BrightAuthSetupDialog extends StatefulWidget {
  final ChildProfile child;
  final Function(ChildProfile) onComplete;

  const BrightAuthSetupDialog({
    super.key,
    required this.child,
    required this.onComplete,
  });

  @override
  State<BrightAuthSetupDialog> createState() => _BrightAuthSetupDialogState();
}

class _BrightAuthSetupDialogState extends State<BrightAuthSetupDialog> {
  List<String> _selectedPictures = [];
  final _pinController = TextEditingController();
  final List<String> _brightPictures = brightPictureOptions;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: SafePlayColors.brightIndigo,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Set Up ${widget.child.name}\'s Login',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: SafePlayColors.neutral700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Choose 3 letters and create a 4-digit PIN for ${widget.child.name}.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: SafePlayColors.neutral600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Picture selection
            Text(
              'Step 1: Choose 3 letters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _brightPictures.length,
                itemBuilder: (context, index) {
                  final picture = _brightPictures[index];
                  final isSelected = _selectedPictures.contains(picture);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedPictures.remove(picture);
                        } else if (_selectedPictures.length < 3) {
                          _selectedPictures.add(picture);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SafePlayColors.brightIndigo
                            : SafePlayColors.neutral100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? SafePlayColors.brightIndigo
                              : SafePlayColors.neutral300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: AvatarWidget(
                          name: picture,
                          size: 32,
                          backgroundColor: isSelected
                              ? Colors.white
                              : SafePlayColors.brightIndigo,
                          textColor: isSelected
                              ? SafePlayColors.brightIndigo
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // PIN input
            Text(
              'Step 2: Create a 4-digit PIN',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: '4-digit PIN',
                hintText: 'Enter 4 digits',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.length != 4) {
                  return 'PIN must be 4 digits';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canSave ? _saveAuthentication : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SafePlayColors.brightIndigo,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _canSave
                          ? 'Save Login'
                          : 'Complete setup (${_selectedPictures.length}/3 letters, ${_pinController.text.length}/4 PIN)',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSave {
    return _selectedPictures.length == 3 && _pinController.text.length == 4;
  }

  Future<void> _saveAuthentication() async {
    try {
      // Validate credentials first
      if (_selectedPictures.length != 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please select exactly 3 letters for your child\'s login.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final pinValue = _pinController.text.trim();
      if (!RegExp(r'^\d{4}$').hasMatch(pinValue)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a 4-digit PIN to continue.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create auth data for local storage
      final authData = {
        'authType': 'picture+pin',
        'pictureSequenceHash': _hashPictureSequence(_selectedPictures),
        'pinHash': _hashPin(pinValue),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Update child with auth data
      final updatedChild = widget.child.copyWith(
        authData: authData,
      );

      // Save to local storage
      await LocalChildStorage.updateChild(updatedChild);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login setup completed for ${widget.child.name}!'),
            backgroundColor: SafePlayColors.success,
          ),
        );
      }

      Navigator.of(context).pop();
      widget.onComplete(updatedChild);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up login: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _hashPictureSequence(List<String> sequence) {
    final combined = sequence.join('|');
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
