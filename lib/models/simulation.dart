/// Simulation model for PhET and other interactive simulations
class Simulation {
  final String id;
  final String title;
  final String description;
  final String iframeUrl;
  final String? thumbnailPath;
  final List<String> topics;
  final List<String> learningGoals;
  final String scientificExplanation;
  final String warning;
  final int estimatedMinutes;
  final String difficulty; // 'Easy Peasy', 'Medium', 'Challenge'
  final String ageGroup; // 'bright', 'junior'

  const Simulation({
    required this.id,
    required this.title,
    required this.description,
    required this.iframeUrl,
    this.thumbnailPath,
    required this.topics,
    required this.learningGoals,
    required this.scientificExplanation,
    required this.warning,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.ageGroup,
  });

  factory Simulation.fromJson(Map<String, dynamic> json) {
    return Simulation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iframeUrl: json['iframeUrl'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      topics: List<String>.from(json['topics'] as List),
      learningGoals: List<String>.from(json['learningGoals'] as List),
      scientificExplanation: json['scientificExplanation'] as String,
      warning: json['warning'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      difficulty: json['difficulty'] as String,
      ageGroup: json['ageGroup'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iframeUrl': iframeUrl,
      'thumbnailPath': thumbnailPath,
      'topics': topics,
      'learningGoals': learningGoals,
      'scientificExplanation': scientificExplanation,
      'warning': warning,
      'estimatedMinutes': estimatedMinutes,
      'difficulty': difficulty,
      'ageGroup': ageGroup,
    };
  }
}
