import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

class HomeAuthenticated extends HomeState {}

class HomeNotAuthenticated extends HomeState {}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeInitial extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeDungeonMaster extends HomeState {
  final String dungeonMasterName;

  const HomeDungeonMaster(this.dungeonMasterName);

  @override
  List<Object?> get props => [dungeonMasterName];
}

class HomePlayer extends HomeState {
  final String playerName;

  const HomePlayer(this.playerName);

  @override
  List<Object?> get props => [playerName];
}
