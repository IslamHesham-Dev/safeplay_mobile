class BrowserActivityInsight {
  const BrowserActivityInsight({
    required this.summary,
    required this.category,
    required this.timeframe,
    required this.tone,
  });

  final String summary;
  final String category;
  final String timeframe;
  final String tone;

  factory BrowserActivityInsight.fromJson(Map<String, dynamic> json) {
    return BrowserActivityInsight(
      summary: json['summary']?.toString() ?? 'Activity insight',
      category: json['category']?.toString() ?? 'General',
      timeframe: json['timeframe']?.toString() ?? 'Recently',
      tone: json['tone']?.toString() ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'category': category,
        'timeframe': timeframe,
        'tone': tone,
      };
}
