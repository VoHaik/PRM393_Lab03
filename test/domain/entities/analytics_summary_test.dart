import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/domain/entities/analytics_summary.dart';
import 'package:journal_trend_analyzer/domain/entities/journal.dart';

void main() {
  test('stores a ranked list of top journals for journal analytics', () {
    const journals = [
      Journal(
        id: 'https://openalex.org/S1',
        displayName: 'Journal One',
        publisher: 'Various Publishers',
        type: 'journal',
        publicationCount: 42,
      ),
      Journal(
        id: 'https://openalex.org/S2',
        displayName: 'Journal Two',
        publisher: 'Various Publishers',
        type: 'journal',
        publicationCount: 24,
      ),
    ];

    final summary = AnalyticsSummary(
      totalPublications: 10,
      averageCitations: 5,
      peakYear: 2024,
      topJournal: journals.first,
      topJournals: journals,
    );

    expect(summary.topJournal, journals.first);
    expect(summary.topJournals, hasLength(2));
    expect(summary.topJournals.last.displayName, 'Journal Two');
    expect(summary.topJournals.first.publicationCount, 42);
  });
}
