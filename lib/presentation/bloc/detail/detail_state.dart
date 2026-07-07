import 'package:equatable/equatable.dart';
import '../../../domain/entities/publication.dart';

abstract class DetailState extends Equatable {
  const DetailState();

  @override
  List<Object?> get props => [];
}

class DetailInitial extends DetailState {}

class DetailLoaded extends DetailState {
  final Publication publication;

  const DetailLoaded(this.publication);

  @override
  List<Object?> get props => [publication];
}
