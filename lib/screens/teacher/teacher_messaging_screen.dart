import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../models/teacher_broadcast_message.dart';
import '../../models/teacher_inbox_message.dart';
import '../../models/user_type.dart';
import '../../providers/auth_provider.dart';
import '../../services/messaging_service.dart';
import '../../navigation/route_names.dart';

/// Teacher Messaging Screen - Broadcast messages to students
class TeacherMessagingScreen extends StatefulWidget {
  const TeacherMessagingScreen({super.key});

  @override
  State<TeacherMessagingScreen> createState() => _TeacherMessagingScreenState();
}

class _TeacherMessagingScreenState extends State<TeacherMessagingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  String _selectedAgeGroup = 'bright'; // 'junior' or 'bright'
  final TextEditingController _customMessageController =
      TextEditingController();
  late final MessagingService _messagingService;
  StreamSubscription<List<TeacherInboxMessage>>? _inboxSubscription;
  StreamSubscription<List<TeacherBroadcastMessage>>? _sentSubscription;
  bool _sendingBroadcast = false;

  // Pre-made friendly nudges/notifications with game links
  final List<QuickMessage> _quickMessages = [
    // Science Games - Junior
    QuickMessage(
      id: 'food-chains',
      emoji: '🌳',
      title: 'Explore Food Chains!',
      message:
          'Hey explorers! 🌿 Ready to discover who eats what in nature? Open the Food Chains game and learn about animals, plants, and how they all connect! You can find it under Science Interactive Games in your dashboard.',
      category: 'Science',
      color: const Color(0xFF4CAF50),
      gameId: 'food-chains',
      gameName: 'Food Chains',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Play Food Chains',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'microorganisms',
      emoji: '🦠',
      title: 'Tiny World Adventure!',
      message:
          'Did you know there are living things too small to see? 🔬 Explore the world of microorganisms - bacteria, fungi, and algae are waiting for you! Find this game under Science Interactive Games.',
      category: 'Science',
      color: const Color(0xFF9C27B0),
      gameId: 'microorganisms',
      gameName: 'Microorganisms',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Explore Microorganisms',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'health-growth',
      emoji: '🏃',
      title: 'Stay Healthy & Strong!',
      message:
          'Learn how your body needs water, food, exercise and rest to stay healthy! 💪 Help Ben live a healthy life in the Human Body Health & Growth game. Find it in Science Interactive Games.',
      category: 'Science',
      color: const Color(0xFFE91E63),
      gameId: 'health-growth',
      gameName: 'Human Body Health & Growth',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Play Health & Growth',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'teeth-eating',
      emoji: '🦷',
      title: 'Amazing Teeth Facts!',
      message:
          'Did you know lions have very different teeth than sheep? 🦁 Learn how animals\' teeth are adapted to what they eat! Find Teeth & Eating under Science Interactive Games.',
      category: 'Science',
      color: const Color(0xFF00BCD4),
      gameId: 'teeth-eating',
      gameName: 'Teeth & Eating',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Explore Teeth & Eating',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'plants-animals',
      emoji: '🌱',
      title: 'Discover Plants & Animals!',
      message:
          'Spot plants and animals in an outdoor scene! 🌿 Discover where they live and learn how different habitats suit different living things. Find it under Science Interactive Games.',
      category: 'Science',
      color: const Color(0xFF8BC34A),
      gameId: 'plants-animals',
      gameName: 'Plants & Animals',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Explore Plants & Animals',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'how-plants-grow',
      emoji: '🌻',
      title: 'Watch Plants Grow!',
      message:
          'Learn how plants need water, light, and soil to grow! 🌱 Experiment with different conditions and see what happens. Find How Plants Grow under Science Interactive Games.',
      category: 'Science',
      color: const Color(0xFF4CAF50),
      gameId: 'how-plants-grow',
      gameName: 'How Plants Grow',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Grow Plants',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    // Math Games - Junior
    QuickMessage(
      id: 'addition-junior',
      emoji: '➕',
      title: 'Add It Up!',
      message:
          'Practice your addition skills! ➕ Solve fun math problems and become a number wizard! Find Addition games under Math Interactive Games in your dashboard.',
      category: 'Math',
      color: const Color(0xFF5B9BD5),
      gameId: 'addition',
      gameName: 'Addition',
      gameLocation: 'Math Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Play Addition',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'subtraction-junior',
      emoji: '➖',
      title: 'Subtract & Solve!',
      message:
          'Master subtraction with fun games! ➖ Take away numbers and find the answer. Find Subtraction games under Math Interactive Games.',
      category: 'Math',
      color: const Color(0xFFE91E63),
      gameId: 'subtraction',
      gameName: 'Subtraction',
      gameLocation: 'Math Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Play Subtraction',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'shapes-junior',
      emoji: '🔷',
      title: 'Shape Explorer!',
      message:
          'Discover circles, squares, triangles and more! 🔷 Learn about shapes and their properties. Find Shapes under Math Interactive Games.',
      category: 'Math',
      color: const Color(0xFFFF9800),
      gameId: 'shapes',
      gameName: 'Shapes',
      gameLocation: 'Math Interactive Games section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Explore Shapes',
      ageGroup: 'junior',
      gameType: 'web',
    ),
    // Science Games - Bright
    QuickMessage(
      id: 'electricity',
      emoji: '⚡',
      title: 'Power Up with Circuits!',
      message:
          'Ready to become an electricity expert? 💡 Build circuits, connect batteries and bulbs, and see what happens! Find the Electricity game under Science Interactive Games in your Bright dashboard.',
      category: 'Science',
      color: const Color(0xFFFF9800),
      gameId: 'electricity-circuits',
      gameName: 'Electricity & Circuits',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Build Circuits',
      ageGroup: 'bright',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'earth-sun-moon',
      emoji: '🌍',
      title: 'Space Explorer Time!',
      message:
          'Blast off into space! 🚀 Learn how Earth, Sun, and Moon dance together in the sky. Discover orbits and why we have day and night! Find it under Science Interactive Games.',
      category: 'Science',
      color: const Color(0xFF2196F3),
      gameId: 'earth-sun-moon',
      gameName: 'Earth, Sun & Moon',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Explore Space',
      ageGroup: 'bright',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'forces-action',
      emoji: '💨',
      title: 'Forces in Action!',
      message:
          'Discover how forces make things move! 💨 Push, pull, and see what happens. Find Forces in Action under Science Interactive Games.',
      category: 'Science',
      color: const Color(0xFF9C27B0),
      gameId: 'forces-action',
      gameName: 'Forces in Action',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Explore Forces',
      ageGroup: 'bright',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'magnets-springs',
      emoji: '🧲',
      title: 'Magnets & Springs!',
      message:
          'Explore the power of magnets! 🧲 See how they attract and repel. Learn about springs too! Find Magnets & Springs under Science Interactive Games.',
      category: 'Science',
      color: const Color(0xFFE91E63),
      gameId: 'magnets-springs',
      gameName: 'Magnets & Springs',
      gameLocation: 'Science Interactive Games section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Play with Magnets',
      ageGroup: 'bright',
      gameType: 'web',
    ),
    // Math Games - Bright
    QuickMessage(
      id: 'multiplication-bright',
      emoji: '✖️',
      title: 'Master Multiplication!',
      message:
          'Become a multiplication master! ✖️ Practice your times tables and solve fun problems. Find Multiplication under Math Interactive Games.',
      category: 'Math',
      color: const Color(0xFF5B9BD5),
      gameId: 'multiplication',
      gameName: 'Multiplication',
      gameLocation: 'Math Interactive Games section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Play Multiplication',
      ageGroup: 'bright',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'fractions-bright',
      emoji: '🍕',
      title: 'Fraction Fun!',
      message:
          'Learn about fractions with fun activities! 🍕 Understand parts of a whole and how to compare fractions. Find Fractions under Math Interactive Games.',
      category: 'Math',
      color: const Color(0xFFE91E63),
      gameId: 'fractions',
      gameName: 'Fractions',
      gameLocation: 'Math Interactive Games section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Explore Fractions',
      ageGroup: 'bright',
      gameType: 'web',
    ),
    QuickMessage(
      id: 'decimals-bright',
      emoji: '🔢',
      title: 'Decimal Discovery!',
      message:
          'Master decimals and see how they work! 🔢 Learn to add, subtract, and compare decimal numbers. Find Decimals under Math Interactive Games.',
      category: 'Math',
      color: const Color(0xFF00BCD4),
      gameId: 'decimals',
      gameName: 'Decimals',
      gameLocation: 'Math Interactive Games section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Play with Decimals',
      ageGroup: 'bright',
      gameType: 'web',
    ),
    // Math Simulations - Bright
    QuickMessage(
      id: 'equality-explorer',
      emoji: '⚖️',
      title: 'Balance the Scale!',
      message:
          'Can you make both sides equal? ⚖️ Use the balance scale to solve equations and become a math champion! Find Equality Explorer under Math Simulations in your dashboard.',
      category: 'Math',
      color: const Color(0xFF5B9BD5),
      gameId: 'equality-explorer-basics',
      gameName: 'Equality Explorer',
      gameLocation: 'Math Simulations section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Balance the Scale',
      ageGroup: 'bright',
      gameType: 'simulation',
    ),
    QuickMessage(
      id: 'area-model',
      emoji: '📐',
      title: 'Shape Up with Area!',
      message:
          'Rectangles are everywhere! 📏 Learn how to find area using the Area Model - break numbers into parts and see multiplication come alive! Find it under Math Simulations.',
      category: 'Math',
      color: const Color(0xFFE91E63),
      gameId: 'area-model-introduction',
      gameName: 'Area Model Introduction',
      gameLocation: 'Math Simulations section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Try Area Model',
      ageGroup: 'bright',
      gameType: 'simulation',
    ),
    QuickMessage(
      id: 'mean-share',
      emoji: '📊',
      title: 'Find the Mean!',
      message:
          'What does "average" really mean? 🤔 Share and balance numbers to discover the mean - it\'s like making everything fair! Find Mean: Share and Balance under Math Simulations.',
      category: 'Math',
      color: const Color(0xFF00BCD4),
      gameId: 'mean-share-and-balance',
      gameName: 'Mean: Share and Balance',
      gameLocation: 'Math Simulations section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Explore the Mean',
      ageGroup: 'bright',
      gameType: 'simulation',
    ),
    // Science Simulations - Bright
    QuickMessage(
      id: 'states-of-matter',
      emoji: '💧',
      title: 'States of Matter Magic!',
      message:
          'Watch atoms dance! 💃 See how solids, liquids, and gases behave differently. Heat things up or cool them down - what happens? Find States of Matter under Science Simulations.',
      category: 'Simulation',
      color: const Color(0xFF00BCD4),
      gameId: 'states-of-matter',
      gameName: 'States of Matter',
      gameLocation: 'Science Simulations section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Explore States of Matter',
      ageGroup: 'bright',
      gameType: 'simulation',
    ),
    QuickMessage(
      id: 'static-electricity',
      emoji: '🎈',
      title: 'Balloon Science!',
      message:
          'Rub a balloon and watch the magic happen! ✨ Learn about static electricity and see charges push and pull! Find Balloons and Static Electricity under Science Simulations.',
      category: 'Simulation',
      color: const Color(0xFFFF5722),
      gameId: 'balloons-static-electricity',
      gameName: 'Balloons and Static Electricity',
      gameLocation: 'Science Simulations section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Play with Static',
      ageGroup: 'bright',
      gameType: 'simulation',
    ),
    QuickMessage(
      id: 'density',
      emoji: '🌊',
      title: 'Density Discovery!',
      message:
          'Why do some things float and others sink? 🌊 Explore density and see how it affects objects in water! Find Density under Science Simulations.',
      category: 'Simulation',
      color: const Color(0xFF2196F3),
      gameId: 'density',
      gameName: 'Density',
      gameLocation: 'Science Simulations section',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Explore Density',
      ageGroup: 'bright',
      gameType: 'simulation',
    ),
    // English/Reading
    QuickMessage(
      id: 'reading-time',
      emoji: '📚',
      title: 'Story Time!',
      message:
          'A new adventure awaits in the library! 📖 Pick a book, read along, and discover amazing stories. You can find books in the Reading section of your dashboard. What will you read today?',
      category: 'English',
      color: const Color(0xFF673AB7),
      gameId: 'books',
      gameName: 'Reading Corner',
      gameLocation: 'Books section',
      gameRoute: RouteNames.juniorDashboard,
      ctaLabel: 'Open Reading Corner',
      ageGroup: 'both',
      gameType: 'web',
    ),
    // Motivation & Wellbeing
    QuickMessage(
      id: 'daily-goal',
      emoji: '🎯',
      title: 'Daily Goal Reminder',
      message:
          'You\'re doing amazing! 🌟 Remember to complete your daily tasks and earn those coins. Every game counts! Check your progress at the top of your dashboard.',
      category: 'Motivation',
      color: const Color(0xFF4CAF50),
      gameId: null,
      gameName: null,
      gameLocation: null,
      gameRoute: null,
      ctaLabel: null,
      ageGroup: 'both',
    ),
    QuickMessage(
      id: 'wellbeing',
      emoji: '💖',
      title: 'Check-in Time',
      message:
          'How are you feeling today? 😊 Take a moment to share your mood in the Wellbeing Check. We care about how you\'re doing!',
      category: 'Wellbeing',
      color: const Color(0xFFE91E63),
      gameId: 'wellbeing',
      gameName: 'Wellbeing Check',
      gameLocation: 'Dashboard',
      gameRoute: RouteNames.brightDashboard,
      ctaLabel: 'Open Wellbeing Check',
      ageGroup: 'both',
    ),
    QuickMessage(
      id: 'explore-new',
      emoji: '🗺️',
      title: 'Try Something New!',
      message:
          'Adventure awaits! 🚀 Why not try a game you haven\'t played before? Scroll through your dashboard and pick something new. You might discover your new favorite!',
      category: 'Motivation',
      color: const Color(0xFF9C27B0),
      gameId: null,
      gameName: null,
      gameLocation: null,
      gameRoute: null,
      ctaLabel: null,
      ageGroup: 'both',
    ),
  ];

  String _selectedCategory = 'All';

  // Mock student messages/questions
  final List<StudentMessage> _mockStudentMessages = [
    StudentMessage(
      id: 'mock-student-1',
      studentName: 'Emma',
      studentAvatar: ':)',
      ageGroup: 'bright',
      question:
          "Ms. Johnson, I don't understand how the food chain works. Can animals be in more than one food chain?",
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      relatedGame: 'Food Chains',
      childId: 'mock-child-1',
      inboxMessageId: 'mock-inbox-1',
    ),
    StudentMessage(
      id: 'mock-student-2',
      studentName: 'Liam',
      studentAvatar: ':)',
      ageGroup: 'bright',
      question:
          "How do I balance the equation in the scale game? I keep getting it wrong?",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      relatedGame: 'Equality Explorer',
      childId: 'mock-child-2',
      inboxMessageId: 'mock-inbox-2',
    ),
    StudentMessage(
      id: 'mock-student-3',
      studentName: 'Sophia',
      studentAvatar: ':)',
      ageGroup: 'bright',
      question:
          "The States of Matter simulation is so cool! But why do the atoms move faster when it's hot?",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      relatedGame: 'States of Matter',
      childId: 'mock-child-3',
      inboxMessageId: 'mock-inbox-3',
    ),
    StudentMessage(
      id: 'mock-student-4',
      studentName: 'Noah',
      studentAvatar: ':)',
      ageGroup: 'bright',
      question: "I finished all the math games! What should I try next?",
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      relatedGame: null,
      childId: 'mock-child-4',
      inboxMessageId: 'mock-inbox-4',
    ),
    StudentMessage(
      id: 'mock-student-5',
      studentName: 'Olivia',
      studentAvatar: ':)',
      ageGroup: 'bright',
      question:
          "Can you explain what happens to water when it freezes? I saw it in the simulation but want to understand more?",
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
      relatedGame: 'States of Matter',
      childId: 'mock-child-5',
      inboxMessageId: 'mock-inbox-5',
    ),
  ];
  List<StudentMessage> _studentMessages = [];
  List<TeacherBroadcastMessage> _recentBroadcasts = [];
  List<TeacherInboxMessage> _recentTeacherReplies = []; // Track private replies to students

  final List<Map<String, String>> _mockSentMessages = [
    {
      'message': 'dYZ% Great job on your math practice today!',
      'time': '2 hours ago',
      'group': 'Bright',
    },
    {
      'message': 'dY"s Don\'t forget to check out the new books!',
      'time': 'Yesterday',
      'group': 'Junior',
    },
    {
      'message': '?-? Keep up the amazing work everyone!',
      'time': '2 days ago',
      'group': 'Bright',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
    _messagingService = MessagingService();
    _studentMessages = List<StudentMessage>.from(_mockStudentMessages);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _subscribeToInbox();
      _subscribeToSentHistory();
    });
  }

  @override
  void dispose() {
    _inboxSubscription?.cancel();
    _sentSubscription?.cancel();
    _tabController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  List<QuickMessage> get _filteredMessages {
    var messages = _quickMessages;
    
    // Filter by age group
    messages = messages.where((m) {
      // Include messages that match the selected age group or are for both
      final matchesAgeGroup = m.ageGroup == _selectedAgeGroup || m.ageGroup == 'both';
      
      // When Junior is selected, exclude simulation games
      if (_selectedAgeGroup == 'junior' && m.gameType == 'simulation') {
        return false;
      }
      
      return matchesAgeGroup;
    }).toList();
    
    // Filter by category if not 'All'
    if (_selectedCategory != 'All') {
      messages = messages
          .where((m) => m.category == _selectedCategory)
          .toList();
    }
    
    return messages;
  }

  void _subscribeToInbox() {
    final auth = context.read<AuthProvider>();
    final teacherId = auth.currentUser?.id;
    if (teacherId == null) {
      debugPrint('TeacherMessagingScreen: Missing teacher ID for inbox stream');
      return;
    }

    _inboxSubscription?.cancel();
    _inboxSubscription = _messagingService
        .listenToTeacherInbox(teacherId: teacherId)
        .listen((messages) {
      final firebaseMessages =
          messages.map(_mapInboxMessage).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _studentMessages = [
          ...firebaseMessages,
          ..._mockStudentMessages,
        ];
      });
    }, onError: (error) {
      debugPrint('Teacher inbox stream error: $error');
    });
  }

  void _subscribeToSentHistory() {
    final auth = context.read<AuthProvider>();
    final teacherId = auth.currentUser?.id;
    if (teacherId == null) {
      debugPrint(
          'TeacherMessagingScreen: Missing teacher ID for history stream');
      return;
    }

    _sentSubscription?.cancel();
    _sentSubscription = _messagingService
        .listenToTeacherBroadcasts(teacherId: teacherId, limit: 5)
        .listen((messages) {
      if (!mounted) return;
      setState(() {
        _recentBroadcasts = messages;
      });
    }, onError: (error) {
      debugPrint('Teacher history stream error: $error');
    });
  }

  Future<void> _refreshInbox() async {
    final auth = context.read<AuthProvider>();
    final teacherId = auth.currentUser?.id;
    if (teacherId == null) {
      return;
    }

    try {
      final messages = await _messagingService.fetchTeacherInboxOnce(
        teacherId: teacherId,
        limit: 40,
      );
      final firebaseMessages =
          messages.map(_mapInboxMessage).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _studentMessages = [
          ...firebaseMessages,
          ..._mockStudentMessages,
        ];
      });
    } catch (error, stackTrace) {
      debugPrint('Teacher inbox refresh error: $error');
      debugPrint('$stackTrace');
      if (mounted) {
        _showSnack(
          'Unable to refresh inbox. Please try again.',
          SafePlayColors.error,
        );
      }
    }
  }

  StudentMessage _mapInboxMessage(TeacherInboxMessage message) {
    return StudentMessage(
      id: message.id,
      studentName: message.childName,
      studentAvatar: message.childAvatar ?? ':)',
      ageGroup: message.ageGroup.name,
      question: message.body,
      timestamp: message.createdAt,
      isRead: message.isRead,
      relatedGame: message.relatedGame,
      childId: message.childId,
      inboxMessageId: message.id,
    );
  }

  void _showSnack(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<bool> _sendBroadcast(QuickMessage? quickMessage) async {
    final auth = context.read<AuthProvider>();
    final teacher = auth.currentUser;

    if (teacher == null) {
      _showSnack(
          'Please sign in as a teacher to send messages', SafePlayColors.error);
      return false;
    }

    final body =
        (quickMessage?.message ?? _customMessageController.text).trim();
    if (body.isEmpty) {
      _showSnack('Please write a message first', SafePlayColors.warning);
      return false;
    }

    final targetAgeGroup =
        _selectedAgeGroup == 'junior' ? AgeGroup.junior : AgeGroup.bright;
    final title = quickMessage?.title ?? 'Message from ${teacher.name}';
    final emoji = quickMessage?.emoji ?? '✉️';
    final category = quickMessage?.category ?? 'Announcement';
    final color = quickMessage?.color ??
        (targetAgeGroup == AgeGroup.junior
            ? SafePlayColors.juniorPurple
            : SafePlayColors.brightIndigo);

    setState(() => _sendingBroadcast = true);
    try {
      await _messagingService.sendBroadcast(
        teacherId: teacher.id,
        teacherName: teacher.name,
        teacherAvatar: teacher.avatarUrl,
        audience: targetAgeGroup,
        title: title,
        body: body,
        emoji: emoji,
        category: category,
        color: color,
        quickMessageId: quickMessage?.id,
        gameId: quickMessage?.gameId,
        gameName: quickMessage?.gameName,
        gameRoute: quickMessage?.gameRoute,
        gameLocation: quickMessage?.gameLocation,
        ctaLabel: quickMessage?.ctaLabel,
        gameType: quickMessage?.gameType,
      );
      if (quickMessage == null) {
        _customMessageController.clear();
      }
      return true;
    } catch (error, stackTrace) {
      debugPrint('Teacher broadcast send error: $error');
      debugPrint('$stackTrace');
      _showSnack(
          'Unable to send message. Please try again.', SafePlayColors.error);
      return false;
    } finally {
      if (mounted) {
        setState(() => _sendingBroadcast = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildAgeGroupSelector(),
          if (_currentTabIndex == 0) _buildCategoryFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuickMessagesTab(),
                _buildCustomMessageTab(),
                _buildStudentMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SafePlayColors.brandTeal500,
            SafePlayColors.brandTeal500.withOpacity(0.85),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.campaign_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Broadcast Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Send friendly nudges to your students',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: SafePlayColors.brandTeal500,
              unselectedLabelColor: Colors.white,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: [
                const Tab(text: '✨ Quick'),
                const Tab(text: '✏️ Custom'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📩 Inbox'),
                      if (_studentMessages
                          .where((m) => !m.isRead)
                          .isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: SafePlayColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_studentMessages.where((m) => !m.isRead).length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAgeGroupButton(
              'junior',
              'Junior (6-8)',
              '👶',
              SafePlayColors.juniorPurple,
            ),
          ),
          Expanded(
            child: _buildAgeGroupButton(
              'bright',
              'Bright (9-12)',
              '🧒',
              SafePlayColors.brightIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupButton(
      String value, String label, String emoji, Color color) {
    final isSelected = _selectedAgeGroup == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedAgeGroup = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : SafePlayColors.neutral600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'All',
      'Science',
      'Math',
      'English',
      'Simulation',
      'Motivation',
      'Wellbeing'
    ];
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(category),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : SafePlayColors.neutral700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              selectedColor: SafePlayColors.brandTeal500,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? SafePlayColors.brandTeal500
                    : SafePlayColors.neutral200,
              ),
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickMessagesTab() {
    final messages = _filteredMessages;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _buildQuickMessageCard(messages[index]);
      },
    );
  }

  Widget _buildQuickMessageCard(QuickMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMessagePreview(message),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: message.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(message.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: message.color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: message.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              message.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: message.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.send_rounded, color: message.color, size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  message.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: SafePlayColors.neutral600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.gameName != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: SafePlayColors.neutral50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SafePlayColors.neutral200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.videogame_asset_outlined,
                            size: 14, color: SafePlayColors.neutral500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${message.gameName} - ${message.gameLocation ?? 'Dashboard'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: SafePlayColors.neutral600,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  Widget _buildCustomMessageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SafePlayColors.brandTeal500.withOpacity(0.1),
                  SafePlayColors.brandTeal200.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: SafePlayColors.brandTeal500.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SafePlayColors.brandTeal500.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.info_outline,
                      color: SafePlayColors.brandTeal500, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Your Own Message',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: SafePlayColors.brandTeal500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Write a custom message to send to all ${_selectedAgeGroup == 'junior' ? 'Junior' : 'Bright'} students.',
                        style: TextStyle(
                          color: SafePlayColors.neutral600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Message input
          Text(
            'Your Message',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: SafePlayColors.neutral900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _customMessageController,
              maxLines: 6,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    'Write a friendly message for your students...\n\nTip: Use emojis to make it fun! :-)',
                hintStyle: TextStyle(color: SafePlayColors.neutral400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick emoji buttons
          Text(
            'Add Emojis',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: SafePlayColors.neutral700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '🎉',
              '⭐',
              '🚀',
              '💪',
              '🎯',
              '📚',
              '🧠',
              '💡',
              '🌟',
              '👏',
              '🎮',
              '🏆'
            ].map((emoji) => _buildEmojiButton(emoji)).toList(),
          ),
          const SizedBox(height: 24),

          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _sendingBroadcast ? null : () => _showSendConfirmation(null),
              icon: _sendingBroadcast
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(
                'Send to All ${_selectedAgeGroup == 'junior' ? 'Junior' : 'Bright'} Students',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedAgeGroup == 'junior'
                    ? SafePlayColors.juniorPurple
                    : SafePlayColors.brightIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Sent messages history (mock)
          _buildSentMessagesSection(),
        ],
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return InkWell(
      onTap: () {
        final text = _customMessageController.text;
        final selection = _customMessageController.selection;
        final start = selection.start >= 0 ? selection.start : text.length;
        final end = selection.end >= 0 ? selection.end : text.length;
        final newText = text.replaceRange(
          start,
          end,
          emoji,
        );
        final newOffset = start + emoji.length;
        _customMessageController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newOffset),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SafePlayColors.neutral200),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildSentMessagesSection() {
    final sentMessages = <Map<String, dynamic>>[];
    
    // Broadcast messages
    for (final msg in _recentBroadcasts) {
      sentMessages.add({
        'message': msg.message,
        'time': _formatTimestamp(msg.createdAt),
        'timestamp': msg.createdAt.millisecondsSinceEpoch,
        'group': msg.audience == AgeGroup.junior ? 'Junior' : 'Bright',
        'type': 'broadcast',
      });
    }
    
    // Private replies to students
    for (final msg in _recentTeacherReplies) {
      sentMessages.add({
        'message': msg.body,
        'time': _formatTimestamp(msg.createdAt),
        'timestamp': msg.createdAt.millisecondsSinceEpoch,
        'group': 'To ${msg.childName}',
        'type': 'private',
      });
    }
    
    // Add mock messages (they don't have timestamps, so add them at the end)
    for (final msg in _mockSentMessages) {
      sentMessages.add({
        'message': msg['message'],
        'time': msg['time'],
        'timestamp': 0, // Mock messages go to the end
        'group': msg['group'],
        'type': 'mock',
      });
    }
    
    // Sort by timestamp (most recent first)
    sentMessages.sort((a, b) {
      final timestampA = a['timestamp'] as int;
      final timestampB = b['timestamp'] as int;
      return timestampB.compareTo(timestampA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: SafePlayColors.neutral500, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recently Sent',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: SafePlayColors.neutral700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sentMessages.map((msg) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SafePlayColors.neutral100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['message'] ?? '',
                          style: TextStyle(
                            color: SafePlayColors.neutral700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: msg['group'] == 'Junior'
                                    ? SafePlayColors.juniorPurple
                                        .withOpacity(0.1)
                                    : SafePlayColors.brightIndigo
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                msg['group'] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: msg['group'] == 'Junior'
                                      ? SafePlayColors.juniorPurple
                                      : SafePlayColors.brightIndigo,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              msg['time'] ?? '',
                              style: TextStyle(
                                color: SafePlayColors.neutral400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle,
                      color: SafePlayColors.success, size: 20),
                ],
              ),
            )),
      ],
    );
  }

  void _showMessagePreview(QuickMessage message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SafePlayColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: message.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(message.emoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: message.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: message.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              message.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: message.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Message preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SafePlayColors.neutral50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SafePlayColors.neutral100),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  fontSize: 15,
                  color: SafePlayColors.neutral700,
                  height: 1.5,
                ),
              ),
            ),
            if (message.gameName != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.videogame_asset_outlined,
                      size: 20, color: SafePlayColors.neutral500),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.gameName!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.gameLocation ?? 'Dashboard shortcut',
                          style: TextStyle(
                            fontSize: 13,
                            color: SafePlayColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            // Target info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_selectedAgeGroup == 'junior'
                        ? SafePlayColors.juniorPurple
                        : SafePlayColors.brightIndigo)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.group,
                    color: _selectedAgeGroup == 'junior'
                        ? SafePlayColors.juniorPurple
                        : SafePlayColors.brightIndigo,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This message will be sent to all ${_selectedAgeGroup == 'junior' ? 'Junior (6-8)' : 'Bright (9-12)'} students',
                      style: TextStyle(
                        color: _selectedAgeGroup == 'junior'
                            ? SafePlayColors.juniorPurple
                            : SafePlayColors.brightIndigo,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendingBroadcast
                    ? null
                    : () {
                        Navigator.pop(context);
                        _showSendConfirmation(message);
                      },
                icon: _sendingBroadcast
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
                label: Text(
                  _sendingBroadcast ? 'Sending...' : 'Send Message',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: message.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showSendConfirmation(QuickMessage? message) async {
    final messageText =
        (message?.message ?? _customMessageController.text).trim();
    if (messageText.isEmpty) {
      _showSnack('Please write a message first', SafePlayColors.warning);
      return;
    }

    final sent = await _sendBroadcast(message);
    if (!sent || !mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: SafePlayColors.success, size: 28),
            const SizedBox(width: 12),
            const Text('Message Sent!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your message has been sent to all ${_selectedAgeGroup == 'junior' ? 'Junior' : 'Bright'} students.',
              style: TextStyle(color: SafePlayColors.neutral600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SafePlayColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('📨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Students will see this message when they open the app.',
                      style: TextStyle(
                        color: SafePlayColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: SafePlayColors.brandTeal500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentMessagesTab() {
    final unreadCount = _studentMessages.where((m) => !m.isRead).length;

    return Column(
      children: [
        // Header info
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SafePlayColors.brightIndigo.withOpacity(0.1),
                SafePlayColors.brightIndigo.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: SafePlayColors.brightIndigo.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SafePlayColors.brightIndigo.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.school_rounded,
                    color: SafePlayColors.brightIndigo, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Questions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: SafePlayColors.brightIndigo,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unreadCount > 0
                          ? '$unreadCount new question${unreadCount > 1 ? 's' : ''} from Bright students'
                          : 'Questions from Bright students appear here',
                      style: TextStyle(
                        color: SafePlayColors.neutral600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: SafePlayColors.brightIndigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount NEW',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Messages list
        Expanded(
          child: _studentMessages.isEmpty
              ? _buildEmptyStudentMessages()
              : RefreshIndicator(
                  onRefresh: _refreshInbox,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _studentMessages.length,
                    itemBuilder: (context, index) {
                      return _buildStudentMessageCard(_studentMessages[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyStudentMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: SafePlayColors.brightIndigo.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(':)', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No student questions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: SafePlayColors.neutral700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When Bright students send you questions,\n'
            'they will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: SafePlayColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentMessageCard(StudentMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: message.isRead
            ? null
            : Border.all(color: SafePlayColors.brightIndigo, width: 2),
        boxShadow: [
          BoxShadow(
            color: message.isRead
                ? Colors.black.withOpacity(0.05)
                : SafePlayColors.brightIndigo.withOpacity(0.15),
            blurRadius: message.isRead ? 10 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStudentMessageDetail(message),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Student avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            SafePlayColors.brightIndigo,
                            SafePlayColors.brightIndigo.withOpacity(0.7)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(message.studentAvatar,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                message.studentName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: SafePlayColors.neutral900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: SafePlayColors.brightIndigo
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Bright',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: SafePlayColors.brightIndigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTimestamp(message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: SafePlayColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!message.isRead)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: SafePlayColors.brightIndigo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Question text
                Text(
                  message.question,
                  style: TextStyle(
                    fontSize: 14,
                    color: SafePlayColors.neutral700,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.relatedGame != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: SafePlayColors.neutral50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SafePlayColors.neutral200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.games_outlined,
                            size: 14, color: SafePlayColors.neutral500),
                        const SizedBox(width: 6),
                        Text(
                          'Related to: ${message.relatedGame}',
                          style: TextStyle(
                            fontSize: 11,
                            color: SafePlayColors.neutral600,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  void _showStudentMessageDetail(StudentMessage message) {
    // Mark as read
    setState(() {
      final index = _studentMessages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _studentMessages[index] = StudentMessage(
          id: message.id,
          studentName: message.studentName,
          studentAvatar: message.studentAvatar,
          ageGroup: message.ageGroup,
          question: message.question,
          timestamp: message.timestamp,
          isRead: true,
          relatedGame: message.relatedGame,
          childId: message.childId,
          inboxMessageId: message.inboxMessageId,
        );
      }
    });
    if (!message.id.startsWith('mock-')) {
      _messagingService.markInboxMessageRead(message.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SafePlayColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Student info header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SafePlayColors.brightIndigo,
                        SafePlayColors.brightIndigo.withOpacity(0.7)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: SafePlayColors.brightIndigo.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(message.studentAvatar,
                        style: const TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.studentName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: SafePlayColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  SafePlayColors.brightIndigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Bright Student',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: SafePlayColors.brightIndigo,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimestamp(message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: SafePlayColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SafePlayColors.brightIndigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: SafePlayColors.brightIndigo.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline,
                          size: 18, color: SafePlayColors.brightIndigo),
                      const SizedBox(width: 8),
                      Text(
                        'Student\'s Question',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: SafePlayColors.brightIndigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message.question,
                    style: TextStyle(
                      fontSize: 15,
                      color: SafePlayColors.neutral700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (message.relatedGame != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SafePlayColors.neutral50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.games_rounded,
                        size: 20, color: SafePlayColors.neutral600),
                    const SizedBox(width: 10),
                    Text(
                      'Related to: ${message.relatedGame}',
                      style: TextStyle(
                        fontSize: 13,
                        color: SafePlayColors.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Reply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showReplyDialog(message);
                },
                icon: const Icon(Icons.reply_rounded, color: Colors.white),
                label: const Text(
                  'Reply to Student',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SafePlayColors.brightIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(StudentMessage message) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: SafePlayColors.brightIndigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(message.studentAvatar,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reply to',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal)),
                  Text(message.studentName,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: replyController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SafePlayColors.neutral200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: SafePlayColors.brightIndigo, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Quick replies
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickReplyChip('Great question! 👍', replyController),
                _buildQuickReplyChip('Let me explain... 📚', replyController),
                _buildQuickReplyChip('Try the game again! 🎮', replyController),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: SafePlayColors.neutral500)),
          ),
          ElevatedButton(
            onPressed: () async {
              final replyText = replyController.text.trim();
              if (replyText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a reply message'),
                    backgroundColor: SafePlayColors.warning,
                  ),
                );
                return;
              }

              final auth = context.read<AuthProvider>();
              final teacher = auth.currentUser;
              if (teacher == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please sign in as a teacher'),
                    backgroundColor: SafePlayColors.error,
                  ),
                );
                return;
              }

              try {
                final ageGroup = AgeGroup.fromString(message.ageGroup) ?? AgeGroup.bright;
                await _messagingService.sendTeacherReply(
                  teacherId: teacher.id,
                  teacherName: teacher.name,
                  childId: message.childId,
                  childName: message.studentName,
                  ageGroup: ageGroup,
                  message: replyText,
                  teacherAvatar: teacher.avatarUrl,
                  childAvatar: message.studentAvatar,
                  relatedInboxMessageId: message.inboxMessageId,
                );

                // Add to recent replies for "Recently Sent" section
                if (context.mounted) {
                  setState(() {
                    _recentTeacherReplies.insert(0, TeacherInboxMessage(
                      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
                      teacherId: teacher.id,
                      teacherName: teacher.name,
                      teacherAvatar: teacher.avatarUrl,
                      childId: message.childId,
                      childName: message.studentName,
                      childAvatar: message.studentAvatar,
                      ageGroup: ageGroup,
                      body: replyText,
                      createdAt: DateTime.now(),
                      isRead: false,
                      relatedBroadcastId: message.inboxMessageId,
                    ));
                    // Keep only the last 10 replies
                    if (_recentTeacherReplies.length > 10) {
                      _recentTeacherReplies = _recentTeacherReplies.take(10).toList();
                    }
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('Reply sent to ${message.studentName}!'),
                        ],
                      ),
                      backgroundColor: SafePlayColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send reply: ${e.toString()}'),
                      backgroundColor: SafePlayColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.brightIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChip(String text, TextEditingController controller) {
    return InkWell(
      onTap: () {
        controller.text = text;
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: SafePlayColors.brightIndigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: SafePlayColors.brightIndigo.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: SafePlayColors.brightIndigo,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class QuickMessage {
  final String id;
  final String emoji;
  final String title;
  final String message;
  final String category;
  final Color color;
  final String? gameId;
  final String? gameName;
  final String? gameLocation;
  final String? gameRoute;
  final String? ctaLabel;
  final String? ageGroup; // 'junior', 'bright', or 'both'
  final String? gameType; // 'web' or 'simulation'

  const QuickMessage({
    required this.id,
    required this.emoji,
    required this.title,
    required this.message,
    required this.category,
    required this.color,
    this.gameId,
    this.gameName,
    this.gameLocation,
    this.gameRoute,
    this.ctaLabel,
    this.ageGroup,
    this.gameType,
  });
}

class StudentMessage {
  final String id;
  final String studentName;
  final String studentAvatar;
  final String ageGroup;
  final String question;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedGame;
  final String childId;
  final String inboxMessageId;

  const StudentMessage({
    required this.id,
    required this.studentName,
    required this.studentAvatar,
    required this.ageGroup,
    required this.question,
    required this.timestamp,
    required this.isRead,
    required this.childId,
    required this.inboxMessageId,
    this.relatedGame,
  });
}
