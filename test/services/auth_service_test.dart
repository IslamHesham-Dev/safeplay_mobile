import 'package:flutter_test/flutter_test.dart';
import 'package:safeplay_mobile/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should be instantiated', () {
      expect(authService, isNotNull);
    });

    test('should have required methods', () {
      expect(authService.signInWithEmail, isNotNull);
      expect(authService.signUpWithEmail, isNotNull);
      expect(authService.signOut, isNotNull);
    });
  });
}
