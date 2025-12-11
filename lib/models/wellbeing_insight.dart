class WellbeingInsight {
  const WellbeingInsight({
    required this.summary,
    required this.category,
    required this.timeframe,
    required this.tone,
  });

  final String summary;
  final String category;
  final String timeframe;
  final String tone;

  factory WellbeingInsight.fromJson(Map<String, dynamic> json) {
    return WellbeingInsight(
      summary: json['summary']?.toString() ?? 'Wellbeing insight',
      category: json['category']?.toString() ?? 'General',
      timeframe: json['timeframe']?.toString() ?? 'Recent check-ins',
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
