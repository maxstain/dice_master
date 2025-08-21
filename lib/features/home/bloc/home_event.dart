import 'package:dice_master/models/session.dart';
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

class LeaveSessionRequested extends HomeEvent {
  const LeaveSessionRequested();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();

  @override
  List<Object?> get props => [];
}

// The HomeLoaded event can be used to trigger UI updates
class HomeLoaded extends HomeEvent {
  final String message;
  final List<Session> sessions;

  const HomeLoaded(this.message, this.sessions);

  @override
  List<Object?> get props => [message, sessions];
}
