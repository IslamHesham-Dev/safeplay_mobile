import 'package:flutter/foundation.dart';

/// Session-based coin storage service
/// Coins are only stored for the current session and reset to 0 when app restarts
class SessionCoinService extends ChangeNotifier {
  static final SessionCoinService _instance = SessionCoinService._internal();
  factory SessionCoinService() => _instance;
  SessionCoinService._internal();

  // Session-based coin storage (not persisted)
  int _sessionCoins = 0;
  int _pendingCoins =
      0; // Coins earned from last activity, waiting to be animated

  /// Get current session coins
  int get sessionCoins => _sessionCoins;

  /// Get pending coins (from last activity)
  int get pendingCoins => _pendingCoins;

  /// Add coins earned from an activity
  void addCoins(int coins) {
    _pendingCoins = coins;
    _sessionCoins += coins;
    debugPrint('💰 Session coins updated: $_sessionCoins (added $coins)');
    notifyListeners(); // Notify listeners that coins have changed
  }

  /// Clear pending coins after animation
  void clearPendingCoins() {
    _pendingCoins = 0;
    notifyListeners(); // Notify listeners that pending coins have been cleared
  }

  /// Reset session coins (called on app restart)
  void reset() {
    _sessionCoins = 0;
    _pendingCoins = 0;
    debugPrint('💰 Session coins reset to 0');
    notifyListeners(); // Notify listeners that coins have been reset
  }
}
