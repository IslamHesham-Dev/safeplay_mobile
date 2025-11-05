import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../screens/auth/junior_picture_password_login.dart';
import '../../screens/auth/bright_picture_pin_login.dart';

/// Child selector screen for choosing which child to log in
class ChildSelectorScreen extends StatelessWidget {
  const ChildSelectorScreen({super.key});

  // Demo children data - in a real app, this would come from Firebase
  static const List<Map<String, dynamic>> _demoChildren = [
    {
      'id': 'child-emma',
      'name': 'Emma Chen',
      'ageGroup': 'junior',
      'avatar': '👧',
      'loginType': 'emoji',
      'emojiSequence': ['🦊', '🌈', '⭐'],
    },
    {
      'id': 'child-liam',
      'name': 'Liam Chen',
      'ageGroup': 'bright',
      'avatar': '👦',
      'loginType': 'picture_pin',
      'pictureSelection': ['rocket', 'microscope', 'planet'],
      'pin': '4312',
    },
    {
      'id': 'child-sofia',
      'name': 'Sofia Rodriguez',
      'ageGroup': 'junior',
      'avatar': '👧',
      'loginType': 'emoji',
      'emojiSequence': ['🎵', '🎨', '📚'],
    },
    {
      'id': 'child-diego',
      'name': 'Diego Rodriguez',
      'ageGroup': 'bright',
      'avatar': '👦',
      'loginType': 'picture_pin',
      'pictureSelection': ['globe', 'book', 'telescope'],
      'pin': '7890',
    },
    {
      'id': 'child-aria',
      'name': 'Aria Kim',
      'ageGroup': 'junior',
      'avatar': '👧',
      'loginType': 'emoji',
      'emojiSequence': ['🎨', '🎵', '🦋'],
    },
  ];

  void _navigateToChildLogin(BuildContext context, Map<String, dynamic> child) {
    final childId = child['id'] as String;
    final childName = child['name'] as String;
    final ageGroup = child['ageGroup'] as String;

    if (ageGroup == 'junior') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JuniorPicturePasswordLogin(
            childId: childId,
            childName: childName,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BrightPicturePinLogin(
            childId: childId,
            childName: childName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profile'),
        backgroundColor: SafePlayColors.brandTeal500,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Who is learning today?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: SafePlayColors.brandTeal500,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your profile to start learning',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SafePlayColors.neutral600,
                    ),
              ),
              const SizedBox(height: 32),

              // Demo children profiles
              Expanded(
                child: ListView.builder(
                  itemCount: _demoChildren.length,
                  itemBuilder: (context, index) {
                    final child = _demoChildren[index];
                    final name = child['name'] as String;
                    final avatar = child['avatar'] as String;
                    final ageGroup = child['ageGroup'] as String;
                    final loginType = child['loginType'] as String;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: ageGroup == 'junior'
                              ? SafePlayColors.juniorPurple
                              : SafePlayColors.brightIndigo,
                          child: Text(
                            avatar,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ageGroup == 'junior'
                                  ? 'Junior Explorer'
                                  : 'Bright Minds',
                              style: TextStyle(
                                color: ageGroup == 'junior'
                                    ? SafePlayColors.juniorPurple
                                    : SafePlayColors.brightIndigo,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loginType == 'emoji'
                                  ? 'Login with emoji sequence'
                                  : 'Login with pictures + PIN',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: SafePlayColors.neutral600,
                                  ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: SafePlayColors.neutral400,
                        ),
                        onTap: () => _navigateToChildLogin(context, child),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Help section
              Card(
                color: SafePlayColors.neutral50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: SafePlayColors.brandTeal500,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Need Help?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ask your parent to help you log in or reset your password.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SafePlayColors.neutral600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
