import '../models/web_game.dart';

/// Service for managing web-based educational games
class WebGameService {
  static final WebGameService _instance = WebGameService._internal();
  factory WebGameService() => _instance;
  WebGameService._internal();

  /// Get all web games for a specific age group
  Future<List<WebGame>> getWebGames(
      {String ageGroup = 'junior', String? subject}) async {
    if (ageGroup == 'junior') {
      return _getJuniorWebGames(subject: subject);
    } else if (ageGroup == 'bright') {
      return _getBrightWebGames(subject: subject);
    }
    return [];
  }

  /// Get web games for Junior children (6-8)
  Future<List<WebGame>> _getJuniorWebGames({String? subject}) async {
    final allGames = [
      const WebGame(
        id: 'food-chains',
        title: 'Food Chains',
        description:
            'Learn about various living things such as animals and plants, sort them into different categories and discover where they fit into the food chain.',
        websiteUrl:
            'https://www.sciencekids.co.nz/gamesactivities/foodchains.html',
        canvasSelector: null,
        topics: [
          'Animals',
          'Plants',
          'Food Chains',
          'Habitats',
          'Ecosystems',
        ],
        learningGoals: [
          'Identify different animals and plants in a woodland habitat.',
          'Understand what a food chain is and how living things depend on each other.',
          'Sort animals by characteristics (fly, have legs, have shells).',
          'Explore how different habitats (ocean, forest, desert) have different food chains.',
          'Learn about producers, consumers, and decomposers in nature.',
        ],
        explanation:
            'A food chain shows how energy moves from one living thing to another. '
            'Plants make their own food using sunlight (producers). Animals that eat plants are called herbivores. '
            'Animals that eat other animals are called carnivores. In this game, you\'ll explore the woodland habitat '
            'and discover how animals like the fox, owl, squirrel, snail, bird, and caterpillar fit into the food chain!',
        warning:
            'This game requires an internet connection. Adult guidance is recommended for younger learners.',
        estimatedMinutes: 15,
        difficulty: 'Easy',
        ageGroup: 'junior',
        subject: 'science',
        iconEmoji: '🌳',
        color: '4CAF50', // Green
      ),
    ];

    if (subject != null) {
      return allGames.where((game) => game.subject == subject).toList();
    }
    return allGames;
  }

  /// Get web games for Bright children (9-12)
  Future<List<WebGame>> _getBrightWebGames({String? subject}) async {
    // Placeholder for future Bright web games
    return [];
  }
}
