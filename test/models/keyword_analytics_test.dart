import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/models/keyword_analytics.dart';

void main() {
  test('keyword analytics calculates growth and most active year', () {
    final analytics = KeywordAnalytics(
      id: 'https://openalex.org/topics/T1',
      name: 'Deep Learning',
      publicationCount: 48,
      totalTopicPublications: 100,
      trendByYear: const {2023: 20, 2024: 28, 2025: 48},
    );

    expect(analytics.percentage, 48.0);
    expect(analytics.latestYear, 2025);
    expect(analytics.previousYear, 2024);
    expect(analytics.growth, 20);
    expect(analytics.growthRate, closeTo(71.43, 0.01));
    expect(analytics.mostActiveYear, 2025);
  });
}
