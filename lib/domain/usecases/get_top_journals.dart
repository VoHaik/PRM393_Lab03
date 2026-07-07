import '../repositories/publication_repository.dart';

class GetTopJournals {
  final PublicationRepository repository;

  GetTopJournals(this.repository);

  Future<List<Map<String, dynamic>>> call(String keyword) {
    return repository.getTopJournals(keyword);
  }
}
