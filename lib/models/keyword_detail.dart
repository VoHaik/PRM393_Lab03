import 'publication.dart';

class KeywordDetailData {
  final String keyword;
  final Map<int, int> trendByYear;
  final List<Map<String, dynamic>> relatedJournals;
  final List<Publication> relatedPublications;
  final List<Map<String, dynamic>> topAuthors;

  const KeywordDetailData({
    required this.keyword,
    required this.trendByYear,
    required this.relatedJournals,
    required this.relatedPublications,
    required this.topAuthors,
  });
}
