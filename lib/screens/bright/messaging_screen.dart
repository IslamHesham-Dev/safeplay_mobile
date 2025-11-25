import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
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
      'text': 'That\'s great to hear! Remember to check the safety guidelines before starting the next experiment. 🔬',
      'isMe': false,
      'time': '10:06 AM',
      'senderName': 'Ms. Sarah',
    },
  ];

  // Mock conversations list
  final List<Map<String, dynamic>> _conversations = [
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

  bool _showConversationList = true;
  int _selectedConversation = 0;

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
          if (!_showConversationList)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: JuniorTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: JuniorTheme.primaryGreen,
                size: 22,
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
        setState(() {
          _selectedConversation = index;
          _showConversationList = false;
        });
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
                      conversation['avatar'],
                      style: const TextStyle(fontSize: 28),
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
  }) {
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
              child: Text(
                text,
                style: JuniorTheme.bodyMedium.copyWith(
                  color: isMe ? Colors.white : JuniorTheme.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: JuniorTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: JuniorTheme.primaryOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
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
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _messages.add({
                      'text': _messageController.text,
                      'isMe': true,
                      'time': 'Now',
                      'senderName': 'You',
                    });
                    _messageController.clear();
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                }
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
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
