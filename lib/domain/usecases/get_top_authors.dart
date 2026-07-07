import '../repositories/publication_repository.dart';

class GetTopAuthors {
  final PublicationRepository repository;

  GetTopAuthors(this.repository);

  Future<List<Map<String, dynamic>>> call(String keyword) {
    return repository.getTopAuthors(keyword);
  }
}
