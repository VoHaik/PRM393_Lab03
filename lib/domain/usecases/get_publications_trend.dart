import '../repositories/publication_repository.dart';

class GetPublicationsTrend {
  final PublicationRepository repository;

  GetPublicationsTrend(this.repository);

  Future<Map<int, int>> call(String keyword) {
    return repository.getPublicationsTrend(keyword);
  }
}
