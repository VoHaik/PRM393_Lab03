import 'package:equatable/equatable.dart';
import '../../../domain/entities/publication.dart';

abstract class DetailEvent extends Equatable {
  const DetailEvent();

  @override
  List<Object?> get props => [];
}

class SelectPublicationEvent extends DetailEvent {
  final Publication publication;

  const SelectPublicationEvent(this.publication);

  @override
  List<Object?> get props => [publication];
}
