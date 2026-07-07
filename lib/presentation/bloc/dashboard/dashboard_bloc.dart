import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_analytics_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetAnalyticsSummary getAnalyticsSummary;

  DashboardBloc({required this.getAnalyticsSummary}) : super(DashboardInitial()) {
    on<FetchDashboardEvent>((event, emit) async {
      if (event.keyword.trim().isEmpty) {
        emit(DashboardInitial());
        return;
      }

      emit(DashboardLoading());

      try {
        final summary = await getAnalyticsSummary(event.keyword);
        emit(DashboardSuccess(summary: summary, keyword: event.keyword));
      } catch (e) {
        emit(DashboardFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
