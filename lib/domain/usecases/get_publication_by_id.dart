import '../entities/publication.dart';
import '../repositories/publication_repository.dart';

class GetPublicationById {
  final PublicationRepository repository;

  GetPublicationById(this.repository);

  Future<Publication> call(String id) {
    return repository.getPublicationById(id);
  }
}
