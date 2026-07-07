import '../../domain/entities/author.dart';

class AuthorModel extends Author {
  const AuthorModel({
    required super.id,
    required super.displayName,
    required super.orcid,
    super.worksCount,
    super.citedByCount,
    super.institution,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    // OpenAlex authorships structure returns map with 'author' key
    final authorMap = json['author'] as Map<String, dynamic>? ?? json;
    
    // Check if institution is available in affiliations list
    String? instName;
    final affiliations = json['affiliations'] as List<dynamic>? ?? authorMap['affiliations'] as List<dynamic>?;
    if (affiliations != null && affiliations.isNotEmpty) {
      final firstAff = affiliations.first as Map<String, dynamic>?;
      if (firstAff != null) {
        final inst = firstAff['institution'] as Map<String, dynamic>?;
        if (inst != null) {
          instName = inst['display_name']?.toString();
        }
      }
    }
    
    // Also check last_known_institutions as fallback
    final lastKnown = json['last_known_institutions'] as List<dynamic>? ?? authorMap['last_known_institutions'] as List<dynamic>?;
    if (instName == null && lastKnown != null && lastKnown.isNotEmpty) {
      final firstInst = lastKnown.first as Map<String, dynamic>?;
      if (firstInst != null) {
        instName = firstInst['display_name']?.toString();
      }
    }

    return AuthorModel(
      id: authorMap['id']?.toString() ?? '',
      displayName: authorMap['display_name']?.toString() ?? 'Unknown Author',
      orcid: authorMap['orcid']?.toString() ?? '',
      worksCount: json['works_count'] as int? ?? authorMap['works_count'] as int?,
      citedByCount: json['cited_by_count'] as int? ?? authorMap['cited_by_count'] as int?,
      institution: instName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'orcid': orcid,
      'works_count': worksCount,
      'cited_by_count': citedByCount,
      'institution': institution,
    };
  }
}
