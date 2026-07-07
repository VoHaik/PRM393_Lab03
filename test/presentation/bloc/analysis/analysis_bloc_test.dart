import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/domain/entities/analytics_summary.dart';
import 'package:journal_trend_analyzer/domain/entities/publication.dart';
import 'package:journal_trend_analyzer/domain/repositories/publication_repository.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_publications_trend.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_top_authors.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_top_journals.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_top_keywords.dart';
import 'package:journal_trend_analyzer/presentation/bloc/analysis/analysis_bloc.dart';
import 'package:journal_trend_analyzer/presentation/bloc/analysis/analysis_event.dart';
import 'package:journal_trend_analyzer/presentation/bloc/analysis/analysis_state.dart';

class FakePublicationRepository implements PublicationRepository {
  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<Publication> getPublicationById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
    return {2024: 7};
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) async {
    return [
      {'key_display_name': 'Ada Lovelace', 'count': 12},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/S123',
        'key_display_name': 'Journal of Machine Learning Research',
        'count': 42,
      },
      {
        'key': 'https://openalex.org/S456',
        'key_display_name': 'Nature Machine Intelligence',
        'count': 24,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) async {
    return [
      {'key_display_name': 'machine learning', 'count': 18},
    ];
  }

  @override
  Future<List<Publication>> searchPublications(String keyword) {
    throw UnimplementedError();
  }
}

void main() {
  test('fetch analysis emits top journals from repository aggregation', () async {
    final repository = FakePublicationRepository();
    final bloc = AnalysisBloc(
      getPublicationsTrend: GetPublicationsTrend(repository),
      getTopKeywords: GetTopKeywords(repository),
      getTopAuthors: GetTopAuthors(repository),
      getTopJournals: GetTopJournals(repository),
    );
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AnalysisLoading>(),
        isA<AnalysisSuccess>().having(
          (state) => state.topJournals,
          'topJournals',
          hasLength(2),
        ).having(
          (state) => state.topJournals.first['key_display_name'],
          'first journal name',
          'Journal of Machine Learning Research',
        ).having(
          (state) => state.topJournals.first['count'],
          'first journal count',
          42,
        ),
      ]),
    );

    bloc.add(const FetchAnalysisEvent('machine learning'));

    await expectation;
  });
}
