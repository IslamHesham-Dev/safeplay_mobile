import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/teacher_service.dart';
import '../../models/teacher_profile.dart' as teacher;
import '../../models/activity.dart';
import '../../models/question_template.dart';
import '../../design_system/colors.dart';

class ActivityCreationScreen extends StatefulWidget {
  const ActivityCreationScreen({super.key});

  @override
  State<ActivityCreationScreen> createState() => _ActivityCreationScreenState();
}

class _ActivityCreationScreenState extends State<ActivityCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _skillsController = TextEditingController();
  final _tagsController = TextEditingController();

  late final TeacherService _teacherService;
  teacher.TeacherProfile? _teacherProfile;
  List<QuestionTemplate> _availableTemplates = [];
  List<QuestionTemplate> _selectedTemplates = [];

  ActivitySubject _selectedSubject = ActivitySubject.math;
  teacher.AgeGroup _selectedAgeGroup = teacher.AgeGroup.junior;
  Difficulty _selectedDifficulty = Difficulty.easy;
  int _durationMinutes = 5;
  int _points = 100;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _teacherService = TeacherService();
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    _skillsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final teacherId = auth.currentUser?.id;

      if (teacherId == null) {
        setState(() => _error = 'No teacher ID found');
        return;
      }

      _teacherProfile = await _teacherService.getTeacherProfile(teacherId);

      if (_teacherProfile != null) {
        _availableTemplates = await _teacherService.getQuestionTemplates(
          teacherId: teacherId,
          subjects: _teacherProfile!.authorizedSubjects,
          ageGroups: _teacherProfile!.authorizedAgeGroups,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one template')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final teacherId = auth.currentUser?.id;

      if (teacherId == null) {
        throw Exception('No teacher ID found');
      }

      final learningObjectives = _objectivesController.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final skills = _skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final activityId = await _teacherService.createActivityFromTemplates(
        teacherId: teacherId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: _selectedSubject,
        ageGroup: _selectedAgeGroup,
        difficulty: _selectedDifficulty,
        templateIds: _selectedTemplates.map((t) => t.id).toList(),
        learningObjectives: learningObjectives,
        skills: skills,
        tags: tags,
        durationMinutes: _durationMinutes,
        points: _points,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Activity created successfully! ID: $activityId')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating activity: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _teacherProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Activity')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitialData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _loading ? null : _createActivity,
            child: Text(
              'Create',
              style: TextStyle(
                color: _loading ? Colors.white70 : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Activity Title',
                  hintText: 'e.g., Skip Counting Race',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the activity',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Activity Configuration
              _buildSectionHeader('Activity Configuration'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ActivitySubject>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: _teacherProfile?.authorizedSubjects
                              .map((subject) => DropdownMenuItem(
                                    value: subject,
                                    child: Text(subject.displayName),
                                  ))
                              .toList() ??
                          [],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSubject = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<teacher.AgeGroup>(
                      value: _selectedAgeGroup,
                      decoration: const InputDecoration(
                        labelText: 'Age Group',
                        border: OutlineInputBorder(),
                      ),
                      items: _teacherProfile?.authorizedAgeGroups
                              .map((group) => DropdownMenuItem(
                                    value: group,
                                    child: Text(group.displayName),
                                  ))
                              .toList() ??
                          [],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAgeGroup = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Difficulty>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: Difficulty.values
                          .map((difficulty) => DropdownMenuItem(
                                value: difficulty,
                                child: Text(difficulty.name.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDifficulty = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _durationMinutes.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _durationMinutes = int.tryParse(value) ?? 5;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _points.toString(),
                decoration: const InputDecoration(
                  labelText: 'Points',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _points = int.tryParse(value) ?? 100;
                },
              ),
              const SizedBox(height: 24),

              // Learning Objectives
              _buildSectionHeader('Learning Objectives'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _objectivesController,
                decoration: const InputDecoration(
                  labelText: 'Learning Objectives',
                  hintText: 'Enter one objective per line',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'At least one learning objective is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Skills and Tags
              _buildSectionHeader('Skills and Tags'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  hintText:
                      'e.g., skip-counting, place-value (comma separated)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'At least one skill is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'e.g., number-sense, patterns (comma separated)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'At least one tag is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Template Selection
              _buildSectionHeader('Question Templates'),
              const SizedBox(height: 16),

              if (_availableTemplates.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                          'No templates available for your specializations'),
                    ),
                  ),
                )
              else
                ..._availableTemplates
                    .map((template) => _buildTemplateCard(template)),

              const SizedBox(height: 24),

              // Selected Templates Summary
              if (_selectedTemplates.isNotEmpty) ...[
                _buildSectionHeader(
                    'Selected Templates (${_selectedTemplates.length})'),
                const SizedBox(height: 16),
                ..._selectedTemplates
                    .map((template) => _buildSelectedTemplateCard(template)),
                const SizedBox(height: 24),
              ],

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SafePlayColors.brandTeal500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Activity',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: SafePlayColors.brandTeal500,
      ),
    );
  }

  Widget _buildTemplateCard(QuestionTemplate template) {
    final isSelected = _selectedTemplates.contains(template);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? SafePlayColors.brandTeal500.withOpacity(0.1) : null,
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedTemplates.add(template);
            } else {
              _selectedTemplates.remove(template);
            }
          });
        },
        title: Text(template.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(template.prompt),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                Chip(
                  label: Text(template.type.name,
                      style: const TextStyle(fontSize: 10)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                ...template.skills.take(2).map((skill) => Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )),
              ],
            ),
          ],
        ),
        secondary: Text('${template.defaultPoints} pts'),
      ),
    );
  }

  Widget _buildSelectedTemplateCard(QuestionTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: SafePlayColors.brandTeal500.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: SafePlayColors.brandTeal500,
          child: Text(
            template.type.name[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(template.title),
        subtitle: Text(template.prompt),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () {
            setState(() {
              _selectedTemplates.remove(template);
            });
          },
        ),
      ),
    );
  }
}
