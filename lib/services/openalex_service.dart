import 'package:dio/dio.dart';
import '../models/analytics_summary.dart';
import '../models/author.dart';
import '../models/journal.dart';
import '../models/publication.dart';
import '../utils/network/api_client.dart';

class OpenAlexService {
  final ApiClient apiClient;

  OpenAlexService({required this.apiClient});

  Future<List<Publication>> searchPublications(String keyword) async {
    try {
      final response = await apiClient.get(
        '/works',
        queryParameters: {
          'search': keyword,
          'sort': 'cited_by_count:desc',
          'per_page': 50,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'] as List<dynamic>? ?? [];
        return results
            .map((json) => Publication.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search publications');
      }
    } catch (e) {
      throw Exception('Search publications failed: $e');
    }
  }

  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
    try {
      final response = await apiClient.get(
        '/works',
        queryParameters: {
          'search': keyword,
          'group_by': 'publication_year',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> groups = response.data['group_by'] as List<dynamic>? ?? [];
        final Map<int, int> trends = {};
        for (var group in groups) {
          final yearStr = group['key']?.toString();
          final count = group['count'] as int?;
          if (yearStr != null && count != null) {
            final year = int.tryParse(yearStr);
            if (year != null) {
              trends[year] = count;
            }
          }
        }
        return trends;
      } else {
        throw Exception('Failed to get publication trends');
      }
    } catch (e) {
      throw Exception('Get publication trends failed: $e');
    }
  }

  Future<Publication> getPublicationById(String id) async {
    try {
      final cleanId = id.replaceAll('https://openalex.org/', '');
      final response = await apiClient.get('/works/$cleanId');

      if (response.statusCode == 200 && response.data != null) {
        return Publication.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get publication by ID');
      }
    } catch (e) {
      throw Exception('Get publication details by ID failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
    try {
      final response = await apiClient.get(
        '/works',
        queryParameters: {
          'search': keyword,
          'group_by': 'primary_location.source.id',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> groups = response.data['group_by'] as List<dynamic>? ?? [];
        return groups.map((g) => Map<String, dynamic>.from(g as Map)).toList();
      } else {
        throw Exception('Failed to get top journals');
      }
    } catch (e) {
      throw Exception('Get top journals failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) async {
    try {
      final response = await apiClient.get(
        '/works',
        queryParameters: {
          'search': keyword,
          'group_by': 'authorships.author.id',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> groups = response.data['group_by'] as List<dynamic>? ?? [];
        return groups.map((g) => Map<String, dynamic>.from(g as Map)).toList();
      } else {
        throw Exception('Failed to get top authors');
      }
    } catch (e) {
      throw Exception('Get top authors failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) async {
    try {
      final response = await apiClient.get(
        '/works',
        queryParameters: {
          'search': keyword,
          'group_by': 'topics.id',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> groups = response.data['group_by'] as List<dynamic>? ?? [];
        return groups.map((g) => Map<String, dynamic>.from(g as Map)).toList();
      } else {
        throw Exception('Failed to get top keywords');
      }
    } catch (e) {
      throw Exception('Get top keywords failed: $e');
    }
  }

  Future<Map<String, dynamic>> getAuthorById(String id) async {
    try {
      final cleanId = id.replaceAll('https://openalex.org/', '');
      final response = await apiClient.get('/authors/$cleanId');

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get author by ID');
      }
    } catch (e) {
      throw Exception('Failed to get author by ID: $e');
    }
  }

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
        getPublicationsTrend(keyword),
        getTopJournals(keyword),
        getTopAuthors(keyword),
      ]);

      final searchResponse = results[0] as Response;
      final trends = results[1] as Map<int, int>;
      final topJournalsData = results[2] as List<Map<String, dynamic>>;
      final topAuthorsData = results[3] as List<Map<String, dynamic>>;

      int totalPublications = 0;
      List<Publication> publications = [];

      if (searchResponse.statusCode == 200) {
        totalPublications = searchResponse.data['meta']?['count'] as int? ?? 0;
        final List<dynamic> searchResults = searchResponse.data['results'] as List<dynamic>? ?? [];
        publications = searchResults
            .map((json) => Publication.fromJson(json as Map<String, dynamic>))
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
            final profile = await getAuthorById(keyId);
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

  bool _isValidAuthorName(String name) {
    if (name.isEmpty) return false;
    final lower = name.toLowerCase();
    if (lower == 'unknown' ||
        lower.contains('anonymous') ||
        lower.contains('exam') ||
        lower.contains('collaboration') ||
        lower.contains('association') ||
        lower.contains('group')) {
      return false;
    }
    return true;
  }
}
