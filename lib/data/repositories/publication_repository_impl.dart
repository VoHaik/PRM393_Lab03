import 'package:dio/dio.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/publication.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/journal.dart';
import '../../domain/repositories/publication_repository.dart';
import '../datasources/openalex_remote_data_source.dart';
import '../models/publication_model.dart';
import '../../core/network/api_client.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  final OpenAlexRemoteDataSource remoteDataSource;
  final ApiClient apiClient;

  PublicationRepositoryImpl({
    required this.remoteDataSource,
    required this.apiClient,
  });

  @override
  Future<List<Publication>> searchPublications(String keyword) async {
    try {
      final models = await remoteDataSource.searchPublications(keyword);
      return models;
    } catch (e) {
      throw Exception('Search publications failed: $e');
    }
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
    try {
      return await remoteDataSource.getPublicationsTrend(keyword);
    } catch (e) {
      throw Exception('Get publication trends failed: $e');
    }
  }

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword) async {
    try {
      // Execute all API queries in parallel for optimal load times
      final results = await Future.wait([
        apiClient.get(
          '/works',
          queryParameters: {
            'search': keyword,
            'sort': 'cited_by_count:desc',
            'per_page': 50,
          },
        ),
        remoteDataSource.getPublicationsTrend(keyword),
        remoteDataSource.getTopJournals(keyword),
        remoteDataSource.getTopAuthors(keyword),
      ]);

      final searchResponse = results[0] as Response;
      final trends = results[1] as Map<int, int>;
      final topJournalsData = results[2] as List<Map<String, dynamic>>;
      final topAuthorsData = results[3] as List<Map<String, dynamic>>;

      int totalPublications = 0;
      List<PublicationModel> publications = [];

      if (searchResponse.statusCode == 200) {
        totalPublications = searchResponse.data['meta']?['count'] as int? ?? 0;
        final List<dynamic> searchResults = searchResponse.data['results'] as List<dynamic>? ?? [];
        publications = searchResults
            .map((json) => PublicationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Calculate peak publication year from trend API results
      int peakYear = 0;
      int maxCount = -1;
      trends.forEach((year, count) {
        if (count > maxCount) {
          maxCount = count;
          peakYear = year;
        }
      });

      if (publications.isEmpty) {
        return AnalyticsSummary(
          totalPublications: totalPublications,
          averageCitations: 0,
          peakYear: peakYear,
        );
      }

      // Calculate average citation count of the top 50 publications
      double sumCitations = 0;
      for (var pub in publications) {
        sumCitations += pub.citedByCount;
      }
      final averageCitations = sumCitations / publications.length;

      // Top Paper is the most cited one (first in the desc-sorted list)
      final topPaper = publications.first;

      // Extract ranked top journal sources from the API group_by results.
      final topJournals = topJournalsData
          .where((journalMap) {
            final displayName = journalMap['key_display_name']?.toString().trim() ?? '';
            return displayName.isNotEmpty && displayName.toLowerCase() != 'unknown';
          })
          .take(5)
          .map((journalMap) {
            final keyId = journalMap['key']?.toString() ?? '';
            final displayName = journalMap['key_display_name']?.toString() ?? 'Unknown Source';
            return Journal(
              id: keyId,
              displayName: displayName,
              publisher: 'Various Publishers',
              type: 'journal',
              publicationCount: journalMap['count'] as int? ?? 0,
            );
          })
          .toList();
      final topJournal = topJournals.isNotEmpty ? topJournals.first : null;

      // Extract Top Author from the API group_by results
      Author? topAuthor;
      if (topAuthorsData.isNotEmpty) {
        Map<String, dynamic>? firstValidAuthor;
        for (var authorMap in topAuthorsData) {
          final displayName = authorMap['key_display_name']?.toString() ?? '';
          if (_isValidAuthorName(displayName)) {
            firstValidAuthor = authorMap;
            break;
          }
        }

        if (firstValidAuthor != null) {
          final keyId = firstValidAuthor['key']?.toString() ?? '';
          final displayName = firstValidAuthor['key_display_name']?.toString() ?? 'Unknown Author';
          
          try {
            // Fetch live detailed author profile to get ORCID and metadata
            final profile = await remoteDataSource.getAuthorById(keyId);
            final orcid = profile['orcid']?.toString() ?? '';
            final worksCount = profile['works_count'] as int?;
            final citedByCount = profile['cited_by_count'] as int?;
            
            String? institution;
            final lastKnown = profile['last_known_institutions'] as List<dynamic>?;
            if (lastKnown != null && lastKnown.isNotEmpty) {
              institution = lastKnown.first['display_name']?.toString();
            }

            topAuthor = Author(
              id: keyId,
              displayName: displayName,
              orcid: orcid,
              worksCount: worksCount,
              citedByCount: citedByCount,
              institution: institution,
            );
          } catch (_) {
            topAuthor = Author(
              id: keyId,
              displayName: displayName,
              orcid: '',
            );
          }
        }
      }

      return AnalyticsSummary(
        totalPublications: totalPublications,
        averageCitations: double.parse(averageCitations.toStringAsFixed(2)),
        peakYear: peakYear,
        topPaper: topPaper,
        topAuthor: topAuthor,
        topJournal: topJournal,
        topJournals: topJournals,
      );
    } catch (e) {
      throw Exception('Get analytics summary failed: $e');
    }
  }

  @override
  Future<Publication> getPublicationById(String id) async {
    try {
      return await remoteDataSource.getPublicationById(id);
    } catch (e) {
      throw Exception('Get publication details by ID failed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
    try {
      return await remoteDataSource.getTopJournals(keyword);
    } catch (e) {
      throw Exception('Get top journals failed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) async {
    try {
      return await remoteDataSource.getTopAuthors(keyword);
    } catch (e) {
      throw Exception('Get top authors failed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) async {
    try {
      return await remoteDataSource.getTopKeywords(keyword);
    } catch (e) {
      throw Exception('Get top keywords failed: $e');
    }
  }

  bool _isValidAuthorName(String name) {
    final cleanName = name.trim().toLowerCase();
    if (cleanName.isEmpty) return false;
    if (cleanName == 'certification exam') return false;
    if (cleanName == 'system administrator') return false;
    if (cleanName == 'unknown author') return false;
    if (cleanName == 'various authors') return false;
    if (cleanName == 'anonymous') return false;
    if (cleanName.contains('proceedings') || cleanName.contains('conference') || cleanName.contains('committee')) return false;
    // Exclude strings that look like generic publisher names or numbers
    if (RegExp(r'^[0-9\W_]+$').hasMatch(cleanName)) return false;
    return true;
  }
}
