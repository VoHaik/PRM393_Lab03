import '../entities/analytics_summary.dart';
import '../repositories/publication_repository.dart';

class GetAnalyticsSummary {
  final PublicationRepository repository;

  GetAnalyticsSummary(this.repository);

  Future<AnalyticsSummary> call(String keyword) {
    return repository.getAnalyticsSummary(keyword);
  }
}
