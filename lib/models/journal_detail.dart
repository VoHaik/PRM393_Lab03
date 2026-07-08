import 'publication.dart';

class JournalDetailData {
  final String id;
  final String displayName;
  final String publisher;
  final int worksCount;
  final int citedByCount;
  final double averageCitations;
  final List<Publication> relatedPublications;

  const JournalDetailData({
    required this.id,
    required this.displayName,
    required this.publisher,
    required this.worksCount,
    required this.citedByCount,
    required this.averageCitations,
    required this.relatedPublications,
  });

  factory JournalDetailData.fromJson({
    required Map<String, dynamic> sourceJson,
    required List<Publication> relatedPubs,
  }) {
    final int works = sourceJson['works_count'] as int? ?? 0;
    final int citations = sourceJson['cited_by_count'] as int? ?? 0;
    final double avg = works == 0 ? 0.0 : citations / works;

    return JournalDetailData(
      id: sourceJson['id']?.toString() ?? '',
      displayName: sourceJson['display_name']?.toString() ?? 'Unknown Journal',
      publisher: sourceJson['publisher']?.toString() ?? 'Unknown Publisher',
      worksCount: works,
      citedByCount: citations,
      averageCitations: double.parse(avg.toStringAsFixed(2)),
      relatedPublications: relatedPubs,
    );
  }
}
