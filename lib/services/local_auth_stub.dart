// Stub for local_auth on web
// This file provides a stub implementation for web platforms

class LocalAuthentication {
  Future<bool> get canCheckBiometrics async => false;

  Future<bool> authenticate({
    required String localizedReason,
    required AuthenticationOptions options,
  }) async {
    return false;
  }
}

class AuthenticationOptions {
  final bool stickyAuth;
  final bool biometricOnly;

  const AuthenticationOptions({
    required this.stickyAuth,
    required this.biometricOnly,
  });
}

