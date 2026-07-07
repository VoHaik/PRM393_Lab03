import 'package:equatable/equatable.dart';
import '../../../domain/entities/analytics_summary.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardSuccess extends DashboardState {
  final AnalyticsSummary summary;
  final String keyword;

  const DashboardSuccess({required this.summary, required this.keyword});

  @override
  List<Object?> get props => [summary, keyword];
}

class DashboardFailure extends DashboardState {
  final String errorMessage;

  const DashboardFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
