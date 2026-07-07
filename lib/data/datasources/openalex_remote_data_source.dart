import '../../core/network/api_client.dart';
import '../models/publication_model.dart';

abstract class OpenAlexRemoteDataSource {
  Future<List<PublicationModel>> searchPublications(String keyword);
  Future<Map<int, int>> getPublicationsTrend(String keyword);
  Future<PublicationModel> getPublicationById(String id);
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword);
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword);
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword);
  Future<Map<String, dynamic>> getAuthorById(String id);
}

class OpenAlexRemoteDataSourceImpl implements OpenAlexRemoteDataSource {
  final ApiClient apiClient;

  OpenAlexRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PublicationModel>> searchPublications(String keyword) async {
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
          .map((json) => PublicationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to search publications');
    }
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
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
  }

  @override
  Future<PublicationModel> getPublicationById(String id) async {
    final cleanId = id.replaceAll('https://openalex.org/', '');
    final response = await apiClient.get('/works/$cleanId');

    if (response.statusCode == 200 && response.data != null) {
      return PublicationModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to get publication by ID');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
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
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) async {
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
  }

  @override
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) async {
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
  }

  @override
  Future<Map<String, dynamic>> getAuthorById(String id) async {
    final cleanId = id.replaceAll('https://openalex.org/', '');
    final response = await apiClient.get('/authors/$cleanId');

    if (response.statusCode == 200 && response.data != null) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get author by ID');
    }
  }
}
