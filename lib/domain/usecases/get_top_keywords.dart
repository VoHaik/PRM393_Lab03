import '../repositories/publication_repository.dart';

class GetTopKeywords {
  final PublicationRepository repository;

  GetTopKeywords(this.repository);

  Future<List<Map<String, dynamic>>> call(String keyword) {
    return repository.getTopKeywords(keyword);
  }
}
