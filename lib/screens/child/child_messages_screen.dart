import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../design_system/junior_theme.dart';
import '../../models/teacher_broadcast_message.dart';
import '../../models/user_type.dart';
import '../../services/messaging_service.dart';

/// Child Messages Screen - Receives broadcast messages from teachers (read-only)
class ChildMessagesScreen extends StatefulWidget {
  const ChildMessagesScreen({super.key});

  @override
  State<ChildMessagesScreen> createState() => _ChildMessagesScreenState();
}

class _ChildMessagesScreenState extends State<ChildMessagesScreen> {
  late final MessagingService _messagingService;
  StreamSubscription<List<TeacherBroadcastMessage>>? _subscription;

  // Mock messages from teachers with game links
  final List<TeacherMessage> _mockMessages = [
    TeacherMessage(
      id: '1',
      emoji: '🌳',
      title: 'Explore Food Chains!',
      message:
          'Hey explorers! 🌿 Ready to discover who eats what in nature? Open the Food Chains game and learn about animals, plants, and how they all connect! You can find it under Science Interactive Games in your dashboard.',
      teacherName: 'Ms. Johnson',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Science',
      color: const Color(0xFF4CAF50),
      isNew: true,
      gameId: 'food-chains',
      gameName: 'Food Chains',
      gameLocation: 'Science Interactive Games',
      ctaLabel: 'Play Food Chains',
    ),
    TeacherMessage(
      id: '2',
      emoji: '🦠',
      title: 'Tiny World Adventure!',
      message:
          'Did you know there are living things too small to see? 🔬 Explore the world of microorganisms - bacteria, fungi, and algae are waiting for you! Find this game under Science Interactive Games.',
      teacherName: 'Mr. Smith',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: 'Science',
      color: const Color(0xFF9C27B0),
      isNew: true,
      gameId: 'microorganisms',
      gameName: 'Microorganisms',
      gameLocation: 'Science Interactive Games',
      ctaLabel: 'Explore Microorganisms',
    ),
    TeacherMessage(
      id: '3',
      emoji: '🎯',
      title: 'Daily Goal Reminder',
      message:
          'You\'re doing amazing! 🌟 Remember to complete your daily tasks and earn those coins. Every game counts! Check your progress at the top of your dashboard.',
      teacherName: 'Ms. Johnson',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Motivation',
      color: const Color(0xFF4CAF50),
      isNew: false,
    ),
    TeacherMessage(
      id: '4',
      emoji: '🏃',
      title: 'Stay Healthy & Strong!',
      message:
          'Learn how your body needs water, food, exercise and rest to stay healthy! 💪 Help Ben live a healthy life in the Human Body Health & Growth game. Find it in Science Interactive Games.',
      teacherName: 'Mr. Smith',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      category: 'Science',
      color: const Color(0xFFE91E63),
      isNew: false,
      gameId: 'health-growth',
      gameName: 'Human Body Health & Growth',
      gameLocation: 'Science Interactive Games',
      ctaLabel: 'Play Health & Growth',
    ),
    TeacherMessage(
      id: '5',
      emoji: '📚',
      title: 'Story Time!',
      message:
          'A new adventure awaits in the library! 📖 Pick a book, read along, and discover amazing stories. You can find books in the Reading section of your dashboard. What will you read today?',
      teacherName: 'Ms. Johnson',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      category: 'English',
      color: const Color(0xFF673AB7),
      isNew: false,
      gameId: 'books',
      gameName: 'Reading Corner',
      gameLocation: 'Books section',
      ctaLabel: 'Open Reading Corner',
    ),
    TeacherMessage(
      id: '6',
      emoji: '💖',
      title: 'Check-in Time',
      message:
          'How are you feeling today? 😊 Take a moment to share your mood in the Wellbeing Check. We care about how you\'re doing!',
      teacherName: 'Mr. Smith',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      category: 'Wellbeing',
      color: const Color(0xFFE91E63),
      isNew: false,
    ),
  ];
  List<TeacherMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messagingService = MessagingService();
    _messages = List<TeacherMessage>.from(_mockMessages);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _subscribeToBroadcasts();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToBroadcasts() {
    _subscription?.cancel();
    _subscription = _messagingService
        .listenToBroadcasts(audience: AgeGroup.junior, limit: 25)
        .listen((messages) {
      final firebaseMessages =
          messages.map(_mapBroadcastToTeacherMessage).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _messages = [
          ...firebaseMessages,
          ..._mockMessages,
        ];
      });
    }, onError: (error) {
      debugPrint('ChildMessagesScreen stream error: $error');
    });
  }

  TeacherMessage _mapBroadcastToTeacherMessage(
      TeacherBroadcastMessage message) {
    final isNew = DateTime.now().difference(message.createdAt) <=
        const Duration(hours: 24);
    return TeacherMessage(
      id: message.id,
      emoji: message.emoji,
      title: message.title,
      message: message.message,
      teacherName: message.teacherName,
      timestamp: message.createdAt,
      category: message.category,
      color: message.color,
      isNew: isNew,
    );
  }

  @override
  Widget build(BuildContext context) {
    final newMessagesCount = _messages.where((m) => m.isNew).length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JuniorTheme.primaryPurple.withOpacity(0.1),
            JuniorTheme.backgroundLight,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(newMessagesCount),
            Expanded(
              child:
                  _messages.isEmpty ? _buildEmptyState() : _buildMessagesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int newCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      JuniorTheme.primaryPurple,
                      JuniorTheme.primaryPink
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: JuniorTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('📬', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messages from Teachers',
                      style: JuniorTheme.headingMedium.copyWith(
                        color: JuniorTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (newCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: JuniorTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$newCount new message${newCount > 1 ? 's' : ''}! ✨',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Check what your teachers sent you!',
                        style: TextStyle(
                          color: SafePlayColors.neutral500,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: JuniorTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('📭', style: TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No messages yet!',
              style: JuniorTheme.headingMedium.copyWith(
                color: JuniorTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your teachers will send you fun\nmessages and reminders here! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: SafePlayColors.neutral500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageCard(message, index);
      },
    );
  }

  Widget _buildMessageCard(TeacherMessage message, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showMessageDetail(message),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: message.isNew
                ? Border.all(color: message.color, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: message.isNew
                    ? message.color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: message.isNew ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Emoji icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: message.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(message.emoji,
                                style: const TextStyle(fontSize: 26)),
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
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: message.color.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('👩‍🏫',
                                          style: TextStyle(fontSize: 10)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    message.teacherName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: SafePlayColors.neutral500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: SafePlayColors.neutral300,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTimestamp(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: SafePlayColors.neutral400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                    const SizedBox(height: 12),
                    // Category tag and game button indicator
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: message.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
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
                        if (message.gameId != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: message.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Game',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          'Tap to read more',
                          style: TextStyle(
                            fontSize: 11,
                            color: SafePlayColors.neutral400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: SafePlayColors.neutral400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // New badge
              if (message.isNew)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: JuniorTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: JuniorTheme.primaryOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('✨', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 4),
                        Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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

  void _showMessageDetail(TeacherMessage message) {
    // Mark as read
    setState(() {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = TeacherMessage(
          id: message.id,
          emoji: message.emoji,
          title: message.title,
          message: message.message,
          teacherName: message.teacherName,
          timestamp: message.timestamp,
          category: message.category,
          color: message.color,
          isNew: false,
        );
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: message.color.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
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
            const SizedBox(height: 24),

            // Header with emoji
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [message.color, message.color.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: message.color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(message.emoji,
                        style: const TextStyle(fontSize: 32)),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: message.color,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                                fontSize: 11,
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

            // Teacher info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SafePlayColors.neutral50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: message.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getTeacherInitial(message.teacherName),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: message.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From ${message.teacherName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: TextStyle(
                          color: SafePlayColors.neutral500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Full message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: message.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: message.color.withOpacity(0.2)),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  fontSize: 16,
                  color: SafePlayColors.neutral700,
                  height: 1.6,
                ),
              ),
            ),
            
            // Game button if available
            if (message.gameId != null && message.ctaLabel != null) ...[
              const SizedBox(height: 16),
              _buildGameButton(message),
            ],
            
            const SizedBox(height: 20),

            // Fun response (no actual reply, just acknowledgment)
            Row(
              children: [
                Expanded(
                  child: _buildReactionButton('👍', 'Got it!', message.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReactionButton(
                      '🎉', 'Yay!', JuniorTheme.primaryOrange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReactionButton(
                      '❤️', 'Love it!', JuniorTheme.primaryPink),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(TeacherMessage message) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // Show snackbar indicating game would open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(message.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Opening ${message.gameName}...',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: message.color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        // TODO: Navigate to the actual game when integrated
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [message.color, message.color.withOpacity(0.8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: message.color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              message.ctaLabel!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji, String label, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('You reacted with "$label"'),
                ],
              ),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
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

  String _getTeacherInitial(String name) {
    if (name.isEmpty) return 'T';
    return name[0].toUpperCase();
  }
}

class TeacherMessage {
  final String id;
  final String emoji;
  final String title;
  final String message;
  final String teacherName;
  final DateTime timestamp;
  final String category;
  final Color color;
  final bool isNew;
  final String? gameId;
  final String? gameName;
  final String? gameLocation;
  final String? ctaLabel;

  const TeacherMessage({
    required this.id,
    required this.emoji,
    required this.title,
    required this.message,
    required this.teacherName,
    required this.timestamp,
    required this.category,
    required this.color,
    required this.isNew,
    this.gameId,
    this.gameName,
    this.gameLocation,
    this.ctaLabel,
  });
}
