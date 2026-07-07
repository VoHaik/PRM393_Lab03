import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/domain/entities/analytics_summary.dart';
import 'package:journal_trend_analyzer/domain/entities/publication.dart';
import 'package:journal_trend_analyzer/domain/repositories/publication_repository.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_top_journals.dart';

class FakePublicationRepository implements PublicationRepository {
  String? receivedKeyword;

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<Publication> getPublicationById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
    receivedKeyword = keyword;

    return [
      {
        'key': 'https://openalex.org/S123',
        'key_display_name': 'Journal of Machine Learning Research',
        'count': 42,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<List<Publication>> searchPublications(String keyword) {
    throw UnimplementedError();
  }
}

void main() {
  test('delegates top journal aggregation to repository', () async {
    final repository = FakePublicationRepository();
    final useCase = GetTopJournals(repository);

    final result = await useCase('artificial intelligence');

    expect(repository.receivedKeyword, 'artificial intelligence');
    expect(result, hasLength(1));
    expect(
      result.single['key_display_name'],
      'Journal of Machine Learning Research',
    );
    expect(result.single['count'], 42);
  });
}
