import '../../core/utils/abstract_parser.dart';
import '../../domain/entities/publication.dart';
import 'author_model.dart';
import 'journal_model.dart';

class PublicationModel extends Publication {
  const PublicationModel({
    required super.id,
    required super.title,
    required super.publicationYear,
    required super.citedByCount,
    required super.doiUrl,
    required super.abstractText,
    required super.authors,
    super.journal,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> authorships = json['authorships'] as List<dynamic>? ?? [];
    final authorsList = authorships
        .map((a) => AuthorModel.fromJson(a as Map<String, dynamic>))
        .toList();

    JournalModel? parsedJournal;
    final primaryLocation = json['primary_location'] as Map<String, dynamic>?;
    if (primaryLocation != null && primaryLocation['source'] != null) {
      parsedJournal = JournalModel.fromJson(primaryLocation['source'] as Map<String, dynamic>);
    }

    final abstractIndex = json['abstract_inverted_index'] as Map<String, dynamic>?;
    final abstractReconstructed = AbstractParser.reconstruct(abstractIndex);

    return PublicationModel(
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
      'authors': authors.map((a) => (a as AuthorModel).toJson()).toList(),
      'journal': journal != null ? (journal as JournalModel).toJson() : null,
    };
  }
}
