import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class CreateSessionRequested extends HomeEvent {}

class JoinSessionRequested extends HomeEvent {
  final String sessionId;

  const JoinSessionRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class SessionUpdated extends HomeEvent {
  // You might want to add properties here to reflect session changes
  // For example: final UserRole userRole;
  const SessionUpdated();

  @override
  List<Object?> get props => [];
}

class LeaveSessionRequested extends HomeEvent {}

class HomeStarted extends HomeEvent {
  const HomeStarted();

  @override
  List<Object?> get props => [];
}
