import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../design_system/junior_theme.dart';
import '../../models/child_profile.dart';
import '../../models/teacher_broadcast_message.dart';
import '../../models/teacher_inbox_message.dart';
import '../../models/user_type.dart';
import '../../providers/auth_provider.dart';
import '../../services/messaging_service.dart';
import '../../services/game_navigation_service.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _mockMessages = [
    {
      'text': 'Hello! How are you finding the new science module?',
      'isMe': false,
      'time': '10:00 AM',
      'senderName': 'Ms. Sarah',
    },
    {
      'text': 'It\'s really fun! I liked the space simulation.',
      'isMe': true,
      'time': '10:05 AM',
      'senderName': 'You',
    },
    {
      'text':
          'That\'s great to hear! Try the States of Matter simulation next - you can watch atoms dance! 💃 Find it under Science Simulations in your dashboard.',
      'isMe': false,
      'time': '10:06 AM',
      'senderName': 'Ms. Sarah',
      'gameId': 'states-of-matter',
      'gameName': 'States of Matter',
      'ctaLabel': 'Explore States of Matter',
      'emoji': '💧',
      'gameType': 'simulation',
    },
  ];
  List<Map<String, dynamic>> _messages = [];

  // Mock conversations list
  final List<Map<String, dynamic>> _mockConversations = [
    {
      'name': 'Ms. Sarah',
      'avatar': '👩‍🏫',
      'lastMessage': 'Remember to check the safety guidelines...',
      'time': '10:06 AM',
      'unread': 0,
      'online': true,
    },
    {
      'name': 'Mr. Johnson',
      'avatar': '👨‍🏫',
      'lastMessage': 'Great work on your math quiz!',
      'time': 'Yesterday',
      'unread': 2,
      'online': false,
    },
    {
      'name': 'Ms. Chen',
      'avatar': '👩‍💼',
      'lastMessage': 'Don\'t forget about tomorrow\'s class',
      'time': 'Mon',
      'unread': 0,
      'online': true,
    },
  ];
  List<Map<String, dynamic>> _conversations = [];

  late final MessagingService _messagingService;
  StreamSubscription<List<TeacherBroadcastMessage>>? _broadcastSubscription;
  StreamSubscription<List<TeacherInboxMessage>>? _replySubscription;
  ChildProfile? _childProfile;
  List<TeacherBroadcastMessage> _broadcastMessages = [];
  List<TeacherInboxMessage> _childReplies = [];
  bool _isFirebaseConversation = false;
  String? _activeTeacherId;
  String? _activeTeacherName;
  bool _sendingReply = false;

  bool _showConversationList = true;
  int _selectedConversation = 0;
  int _selectedMockIndex = 0;

  @override
  void initState() {
    super.initState();
    _messagingService = MessagingService();
    _messages = List<Map<String, dynamic>>.from(_mockMessages);
    _conversations = List<Map<String, dynamic>>.from(_mockConversations);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadChildProfile();
      _subscribeToBroadcasts();
    });
  }

  @override
  void dispose() {
    _broadcastSubscription?.cancel();
    _replySubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChildProfile() {
    final auth = context.read<AuthProvider>();
    ChildProfile? child;
    final currentUser = auth.currentUser;
    final currentChild = auth.currentChild;

    if (currentUser is ChildProfile &&
        currentUser.ageGroup == AgeGroup.bright) {
      child = currentUser;
    } else if (currentChild != null &&
        currentChild.ageGroup == AgeGroup.bright) {
      child = currentChild;
    }

    setState(() => _childProfile = child);
    if (child != null) {
      _listenToReplies(child.id);
    }
  }

  void _subscribeToBroadcasts() {
    _broadcastSubscription?.cancel();
    _broadcastSubscription = _messagingService
        .listenToBroadcasts(audience: AgeGroup.bright, limit: 25)
        .listen((messages) {
      if (!mounted) return;
      _broadcastMessages = messages;
      _refreshConversations();
      if (_isFirebaseConversation) {
        _refreshActiveChat();
      }
    }, onError: (error) {
      debugPrint('MessagingScreen broadcast stream error: $error');
    });
  }

  void _listenToReplies(String childId) {
    _replySubscription?.cancel();
    _replySubscription = _messagingService
        .listenToChildReplies(childId: childId, limit: 40)
        .listen((messages) {
      if (!mounted) return;
      _childReplies = messages
          .where((msg) => msg.ageGroup == AgeGroup.bright)
          .toList(growable: false);
      _refreshConversations();
      if (_isFirebaseConversation) {
        _refreshActiveChat();
      }
    }, onError: (error) {
      debugPrint('MessagingScreen reply stream error: $error');
    });
  }

  void _refreshConversations() {
    final summaries = <String, _TeacherConversationSummary>{};

    void ensureSummary(
      String teacherId,
      String teacherName,
      String? avatar,
      void Function(_TeacherConversationSummary summary) updater,
    ) {
      final summary = summaries.putIfAbsent(
        teacherId,
        () => _TeacherConversationSummary(
          teacherId: teacherId,
          teacherName: teacherName,
          avatar: avatar,
        ),
      );
      updater(summary);
    }

    for (final broadcast in _broadcastMessages) {
      ensureSummary(
        broadcast.teacherId,
        broadcast.teacherName,
        broadcast.teacherAvatar,
        (summary) => summary.addBroadcast(broadcast),
      );
    }

    for (final reply in _childReplies) {
      ensureSummary(
        reply.teacherId,
        reply.teacherName,
        reply.teacherAvatar,
        (summary) => summary.addReply(reply),
      );
    }

    final tiles = summaries.values
        .map((summary) => summary.toTile(_formatConversationTime))
        .toList()
      ..sort((a, b) =>
          (b['sortTimestamp'] as int).compareTo(a['sortTimestamp'] as int));

    final cleanedTiles = tiles.map((tile) {
      final copy = Map<String, dynamic>.from(tile);
      copy.remove('sortTimestamp');
      return copy;
    }).toList(growable: true);

    final combined = [
      ...cleanedTiles,
      ..._mockConversations,
    ];

    int selectedIndex;
    if (_isFirebaseConversation && _activeTeacherId != null) {
      final matchIndex =
          combined.indexWhere((c) => c['teacherId'] == _activeTeacherId);
      selectedIndex = matchIndex >= 0 ? matchIndex : 0;
    } else {
      final mockOffset = cleanedTiles.length;
      final mockIndex =
          _selectedMockIndex.clamp(0, _mockConversations.length - 1);
      selectedIndex = mockOffset + mockIndex;
    }

    setState(() {
      _conversations = combined;
      _selectedConversation =
          combined.isNotEmpty ? selectedIndex.clamp(0, combined.length - 1) : 0;
    });
  }

  void _refreshActiveChat() {
    final teacherId = _activeTeacherId;
    if (teacherId == null) return;

    final entries = <_ChatEntry>[];
    final broadcastList = _broadcastMessages.where((msg) => msg.teacherId == teacherId).toList();
    for (final broadcast in broadcastList) {
      entries.add(_ChatEntry(
        text: broadcast.message,
        isMe: false,
        timestamp: broadcast.createdAt,
        gameId: broadcast.gameId,
        gameName: broadcast.gameName,
        ctaLabel: broadcast.ctaLabel,
        emoji: broadcast.emoji,
        gameType: broadcast.gameType,
      ));
    }
    for (final reply
        in _childReplies.where((msg) => msg.teacherId == teacherId)) {
      entries.add(_ChatEntry(
        text: reply.body,
        isMe: true,
        timestamp: reply.createdAt,
      ));
    }
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    setState(() {
      _isFirebaseConversation = true;
      _messages = entries
          .map((entry) => {
                'text': entry.text,
                'isMe': entry.isMe,
                'time': DateFormat('h:mm a').format(entry.timestamp),
                if (entry.gameId != null) 'gameId': entry.gameId,
                if (entry.gameName != null) 'gameName': entry.gameName,
                if (entry.ctaLabel != null) 'ctaLabel': entry.ctaLabel,
                if (entry.emoji != null) 'emoji': entry.emoji,
                if (entry.gameType != null) 'gameType': entry.gameType,
              })
          .toList();
    });
    _scrollToBottom();
  }

  void _openFirebaseConversation(Map<String, dynamic> conversation, int index) {
    final teacherId = conversation['teacherId'] as String?;
    if (teacherId == null) return;
    setState(() {
      _activeTeacherId = teacherId;
      _activeTeacherName = conversation['name'] as String?;
      _selectedConversation = index;
      _showConversationList = false;
    });
    _refreshActiveChat();
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    if (_isFirebaseConversation) {
      _sendReply(text);
    } else {
      setState(() {
        _messages.add({
          'text': text,
          'isMe': true,
          'time': 'Now',
          'senderName': 'You',
        });
        _messageController.clear();
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendReply(String text) async {
    if (_sendingReply) return;
    final child = _childProfile;
    final teacherId = _activeTeacherId;
    if (child == null || teacherId == null) {
      _showSnack('Please sign in as a Bright student to send messages.');
      return;
    }

    setState(() => _sendingReply = true);
    try {
      await _messagingService.sendChildReply(
        teacherId: teacherId,
        teacherName: _activeTeacherName ?? 'Teacher',
        childId: child.id,
        childName: child.name,
        ageGroup: child.ageGroup ?? AgeGroup.bright,
        message: text,
        teacherAvatar: _currentConversationAvatar(teacherId),
        childAvatar: _childAvatarEmoji(child),
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint('MessagingScreen reply error: $error');
      debugPrint('$stackTrace');
      _showSnack('Unable to send message right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _sendingReply = false);
      }
    }
  }

  String? _currentConversationAvatar(String teacherId) {
    final match = _conversations.firstWhere((c) => c['teacherId'] == teacherId,
        orElse: () => {});
    final avatar = match['avatar'];
    return avatar is String ? avatar : null;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _childAvatarEmoji(ChildProfile child) {
    final gender = child.gender?.toLowerCase();
    if (gender == 'male' || gender == 'boy') {
      return '👦';
    }
    if (gender == 'female' || gender == 'girl') {
      return '👧';
    }
    return '🧑';
  }

  String _formatConversationTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }
    return DateFormat('MMM d').format(timestamp);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: JuniorTheme.primaryOrange,
      ),
    );
  }

  String _getTeacherInitial(String name) {
    if (name.isEmpty) return 'T';
    return name[0].toUpperCase();
  }

  Widget _buildTeacherInitialAvatar(String name) {
    final initial = _getTeacherInitial(name);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            JuniorTheme.primaryBlue,
            JuniorTheme.primaryPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: JuniorTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInlineGameButton({
    required String gameId,
    required String gameName,
    required String ctaLabel,
    required String emoji,
    String? gameType, // 'web' or 'simulation'
  }) {
    final gameNavService = GameNavigationService();
    return GestureDetector(
      onTap: () async {
        // Navigate to the actual game/simulation
        await gameNavService.navigateToGame(
          context,
          gameId,
          'bright',
          gameType ?? 'web',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              JuniorTheme.primaryBlue,
              JuniorTheme.primaryPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: JuniorTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              ctaLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JuniorTheme.primaryBlue.withOpacity(0.1),
            JuniorTheme.backgroundLight,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildAIGuardBanner(),
          Expanded(
            child: _showConversationList
                ? _buildConversationList()
                : _buildChatView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!_showConversationList)
            GestureDetector(
              onTap: () => setState(() => _showConversationList = true),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: JuniorTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: JuniorTheme.primaryBlue,
                  size: 20,
                ),
              ),
            ),
          if (!_showConversationList)
            _buildTeacherInitialAvatar(
                _conversations[_selectedConversation]['name'] as String? ?? 'T')
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    JuniorTheme.primaryBlue,
                    JuniorTheme.primaryPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: JuniorTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showConversationList
                      ? 'Messages'
                      : _conversations[_selectedConversation]['name'],
                  style: JuniorTheme.headingSmall.copyWith(
                    fontSize: 22,
                    color: JuniorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _showConversationList
                      ? 'Chat with your teachers'
                      : (_conversations[_selectedConversation]['online']
                          ? '🟢 Online'
                          : '⚪ Offline'),
                  style: JuniorTheme.bodySmall.copyWith(
                    color: JuniorTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIGuardBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            JuniorTheme.primaryGreen.withOpacity(0.15),
            JuniorTheme.primaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: JuniorTheme.primaryGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuniorTheme.primaryGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: JuniorTheme.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Safety Guard Active',
                  style: JuniorTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: JuniorTheme.primaryGreen,
                  ),
                ),
                Text(
                  'Messages are monitored for your safety',
                  style: JuniorTheme.bodySmall.copyWith(
                    color: JuniorTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: JuniorTheme.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ON',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationTile(conversation, index);
      },
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation, int index) {
    return GestureDetector(
      onTap: () {
        final teacherId = conversation['teacherId'] as String?;
        if (teacherId != null) {
          _openFirebaseConversation(conversation, index);
        } else {
          final firebaseCount =
              _conversations.length - _mockConversations.length;
          final mockIndex = index - firebaseCount;
          _selectedMockIndex = mockIndex >= 0
              ? mockIndex.clamp(0, _mockConversations.length - 1)
              : 0;
          setState(() {
            _selectedConversation = index;
            _showConversationList = false;
            _isFirebaseConversation = false;
            _activeTeacherId = null;
            _activeTeacherName = null;
            _messages = List<Map<String, dynamic>>.from(_mockMessages);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        JuniorTheme.primaryBlue.withOpacity(0.2),
                        JuniorTheme.primaryPurple.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      _getTeacherInitial(
                          conversation['name'] as String? ?? 'T'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: JuniorTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
                if (conversation['online'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: JuniorTheme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation['name'],
                        style: JuniorTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        conversation['time'],
                        style: JuniorTheme.bodySmall.copyWith(
                          color: JuniorTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation['lastMessage'],
                          style: JuniorTheme.bodySmall.copyWith(
                            color: JuniorTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation['unread'] > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: JuniorTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${conversation['unread']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: JuniorTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;
                return _buildMessageBubble(
                  text: message['text'] as String,
                  isMe: isMe,
                  time: message['time'] as String,
                  gameId: message['gameId'] as String?,
                  gameName: message['gameName'] as String?,
                  ctaLabel: message['ctaLabel'] as String?,
                  emoji: message['emoji'] as String?,
                  gameType: message['gameType'] as String?,
                );
              },
            ),
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required String time,
    String? gameId,
    String? gameName,
    String? ctaLabel,
    String? emoji,
    String? gameType,
  }) {
    // Check if this message contains game-related content
    final hasGameLink = !isMe && gameId != null && ctaLabel != null;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          JuniorTheme.primaryBlue,
                          JuniorTheme.primaryPurple.withOpacity(0.8),
                        ],
                      )
                    : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(6),
                  bottomRight: isMe
                      ? const Radius.circular(6)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? JuniorTheme.primaryBlue.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: JuniorTheme.bodyMedium.copyWith(
                      color: isMe ? Colors.white : JuniorTheme.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  if (hasGameLink) ...[
                    const SizedBox(height: 12),
                    _buildInlineGameButton(
                      gameId: gameId!,
                      gameName: gameName ?? 'Game',
                      ctaLabel: ctaLabel!,
                      emoji: emoji ?? '🎮',
                      gameType: gameType,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                time,
                style: JuniorTheme.bodySmall.copyWith(
                  color: JuniorTheme.textLight,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick replies row
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickReplyChip('Thanks! 👍'),
                  const SizedBox(width: 8),
                  _buildQuickReplyChip('I understand 😊'),
                  const SizedBox(width: 8),
                  _buildQuickReplyChip('Can you explain more? 🤔'),
                  const SizedBox(width: 8),
                  _buildQuickReplyChip('Got it! ✅'),
                  const SizedBox(width: 8),
                  _buildQuickReplyChip('I need help 🙋'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Input row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: JuniorTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: JuniorTheme.textLight.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: JuniorTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: JuniorTheme.bodyMedium.copyWith(
                          color: JuniorTheme.textLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (_sendingReply && _isFirebaseConversation) return;
                    _handleSendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          JuniorTheme.primaryBlue,
                          JuniorTheme.primaryPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: JuniorTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _sendingReply && _isFirebaseConversation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
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

  Widget _buildQuickReplyChip(String text) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: JuniorTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: JuniorTheme.primaryBlue.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          style: JuniorTheme.bodySmall.copyWith(
            color: JuniorTheme.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ChatEntry {
  const _ChatEntry({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.gameId,
    this.gameName,
    this.ctaLabel,
    this.emoji,
    this.gameType,
  });

  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? gameId;
  final String? gameName;
  final String? ctaLabel;
  final String? emoji;
  final String? gameType;
}

class _TeacherConversationSummary {
  _TeacherConversationSummary({
    required this.teacherId,
    required this.teacherName,
    this.avatar,
  });

  final String teacherId;
  final String teacherName;
  final String? avatar;

  DateTime? _lastTimestamp;
  String? _lastMessagePreview;

  void addBroadcast(TeacherBroadcastMessage message) {
    _update(message.createdAt, message.message);
  }

  void addReply(TeacherInboxMessage message) {
    _update(message.createdAt, message.body);
  }

  void _update(DateTime timestamp, String preview) {
    if (_lastTimestamp == null || timestamp.isAfter(_lastTimestamp!)) {
      _lastTimestamp = timestamp;
      _lastMessagePreview = preview;
    }
  }

  Map<String, dynamic> toTile(String Function(DateTime) timeFormatter) {
    final timestamp = _lastTimestamp ?? DateTime.now();
    return {
      'teacherId': teacherId,
      'name': teacherName,
      'avatar': avatar ?? '??',
      'lastMessage': _lastMessagePreview ?? 'Say hi to your teacher!',
      'time': timeFormatter(timestamp),
      'unread': 0,
      'online': false,
      'sortTimestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
