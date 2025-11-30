/// Centralized access to compile-time environment variables.
/// 
/// These values are provided via `--dart-define` when running or building
/// the Flutter application so secrets stay out of source control.
class EnvConfig {
  EnvConfig._();

  /// OpenRouter API key for DeepSeek access.
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  /// Optional `Referer` header value for OpenRouter leaderboard attribution.
  static const String openRouterReferer = String.fromEnvironment(
    'OPENROUTER_APP_URL',
    defaultValue: 'https://safeplay.app',
  );

  /// Optional `X-Title` header value for OpenRouter leaderboard attribution.
  static const String openRouterAppName = String.fromEnvironment(
    'OPENROUTER_APP_NAME',
    defaultValue: 'SafePlay Mobile',
  );
}
