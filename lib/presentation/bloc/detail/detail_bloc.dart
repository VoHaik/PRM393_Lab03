import 'package:flutter_bloc/flutter_bloc.dart';
import 'detail_event.dart';
import 'detail_state.dart';

import '../../../domain/usecases/get_publication_by_id.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final GetPublicationById getPublicationById;

  DetailBloc({required this.getPublicationById}) : super(DetailInitial()) {
    on<SelectPublicationEvent>((event, emit) {
      emit(DetailLoaded(event.publication));
    });
  }
}
