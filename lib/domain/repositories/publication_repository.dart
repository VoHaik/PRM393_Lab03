import '../entities/publication.dart';
import '../entities/analytics_summary.dart';

abstract class PublicationRepository {
  /// Searches for publications by a keyword topic.
  Future<List<Publication>> searchPublications(String keyword);

  /// Retrieves trend data of publication count per year for a keyword.
  Future<Map<int, int>> getPublicationsTrend(String keyword);

  /// Retrieves a summary dashboard analytics object for a keyword.
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword);

  /// Fetches detailed publication metadata by ID.
  Future<Publication> getPublicationById(String id);

  /// Aggregates top contributing journals dynamically.
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword);

  /// Aggregates top active authors dynamically.
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword);

  /// Aggregates top keywords dynamically.
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword);
}
