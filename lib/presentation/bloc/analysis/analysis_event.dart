import 'package:equatable/equatable.dart';

abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object?> get props => [];
}

class FetchAnalysisEvent extends AnalysisEvent {
  final String keyword;

  const FetchAnalysisEvent(this.keyword);

  @override
  List<Object?> get props => [keyword];
}
