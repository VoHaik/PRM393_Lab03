import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardEvent extends DashboardEvent {
  final String keyword;

  const FetchDashboardEvent(this.keyword);

  @override
  List<Object?> get props => [keyword];
}
