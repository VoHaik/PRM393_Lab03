class KeywordAnalytics {
  final String id;
  final String name;
  final int publicationCount;
  final int totalTopicPublications;
  final Map<int, int> trendByYear;

  const KeywordAnalytics({
    required this.id,
    required this.name,
    required this.publicationCount,
    required this.totalTopicPublications,
    required this.trendByYear,
  });

  double get percentage {
    if (totalTopicPublications <= 0) {
      return 0;
    }
    return double.parse(
      ((publicationCount / totalTopicPublications) * 100).toStringAsFixed(2),
    );
  }

  int get latestYear {
    if (trendByYear.isEmpty) {
      return 0;
    }
    return trendByYear.keys.reduce((a, b) => a > b ? a : b);
  }

  int get previousYear {
    final sortedYears = trendByYear.keys.toList()..sort();
    if (sortedYears.length < 2) {
      return 0;
    }
    return sortedYears[sortedYears.length - 2];
  }

  int get growth {
    if (latestYear == 0 || previousYear == 0) {
      return 0;
    }
    return (trendByYear[latestYear] ?? 0) - (trendByYear[previousYear] ?? 0);
  }

  double get growthRate {
    if (previousYear == 0) {
      return 0;
    }
    final previousValue = trendByYear[previousYear] ?? 0;
    if (previousValue <= 0) {
      return growth > 0 ? 100 : 0;
    }
    return double.parse(((growth / previousValue) * 100).toStringAsFixed(2));
  }

  int get mostActiveYear {
    if (trendByYear.isEmpty) {
      return 0;
    }
    return trendByYear.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
