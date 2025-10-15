import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for creating demo data for testing parent account management features
class DemoDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Demo parent accounts
  static const List<Map<String, dynamic>> demoParents = [
    {
      'email': 'demo.parent1@safeplay.com',
      'password': 'DemoParent123!',
      'displayName': 'Sarah Chen',
      'phone': '+1 (555) 123-4567',
      'location': 'San Francisco, CA',
      'bio':
          'Mother of two amazing kids who love learning through SafePlay. I work in tech and believe in the power of educational technology.',
      'children': [
        {
          'fullName': 'Emma Chen',
          'ageGroup': 'junior',
          'grade': 2,
          'dateOfBirth': '2017-03-15',
          'favoriteSubjects': ['Mathematics', 'Art', 'Science'],
          'learningModes': ['Visual', 'Kinesthetic']
        },
        {
          'fullName': 'Liam Chen',
          'ageGroup': 'bright',
          'grade': 5,
          'dateOfBirth': '2014-08-22',
          'favoriteSubjects': ['Science', 'Technology', 'Mathematics'],
          'learningModes': ['Visual', 'Reading/Writing']
        }
      ]
    },
    {
      'email': 'demo.parent2@safeplay.com',
      'password': 'DemoParent123!',
      'displayName': 'Michael Rodriguez',
      'phone': '+1 (555) 987-6543',
      'location': 'Austin, TX',
      'bio':
          'Father of three and elementary school teacher. I use SafePlay both as a parent and educator to support children\'s learning.',
      'children': [
        {
          'fullName': 'Sofia Rodriguez',
          'ageGroup': 'junior',
          'grade': 1,
          'dateOfBirth': '2018-11-08',
          'favoriteSubjects': ['Language Arts', 'Music', 'Art'],
          'learningModes': ['Auditory', 'Visual']
        },
        {
          'fullName': 'Diego Rodriguez',
          'ageGroup': 'bright',
          'grade': 4,
          'dateOfBirth': '2015-06-12',
          'favoriteSubjects': [
            'Social Studies',
            'Language Arts',
            'Physical Education'
          ],
          'learningModes': ['Kinesthetic', 'Auditory']
        },
        {
          'fullName': 'Isabella Rodriguez',
          'ageGroup': 'bright',
          'grade': 6,
          'dateOfBirth': '2013-01-25',
          'favoriteSubjects': ['Mathematics', 'Science', 'Technology'],
          'learningModes': ['Reading/Writing', 'Visual']
        }
      ]
    },
    {
      'email': 'demo.parent3@safeplay.com',
      'password': 'DemoParent123!',
      'displayName': 'Jennifer Kim',
      'phone': '+1 (555) 456-7890',
      'location': 'Seattle, WA',
      'bio':
          'Working mom who values quality educational content for my daughter. SafePlay has been a game-changer for our family.',
      'children': [
        {
          'fullName': 'Aria Kim',
          'ageGroup': 'junior',
          'grade': 3,
          'dateOfBirth': '2016-09-14',
          'favoriteSubjects': ['Art', 'Music', 'Language Arts'],
          'learningModes': ['Visual', 'Auditory']
        }
      ]
    }
  ];

  // Demo activities
  static const List<Map<String, dynamic>> demoActivities = [
    {
      'title': 'Counting with Animals',
      'subject': 'Mathematics',
      'ageGroup': 'junior',
      'durationMinutes': 15,
      'points': 50,
      'type': 'interactive',
      'description': 'Learn to count from 1 to 10 using cute animal characters',
      'questions': [
        {
          'question': 'How many cats do you see?',
          'type': 'multiple-choice',
          'options': ['3', '4', '5', '6'],
          'correctAnswer': '4',
          'points': 10
        },
        {
          'question': 'Count the dogs and select the correct number',
          'type': 'multiple-choice',
          'options': ['2', '3', '4', '5'],
          'correctAnswer': '3',
          'points': 10
        }
      ]
    },
    {
      'title': 'Solar System Explorer',
      'subject': 'Science',
      'ageGroup': 'bright',
      'durationMinutes': 25,
      'points': 75,
      'type': 'interactive',
      'description':
          'Explore the planets in our solar system and learn about their characteristics',
      'questions': [
        {
          'question': 'Which planet is closest to the Sun?',
          'type': 'multiple-choice',
          'options': ['Venus', 'Mercury', 'Earth', 'Mars'],
          'correctAnswer': 'Mercury',
          'points': 15
        },
        {
          'question': 'What is the largest planet in our solar system?',
          'type': 'multiple-choice',
          'options': ['Saturn', 'Jupiter', 'Neptune', 'Uranus'],
          'correctAnswer': 'Jupiter',
          'points': 15
        }
      ]
    },
    {
      'title': 'Creative Story Writing',
      'subject': 'Language Arts',
      'ageGroup': 'bright',
      'durationMinutes': 30,
      'points': 100,
      'type': 'creative',
      'description':
          'Write a creative story using provided prompts and characters',
      'questions': [
        {
          'question': 'Write a story about a magical forest',
          'type': 'text',
          'points': 50
        },
        {
          'question': 'Describe your main character in detail',
          'type': 'text',
          'points': 50
        }
      ]
    }
  ];

  /// Create demo parent account with children and activities
  Future<bool> createDemoParent(Map<String, dynamic> parentData) async {
    try {
      print('Creating demo parent: ${parentData['displayName']}');

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: parentData['email'],
        password: parentData['password'],
      );
      final user = userCredential.user!;

      // Update user profile
      await user.updateDisplayName(parentData['displayName']);

      // Create user document in Firestore
      final userDoc = {
        'uid': user.uid,
        'email': parentData['email'],
        'displayName': parentData['displayName'],
        'phone': parentData['phone'],
        'location': parentData['location'],
        'bio': parentData['bio'],
        'role': 'parent',
        'childrenIds': <String>[],
        'notificationPreferences': {
          'email': true,
          'push': true,
          'weeklyReports': true,
          'incidentAlerts': true,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userDoc);

      // Create children profiles
      final List<String> childIds = [];
      for (final childData in parentData['children']) {
        final childDoc = {
          'fullName': childData['fullName'],
          'ageGroup': childData['ageGroup'],
          'grade': childData['grade'],
          'dateOfBirth': childData['dateOfBirth'],
          'parentIds': [user.uid],
          'preferences': {
            'favoriteSubjects': childData['favoriteSubjects'],
            'learningModes': childData['learningModes'],
          },
          'stats': {
            'level': (DateTime.now().millisecondsSinceEpoch % 5) + 1,
            'totalPoints': (DateTime.now().millisecondsSinceEpoch % 500) + 100,
            'currentStreak': (DateTime.now().millisecondsSinceEpoch % 10) + 1,
            'totalActivitiesCompleted':
                (DateTime.now().millisecondsSinceEpoch % 20) + 5,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        final childRef = await _firestore.collection('children').add(childDoc);
        childIds.add(childRef.id);
      }

      // Update parent's childrenIds
      await _firestore.collection('users').doc(user.uid).update({
        'childrenIds': childIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create demo activities
      for (final activityData in demoActivities) {
        final activityDoc = {
          ...activityData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('activities').add(activityDoc);
      }

      // Create demo notifications for this parent
      final notifications = [
        {
          'type': 'achievement',
          'title': 'Great Job!',
          'message':
              '${parentData['children'][0]['fullName']} completed their first activity and earned 50 points!',
          'childName': parentData['children'][0]['fullName'],
          'userId': user.uid,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'type': 'streak',
          'title': 'Learning Streak!',
          'message':
              '${parentData['children'].length > 1 ? parentData['children'][1]['fullName'] : parentData['children'][0]['fullName']} has maintained a 5-day learning streak!',
          'childName': parentData['children'].length > 1
              ? parentData['children'][1]['fullName']
              : parentData['children'][0]['fullName'],
          'userId': user.uid,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'type': 'weekly-report',
          'title': 'Weekly Learning Report',
          'message': 'Your children completed 12 activities this week',
          'userId': user.uid,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        }
      ];

      for (final notification in notifications) {
        await _firestore.collection('notifications').add(notification);
      }

      print(
          '✅ Created demo parent: ${parentData['displayName']} with ${parentData['children'].length} children');

      // Sign out the created user
      await _auth.signOut();

      return true;
    } catch (error) {
      print(
          '❌ Error creating demo parent ${parentData['displayName']}: $error');
      return false;
    }
  }

  /// Create all demo data
  Future<bool> createAllDemoData() async {
    print('🚀 Starting demo data creation...');

    try {
      bool allSuccess = true;

      // Create all demo parents
      for (final parentData in demoParents) {
        final success = await createDemoParent(parentData);
        if (!success) allSuccess = false;
      }

      if (allSuccess) {
        print('✅ Demo data creation completed!');
        print('\n📋 Demo Accounts Created:');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        for (int i = 0; i < demoParents.length; i++) {
          final parent = demoParents[i];
          print('\n👤 Parent ${i + 1}: ${parent['displayName']}');
          print('   📧 Email: ${parent['email']}');
          print('   🔑 Password: ${parent['password']}');
          print('   👶 Children: ${parent['children'].length}');
          for (int j = 0; j < parent['children'].length; j++) {
            final child = parent['children'][j];
            print(
                '      ${j + 1}. ${child['fullName']} (${child['ageGroup']}, Grade ${child['grade']})');
          }
        }

        print('\n🎯 Next Steps:');
        print('1. Run the Flutter app: flutter run');
        print('2. Use any of the demo accounts above to test the features');
        print(
            '3. Test parent login, profile management, and family management');
      }

      return allSuccess;
    } catch (error) {
      print('❌ Error creating demo data: $error');
      return false;
    }
  }

  /// Get demo parent accounts for display
  static List<Map<String, dynamic>> getDemoAccounts() {
    return demoParents;
  }

  /// Create demo profile picture (placeholder)
  Future<String?> createDemoProfilePicture(String userId) async {
    try {
      // For demo purposes, we'll skip actual image upload
      // and just return a placeholder URL
      return 'https://via.placeholder.com/150/4F46E5/FFFFFF?text=${userId.substring(0, 1).toUpperCase()}';
    } catch (error) {
      print('Error creating demo profile picture: $error');
      return null;
    }
  }

  /// Create demo activity progress for a child
  Future<void> createDemoActivityProgress(
      String childId, String activityId) async {
    try {
      final progressDoc = {
        'childId': childId,
        'activityId': activityId,
        'status': 'completed',
        'score': 85,
        'pointsEarned': 50,
        'timeSpent': 15,
        'completedAt': FieldValue.serverTimestamp(),
        'answers': [
          {'questionId': 'q1', 'answer': '4', 'correct': true},
          {'questionId': 'q2', 'answer': '3', 'correct': true},
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('activityProgress').add(progressDoc);
    } catch (error) {
      print('Error creating demo activity progress: $error');
    }
  }
}
