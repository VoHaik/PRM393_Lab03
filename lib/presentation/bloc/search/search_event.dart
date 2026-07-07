import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchTopicEvent extends SearchEvent {
  final String keyword;

  const SearchTopicEvent(this.keyword);

  @override
  List<Object?> get props => [keyword];
}
