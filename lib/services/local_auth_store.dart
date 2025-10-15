import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exception used for local authentication fallback failures.
class LocalAuthException implements Exception {
  LocalAuthException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() =>
      'LocalAuthException(code: $code${message != null ? ', message: $message' : ''})';
}

/// Simple credential store used when Firebase is unavailable.
class LocalAuthStore {
  static const _accountsKey = 'safeplay.local_parent_accounts';

  /// Create a local parent account. Throws if the email already exists.
  Future<Map<String, dynamic>> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    final accounts = await _readAccounts();
    final normalizedEmail = email.trim().toLowerCase();

    final existing = accounts.firstWhere(
      (account) =>
          (account['email'] as String?)?.toLowerCase() == normalizedEmail,
      orElse: () => <String, dynamic>{},
    );

    if (existing.isNotEmpty) {
      throw LocalAuthException('email-already-in-use');
    }

    final now = DateTime.now();
    final account = <String, dynamic>{
      'id': _generateId(email),
      'email': email.trim(),
      'name': name.trim().isEmpty ? _deriveNameFromEmail(email) : name.trim(),
      'passwordHash': _hashPassword(password),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'lastLoginAt': now.toIso8601String(),
    };

    accounts.add(account);
    await _writeAccounts(accounts);
    return account;
  }

  /// Authenticate against the local store.
  /// Returns account data when successful.
  Future<Map<String, dynamic>?> authenticate({
    required String email,
    required String password,
  }) async {
    final accounts = await _readAccounts();
    final normalizedEmail = email.trim().toLowerCase();
    final account = accounts.firstWhere(
      (candidate) =>
          (candidate['email'] as String?)?.toLowerCase() == normalizedEmail,
      orElse: () => <String, dynamic>{},
    );

    if (account.isEmpty) {
      return null;
    }

    final storedHash = account['passwordHash'] as String?;
    if (storedHash == null || storedHash != _hashPassword(password)) {
      throw LocalAuthException('wrong-password');
    }

    await updateLastLogin(account['id'] as String);
    return account;
  }

  /// Update last login timestamp for an account.
  Future<void> updateLastLogin(String accountId) async {
    final accounts = await _readAccounts();
    final index = accounts.indexWhere((account) => account['id'] == accountId);
    if (index == -1) return;

    final now = DateTime.now().toIso8601String();
    accounts[index]['lastLoginAt'] = now;
    accounts[index]['updatedAt'] = now;
    await _writeAccounts(accounts);
  }

  Future<List<Map<String, dynamic>>> _readAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((entry) => entry.map((key, value) => MapEntry('$key', value)))
            .toList();
      }
    } catch (_) {
      // If decoding fails, reset the store to avoid cascading failures.
    }

    return <Map<String, dynamic>>[];
  }

  Future<void> _writeAccounts(List<Map<String, dynamic>> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(accounts));
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _generateId(String email) {
    final seed =
        '${email.trim().toLowerCase()}-${DateTime.now().microsecondsSinceEpoch}';
    return 'local-${sha1.convert(utf8.encode(seed))}';
  }

  String _deriveNameFromEmail(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) {
      return 'SafePlay Parent';
    }

    return localPart
        .split(RegExp(r'[._-]+'))
        .where((segment) => segment.isNotEmpty)
        .map((segment) =>
            segment[0].toUpperCase() + segment.substring(1).toLowerCase())
        .join(' ');
  }
}
