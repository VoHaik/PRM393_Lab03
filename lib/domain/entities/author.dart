import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String id;
  final String displayName;
  final String orcid;
  final int? worksCount;
  final int? citedByCount;
  final String? institution;

  const Author({
    required this.id,
    required this.displayName,
    required this.orcid,
    this.worksCount,
    this.citedByCount,
    this.institution,
  });

  @override
  List<Object?> get props => [
        id,
        displayName,
        orcid,
        worksCount,
        citedByCount,
        institution,
      ];
}
