import 'package:flutter/material.dart';
import '../../design_system/junior_theme.dart';

class SafeSearchScreen extends StatefulWidget {
  const SafeSearchScreen({super.key});

  @override
  State<SafeSearchScreen> createState() => _SafeSearchScreenState();
}

class _SafeSearchScreenState extends State<SafeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Images', 'Videos', 'Games', 'Facts'];
  bool _isSearching = false;

  // Suggested topics
  final List<Map<String, dynamic>> _suggestedTopics = [
    {'emoji': '🦕', 'title': 'Dinosaurs', 'color': JuniorTheme.primaryGreen},
    {'emoji': '🚀', 'title': 'Space', 'color': JuniorTheme.primaryBlue},
    {'emoji': '🌊', 'title': 'Ocean', 'color': JuniorTheme.primaryPurple},
    {'emoji': '🦁', 'title': 'Animals', 'color': JuniorTheme.primaryOrange},
    {'emoji': '🌋', 'title': 'Volcanoes', 'color': JuniorTheme.primaryPink},
    {'emoji': '🔬', 'title': 'Science', 'color': JuniorTheme.primaryYellow},
  ];

  // Dummy results
  final List<Map<String, dynamic>> _results = [
    {
      'title': 'All About Dolphins',
      'description': 'Dolphins are highly intelligent marine mammals known for their playful behavior...',
      'type': 'Fact',
      'color': JuniorTheme.primaryBlue,
      'icon': Icons.water,
      'emoji': '🐬',
    },
    {
      'title': 'Space Exploration Video',
      'description': 'Watch astronauts float in zero gravity and explore the International Space Station!',
      'type': 'Video',
      'color': JuniorTheme.primaryPurple,
      'icon': Icons.play_circle_fill,
      'emoji': '🚀',
    },
    {
      'title': 'Math Puzzles',
      'description': 'Fun and challenging math games for beginners. Improve your skills!',
      'type': 'Game',
      'color': JuniorTheme.primaryOrange,
      'icon': Icons.games,
      'emoji': '🧩',
    },
    {
      'title': 'Rainforest Animals',
      'description': 'Discover amazing creatures that live in the world\'s rainforests.',
      'type': 'Fact',
      'color': JuniorTheme.primaryGreen,
      'icon': Icons.forest,
      'emoji': '🌴',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JuniorTheme.primaryOrange.withOpacity(0.1),
            JuniorTheme.backgroundLight,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategories(),
          Expanded(
            child: _isSearching || _searchController.text.isNotEmpty
                ? _buildResults()
                : _buildSuggestedTopics(),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  JuniorTheme.primaryOrange,
                  JuniorTheme.primaryPink,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: JuniorTheme.primaryOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.travel_explore,
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
                  'Safe Search',
                  style: JuniorTheme.headingSmall.copyWith(
                    fontSize: 22,
                    color: JuniorTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Explore the world safely!',
                  style: JuniorTheme.bodySmall.copyWith(
                    color: JuniorTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: JuniorTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: JuniorTheme.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_rounded,
                  color: Colors.green[700],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Protected',
                  style: JuniorTheme.bodySmall.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: JuniorTheme.bodyLarge.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'What do you want to learn about?',
          hintStyle: JuniorTheme.bodyMedium.copyWith(
            color: JuniorTheme.textLight,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: JuniorTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: JuniorTheme.primaryOrange,
                size: 22,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: JuniorTheme.textLight.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: JuniorTheme.textSecondary,
                      size: 16,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _isSearching = false;
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          JuniorTheme.primaryOrange,
                          JuniorTheme.primaryPink,
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? JuniorTheme.primaryOrange.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 10 : 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                category,
                style: JuniorTheme.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : JuniorTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestedTopics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: JuniorTheme.primaryYellow,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Explore Topics',
                  style: JuniorTheme.headingSmall.copyWith(
                    fontSize: 18,
                    color: JuniorTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.4,
            ),
            itemCount: _suggestedTopics.length,
            itemBuilder: (context, index) {
              final topic = _suggestedTopics[index];
              return _buildTopicCard(topic);
            },
          ),
          const SizedBox(height: 24),
          _buildFunFactCard(),
        ],
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchController.text = topic['title'];
          _isSearching = true;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (topic['color'] as Color).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Text(
                topic['emoji'],
                style: TextStyle(
                  fontSize: 60,
                  color: (topic['color'] as Color).withOpacity(0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (topic['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      topic['emoji'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    topic['title'],
                    style: JuniorTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: JuniorTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunFactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            JuniorTheme.primaryBlue.withOpacity(0.1),
            JuniorTheme.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: JuniorTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: JuniorTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text('💡', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Did you know?',
                  style: JuniorTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: JuniorTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Octopuses have three hearts and blue blood!',
                  style: JuniorTheme.bodySmall.copyWith(
                    color: JuniorTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (result['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      result['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (result['color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              result['type'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: result['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result['title'],
                        style: JuniorTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result['description'],
                        style: JuniorTheme.bodySmall.copyWith(
                          color: JuniorTheme.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (result['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: result['color'] as Color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
