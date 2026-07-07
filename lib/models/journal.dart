class Journal {
  final String id;
  final String displayName;
  final String publisher;
  final String type;
  final int publicationCount;

  const Journal({
    required this.id,
    required this.displayName,
    required this.publisher,
    required this.type,
    this.publicationCount = 0,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    final sourceMap = json['source'] as Map<String, dynamic>? ?? json;
    
    return Journal(
      id: sourceMap['id']?.toString() ?? '',
      displayName: sourceMap['display_name']?.toString() ?? 'Unknown Source',
      publisher: sourceMap['publisher']?.toString() ?? 'Unknown Publisher',
      type: sourceMap['type']?.toString() ?? 'unknown',
      publicationCount: sourceMap['works_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'publisher': publisher,
      'type': type,
      'works_count': publicationCount,
    };
  }
}
