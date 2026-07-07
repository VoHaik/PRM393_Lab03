import 'package:equatable/equatable.dart';
import 'author.dart';
import 'journal.dart';

class Publication extends Equatable {
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

  @override
  List<Object?> get props => [
        id,
        title,
        publicationYear,
        citedByCount,
        doiUrl,
        abstractText,
        authors,
        journal,
      ];
}
