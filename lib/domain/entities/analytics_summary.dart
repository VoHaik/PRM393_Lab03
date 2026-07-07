import 'package:equatable/equatable.dart';
import 'author.dart';
import 'journal.dart';
import 'publication.dart';

class AnalyticsSummary extends Equatable {
  final int totalPublications;
  final double averageCitations;
  final int peakYear;
  final Journal? topJournal;
  final List<Journal> topJournals;
  final Author? topAuthor;
  final Publication? topPaper;

  const AnalyticsSummary({
    required this.totalPublications,
    required this.averageCitations,
    required this.peakYear,
    this.topJournal,
    this.topJournals = const [],
    this.topAuthor,
    this.topPaper,
  });

  @override
  List<Object?> get props => [
        totalPublications,
        averageCitations,
        peakYear,
        topJournal,
        topJournals,
        topAuthor,
        topPaper,
      ];
}
