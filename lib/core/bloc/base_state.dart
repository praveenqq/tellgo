import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

abstract class BaseLoadingState extends BaseState {
  const BaseLoadingState();
}

abstract class BaseErrorState extends BaseState {
  final String message;

  const BaseErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class BaseSuccessState extends BaseState {
  const BaseSuccessState();
}

