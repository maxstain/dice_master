import 'package:dice_master/models/session.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];

  get sessions => null;
}

class HomeLoading extends HomeState {}

class HomeAuthenticated extends HomeState {}

class HomeLobby extends HomeState {}

class HomeNotAuthenticated extends HomeState {}

class HomeSession extends HomeState {
  final String sessionId;

  const HomeSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeSuccess extends HomeState {
  final String message;
  final List<Session>? sessions;

  const HomeSuccess(this.message, this.sessions);

  @override
  List<Object?> get props => [message, sessions];
}

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

class HomeSessionCreated extends HomeState {
  final String sessionId;

  const HomeSessionCreated(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class HomeSessionJoined extends HomeState {
  final String sessionId;

  const HomeSessionJoined(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class HomeSessionLeft extends HomeState {
  final String sessionId;

  const HomeSessionLeft(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class HomeSessionUpdated extends HomeState {
  final String sessionId;
  final String updatedInfo;

  const HomeSessionUpdated(this.sessionId, this.updatedInfo);

  @override
  List<Object?> get props => [sessionId, updatedInfo];
}

class HomeSessionError extends HomeState {
  final String sessionId;
  final String errorMessage;

  const HomeSessionError(this.sessionId, this.errorMessage);

  @override
  List<Object?> get props => [sessionId, errorMessage];
}
