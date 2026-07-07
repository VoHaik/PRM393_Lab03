import '../utils/abstract_parser.dart';
import 'author.dart';
import 'journal.dart';

class Publication {
  final String id;
  final String title;
  final int publicationYear;
  final int citedByCount;
  final String doiUrl;
  final String abstractText;
  final List<Author> authors;
  final Journal? journal;

  const Publication({
    required this.id,
    required this.title,
    required this.publicationYear,
    required this.citedByCount,
    required this.doiUrl,
    required this.abstractText,
    required this.authors,
    this.journal,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    final List<dynamic> authorships = json['authorships'] as List<dynamic>? ?? [];
    final authorsList = authorships
        .map((a) => Author.fromJson(a as Map<String, dynamic>))
        .toList();

    Journal? parsedJournal;
    final primaryLocation = json['primary_location'] as Map<String, dynamic>?;
    if (primaryLocation != null && primaryLocation['source'] != null) {
      parsedJournal = Journal.fromJson(primaryLocation['source'] as Map<String, dynamic>);
    }

    final abstractIndex = json['abstract_inverted_index'] as Map<String, dynamic>?;
    final abstractReconstructed = AbstractParser.reconstruct(abstractIndex);

    return Publication(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Paper',
      publicationYear: json['publication_year'] as int? ?? 0,
      citedByCount: json['cited_by_count'] as int? ?? 0,
      doiUrl: json['doi']?.toString() ?? '',
      abstractText: abstractReconstructed,
      authors: authorsList,
      journal: parsedJournal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'publication_year': publicationYear,
      'cited_by_count': citedByCount,
      'doi': doiUrl,
      'authors': authors.map((a) => a.toJson()).toList(),
      'journal': journal?.toJson(),
    };
  }
}
