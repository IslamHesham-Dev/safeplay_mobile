import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

/// Teacher Messaging Screen - Broadcast messages to students
class TeacherMessagingScreen extends StatefulWidget {
  const TeacherMessagingScreen({super.key});

  @override
  State<TeacherMessagingScreen> createState() => _TeacherMessagingScreenState();
}

class _TeacherMessagingScreenState extends State<TeacherMessagingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedAgeGroup = 'bright'; // 'junior' or 'bright'
  final TextEditingController _customMessageController = TextEditingController();

  // Pre-made friendly nudges/notifications
  final List<QuickMessage> _quickMessages = [
    // Science Games
    QuickMessage(
      id: 'food-chains',
      emoji: '🦁',
      title: 'Explore Food Chains!',
      message: 'Hey explorers! 🌿 Ready to discover who eats what in nature? Jump into the Food Chains game and learn about animals, plants, and how they all connect!',
      category: 'Science',
      color: const Color(0xFF4CAF50),
    ),
    QuickMessage(
      id: 'microorganisms',
      emoji: '🔬',
      title: 'Tiny World Adventure!',
      message: 'Did you know there are living things too small to see? 🦠 Explore the world of microorganisms - bacteria, fungi, and algae are waiting for you!',
      category: 'Science',
      color: const Color(0xFF9C27B0),
    ),
    QuickMessage(
      id: 'electricity',
      emoji: '⚡',
      title: 'Power Up with Circuits!',
      message: 'Ready to become an electricity expert? 💡 Build circuits, connect batteries and bulbs, and see what happens when you change things around!',
      category: 'Science',
      color: const Color(0xFFFF9800),
    ),
    QuickMessage(
      id: 'earth-sun-moon',
      emoji: '🌍',
      title: 'Space Explorer Time!',
      message: 'Blast off into space! 🚀 Learn how Earth, Sun, and Moon dance together in the sky. Discover orbits and why we have day and night!',
      category: 'Science',
      color: const Color(0xFF2196F3),
    ),
    QuickMessage(
      id: 'plants-grow',
      emoji: '🌱',
      title: 'Grow a Plant!',
      message: 'Become a plant scientist! 🧑‍🔬 Experiment with heat and water to help plants grow. What happens when conditions change?',
      category: 'Science',
      color: const Color(0xFF8BC34A),
    ),
    // Math Games
    QuickMessage(
      id: 'equality-explorer',
      emoji: '⚖️',
      title: 'Balance the Scale!',
      message: 'Can you make both sides equal? ⚖️ Use the balance scale to solve equations and become a math champion!',
      category: 'Math',
      color: const Color(0xFF5B9BD5),
    ),
    QuickMessage(
      id: 'area-model',
      emoji: '📐',
      title: 'Shape Up with Area!',
      message: 'Rectangles are everywhere! 📏 Learn how to find area using the Area Model - break numbers into parts and see multiplication come alive!',
      category: 'Math',
      color: const Color(0xFFE91E63),
    ),
    QuickMessage(
      id: 'mean-balance',
      emoji: '📊',
      title: 'Fair Share Fun!',
      message: 'What does "average" really mean? 🤔 Share and balance numbers to discover the mean - it\'s like making everything fair!',
      category: 'Math',
      color: const Color(0xFF00BCD4),
    ),
    // Reading & English
    QuickMessage(
      id: 'reading-time',
      emoji: '📚',
      title: 'Story Time!',
      message: 'A new adventure awaits in the library! 📖 Pick a book, read along, and discover amazing stories. What will you read today?',
      category: 'English',
      color: const Color(0xFF673AB7),
    ),
    QuickMessage(
      id: 'spelling-bee',
      emoji: '🐝',
      title: 'Spelling Bee Challenge!',
      message: 'Can you spell like a champion? 🏆 Practice your spelling words and become a word wizard! Every letter counts!',
      category: 'English',
      color: const Color(0xFFFFEB3B),
    ),
    // Simulations
    QuickMessage(
      id: 'states-matter',
      emoji: '💧',
      title: 'States of Matter Magic!',
      message: 'Watch atoms dance! 💃 See how solids, liquids, and gases behave differently. Heat things up or cool them down - what happens?',
      category: 'Simulation',
      color: const Color(0xFF00BCD4),
    ),
    QuickMessage(
      id: 'static-electricity',
      emoji: '🎈',
      title: 'Balloon Science!',
      message: 'Rub a balloon and watch the magic happen! ✨ Learn about static electricity and see charges push and pull!',
      category: 'Simulation',
      color: const Color(0xFFFF5722),
    ),
    // General Encouragement
    QuickMessage(
      id: 'daily-goal',
      emoji: '🎯',
      title: 'Daily Goal Reminder',
      message: 'You\'re doing amazing! 🌟 Remember to complete your daily tasks and earn those coins. Every game counts!',
      category: 'Motivation',
      color: const Color(0xFF4CAF50),
    ),
    QuickMessage(
      id: 'wellbeing',
      emoji: '💖',
      title: 'Check-in Time',
      message: 'How are you feeling today? 😊 Take a moment to share your mood. We care about how you\'re doing!',
      category: 'Wellbeing',
      color: const Color(0xFFE91E63),
    ),
    QuickMessage(
      id: 'explore-new',
      emoji: '🗺️',
      title: 'Try Something New!',
      message: 'Adventure awaits! 🚀 Why not try a game you haven\'t played before? You might discover your new favorite!',
      category: 'Motivation',
      color: const Color(0xFF9C27B0),
    ),
  ];

  String _selectedCategory = 'All';

  // Mock student messages/questions
  final List<StudentMessage> _studentMessages = [
    StudentMessage(
      id: '1',
      studentName: 'Emma',
      studentAvatar: '👧',
      ageGroup: 'bright',
      question: 'Ms. Johnson, I don\'t understand how the food chain works. Can animals be in more than one food chain? 🤔',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      relatedGame: 'Food Chains',
    ),
    StudentMessage(
      id: '2',
      studentName: 'Liam',
      studentAvatar: '👦',
      ageGroup: 'bright',
      question: 'How do I balance the equation in the scale game? I keep getting it wrong 😅',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      relatedGame: 'Equality Explorer',
    ),
    StudentMessage(
      id: '3',
      studentName: 'Sophia',
      studentAvatar: '👧',
      ageGroup: 'bright',
      question: 'The States of Matter simulation is so cool! But why do the atoms move faster when it\'s hot? 🔥',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      relatedGame: 'States of Matter',
    ),
    StudentMessage(
      id: '4',
      studentName: 'Noah',
      studentAvatar: '👦',
      ageGroup: 'bright',
      question: 'I finished all the math games! What should I try next? ⭐',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      relatedGame: null,
    ),
    StudentMessage(
      id: '5',
      studentName: 'Olivia',
      studentAvatar: '👧',
      ageGroup: 'bright',
      question: 'Can you explain what happens to water when it freezes? I saw it in the simulation but I want to understand more! ❄️',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
      relatedGame: 'States of Matter',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  List<QuickMessage> get _filteredMessages {
    if (_selectedCategory == 'All') return _quickMessages;
    return _quickMessages.where((m) => m.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildAgeGroupSelector(),
          _buildCategoryFilter(),
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
                child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
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
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: [
                const Tab(text: '✨ Quick'),
                const Tab(text: '✏️ Custom'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📩 Inbox'),
                      if (_studentMessages.where((m) => !m.isRead).isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              'Junior (3-6)',
              '👶',
              SafePlayColors.juniorPurple,
            ),
          ),
          Expanded(
            child: _buildAgeGroupButton(
              'bright',
              'Bright (7-10)',
              '🧒',
              SafePlayColors.brightIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupButton(String value, String label, String emoji, Color color) {
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
    final categories = ['All', 'Science', 'Math', 'English', 'Simulation', 'Motivation', 'Wellbeing'];
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
                color: isSelected ? SafePlayColors.brandTeal500 : SafePlayColors.neutral200,
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
                        child: Text(message.emoji, style: const TextStyle(fontSize: 24)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              border: Border.all(color: SafePlayColors.brandTeal500.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SafePlayColors.brandTeal500.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.info_outline, color: SafePlayColors.brandTeal500, size: 24),
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
                hintText: 'Write a friendly message for your students...\n\nTip: Use emojis to make it fun! 🎉',
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
            children: ['🎉', '⭐', '🚀', '💪', '🎯', '📚', '🧠', '💡', '🌟', '👏', '🎮', '🏆']
                .map((emoji) => _buildEmojiButton(emoji))
                .toList(),
          ),
          const SizedBox(height: 24),

          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSendConfirmation(null),
              icon: const Icon(Icons.send_rounded),
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
        final newText = text.replaceRange(
          selection.start,
          selection.end,
          emoji,
        );
        _customMessageController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: selection.start + emoji.length),
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
    // Mock sent messages
    final sentMessages = [
      {'message': '🎉 Great job on your math practice today!', 'time': '2 hours ago', 'group': 'Bright'},
      {'message': '📚 Don\'t forget to check out the new books!', 'time': 'Yesterday', 'group': 'Junior'},
      {'message': '⭐ Keep up the amazing work everyone!', 'time': '2 days ago', 'group': 'Bright'},
    ];

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
                      msg['message']!,
                      style: TextStyle(
                        color: SafePlayColors.neutral700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: msg['group'] == 'Junior'
                                ? SafePlayColors.juniorPurple.withOpacity(0.1)
                                : SafePlayColors.brightIndigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            msg['group']!,
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
                          msg['time']!,
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
              Icon(Icons.check_circle, color: SafePlayColors.success, size: 20),
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
                    child: Text(message.emoji, style: const TextStyle(fontSize: 28)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      'This message will be sent to all ${_selectedAgeGroup == 'junior' ? 'Junior (3-6)' : 'Bright (7-10)'} students',
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
                onPressed: () {
                  Navigator.pop(context);
                  _showSendConfirmation(message);
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text(
                  'Send Message',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  void _showSendConfirmation(QuickMessage? message) {
    final messageText = message?.message ?? _customMessageController.text;
    if (messageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write a message first'),
          backgroundColor: SafePlayColors.warning,
        ),
      );
      return;
    }

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
              if (message == null) {
                _customMessageController.clear();
              }
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
            border: Border.all(color: SafePlayColors.brightIndigo.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SafePlayColors.brightIndigo.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.school_rounded, color: SafePlayColors.brightIndigo, size: 22),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _studentMessages.length,
                  itemBuilder: (context, index) {
                    return _buildStudentMessageCard(_studentMessages[index]);
                  },
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
              child: Text('📭', style: TextStyle(fontSize: 48)),
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
            'When Bright students send you questions,\nthey will appear here.',
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
        border: message.isRead ? null : Border.all(color: SafePlayColors.brightIndigo, width: 2),
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
                          colors: [SafePlayColors.brightIndigo, SafePlayColors.brightIndigo.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(message.studentAvatar, style: const TextStyle(fontSize: 24)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: SafePlayColors.brightIndigo.withOpacity(0.1),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: SafePlayColors.neutral50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SafePlayColors.neutral200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.games_outlined, size: 14, color: SafePlayColors.neutral500),
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
        );
      }
    });

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
                      colors: [SafePlayColors.brightIndigo, SafePlayColors.brightIndigo.withOpacity(0.7)],
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
                    child: Text(message.studentAvatar, style: const TextStyle(fontSize: 30)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: SafePlayColors.brightIndigo.withOpacity(0.1),
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
                border: Border.all(color: SafePlayColors.brightIndigo.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, size: 18, color: SafePlayColors.brightIndigo),
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
                    Icon(Icons.games_rounded, size: 20, color: SafePlayColors.neutral600),
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
                icon: const Icon(Icons.reply_rounded),
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
            const SizedBox(height: 12),
            // Mark actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Question archived'),
                          backgroundColor: SafePlayColors.neutral600,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.archive_outlined, size: 18),
                    label: const Text('Archive'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SafePlayColors.neutral600,
                      side: BorderSide(color: SafePlayColors.neutral300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Question flagged for follow-up'),
                          backgroundColor: SafePlayColors.warning,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('Flag'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SafePlayColors.warning,
                      side: BorderSide(color: SafePlayColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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
                child: Text(message.studentAvatar, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reply to', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                  Text(message.studentName, style: const TextStyle(fontSize: 16)),
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
                  borderSide: BorderSide(color: SafePlayColors.brightIndigo, width: 2),
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
            child: Text('Cancel', style: TextStyle(color: SafePlayColors.neutral500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Reply sent to ${message.studentName}!'),
                    ],
                  ),
                  backgroundColor: SafePlayColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.brightIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          border: Border.all(color: SafePlayColors.brightIndigo.withOpacity(0.3)),
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

  const QuickMessage({
    required this.id,
    required this.emoji,
    required this.title,
    required this.message,
    required this.category,
    required this.color,
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

  const StudentMessage({
    required this.id,
    required this.studentName,
    required this.studentAvatar,
    required this.ageGroup,
    required this.question,
    required this.timestamp,
    required this.isRead,
    this.relatedGame,
  });
}

