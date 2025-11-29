import 'package:flutter/material.dart';
import '../models/web_game.dart';
import '../services/web_game_service.dart';
import '../services/simulation_service.dart';
import '../screens/junior/web_game_detail_screen.dart';
import '../screens/bright/simulation_detail_screen.dart';

/// Service to help navigate to games from messages
class GameNavigationService {
  static final GameNavigationService _instance = GameNavigationService._internal();
  factory GameNavigationService() => _instance;
  GameNavigationService._internal();

  final WebGameService _webGameService = WebGameService();
  final SimulationService _simulationService = SimulationService();

  /// Navigate to a game by ID for Junior students
  Future<void> navigateToJuniorGame(
    BuildContext context,
    String gameId,
  ) async {
    try {
      // Get all junior games
      final games = await _webGameService.getWebGames(ageGroup: 'junior');
      final game = games.firstWhere(
        (g) => g.id == gameId,
        orElse: () => throw Exception('Game not found: $gameId'),
      );

      // Navigate to the game detail screen
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebGameDetailScreen(game: game),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Game not found: $gameId'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to a game by ID for Bright students (web game)
  Future<void> navigateToBrightWebGame(
    BuildContext context,
    String gameId,
  ) async {
    try {
      WebGame game;
      
      // First, try to find in Bright games with exact ID
      final brightGames = await _webGameService.getWebGames(ageGroup: 'bright');
      try {
        game = brightGames.firstWhere(
          (g) => g.id == gameId,
        );
      } catch (_) {
        // If not found, try with "-bright" suffix (Bright games are cloned from Junior with suffix)
        try {
          game = brightGames.firstWhere(
            (g) => g.id == '$gameId-bright',
          );
        } catch (_) {
          // If still not found, try Junior games (Bright students can access Junior games)
          final juniorGames = await _webGameService.getWebGames(ageGroup: 'junior');
          game = juniorGames.firstWhere(
            (g) => g.id == gameId,
          );
        }
      }

      // Navigate to the game detail screen
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebGameDetailScreen(game: game),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Game not found: $gameId'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to a simulation by ID for Bright students
  Future<void> navigateToBrightSimulation(
    BuildContext context,
    String simulationId,
  ) async {
    try {
      // Get all bright simulations
      final simulations = await _simulationService.getSimulations(ageGroup: 'bright');
      final simulation = simulations.firstWhere(
        (s) => s.id == simulationId,
        orElse: () => throw Exception('Simulation not found: $simulationId'),
      );

      // Navigate to the simulation detail screen
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SimulationDetailScreen(
            simulation: simulation,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Simulation not found: $simulationId'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to a game/simulation based on gameId and type
  Future<void> navigateToGame(
    BuildContext context,
    String gameId,
    String ageGroup, // 'junior' or 'bright'
    String? gameType, // 'web' or 'simulation'
  ) async {
    if (ageGroup == 'junior') {
      await navigateToJuniorGame(context, gameId);
    } else if (ageGroup == 'bright') {
      if (gameType == 'simulation') {
        await navigateToBrightSimulation(context, gameId);
      } else {
        await navigateToBrightWebGame(context, gameId);
      }
    }
  }
}

