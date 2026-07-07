import 'package:equatable/equatable.dart';
import '../../../domain/entities/publication.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Publication> publications;
  final String keyword;

  const SearchSuccess({required this.publications, required this.keyword});

  @override
  List<Object?> get props => [publications, keyword];
}

class SearchFailure extends SearchState {
  final String errorMessage;

  const SearchFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
