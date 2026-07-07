import '../entities/publication.dart';
import '../repositories/publication_repository.dart';

class SearchPublications {
  final PublicationRepository repository;

  SearchPublications(this.repository);

  Future<List<Publication>> call(String keyword) {
    return repository.searchPublications(keyword);
  }
}
