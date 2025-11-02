/// Custom exception for publishing errors
class PublishingException implements Exception {
  final String message;
  final String? activityId;

  const PublishingException({
    required this.message,
    this.activityId,
  });

  @override
  String toString() => message;
}
