import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/search_publications.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchPublications searchPublications;

  SearchBloc({required this.searchPublications}) : super(SearchInitial()) {
    on<SearchTopicEvent>((event, emit) async {
      if (event.keyword.trim().isEmpty) {
        emit(SearchInitial());
        return;
      }

      emit(SearchLoading());

      try {
        final publications = await searchPublications(event.keyword);
        emit(SearchSuccess(publications: publications, keyword: event.keyword));
      } catch (e) {
        emit(SearchFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
