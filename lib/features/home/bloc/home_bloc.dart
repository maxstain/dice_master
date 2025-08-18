import 'dart:async';

import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _firebaseAuth = FirebaseAuth.instance; //

  HomeBloc() : super(HomeLoading()) {
    on<HomeStarted>(_onStarted);
    on<CreateSessionRequested>(_onCreateSessionRequested);
    on<JoinSessionRequested>(_onJoinSessionRequested);
    on<LeaveSessionRequested>(_onLeaveSessionRequested);
    // It's good practice to also handle SessionUpdated,
    // but its logic will depend on how your session management is implemented.
    // on<SessionUpdated>(_onSessionUpdated);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    // Simulate startup work & auth check
    await Future.delayed(const Duration(seconds: 2));
    // Here you would typically check if the user is authenticated
    const isAuthenticated = true; // Replace with actual auth check
    if (isAuthenticated) {
      // If authenticated, go to the lobby to decide to create/join a session
      emit(HomeLobby());
    } else {
      emit(HomeNotAuthenticated());
    }
  }

  Future<void> _onCreateSessionRequested(
      CreateSessionRequested event, Emitter<HomeState> emit) async {
    // In a real app, you'd create a session and get DM details
    emit(HomeDungeonMaster(
        _firebaseAuth.currentUser!.displayName!)); // Placeholder
  }

  Future<void> _onJoinSessionRequested(
      JoinSessionRequested event, Emitter<HomeState> emit) async {
    // In a real app, you'd join a session using event.sessionId and get player details
    emit(HomePlayer(_firebaseAuth.currentUser!.displayName!)); // Placeholder
  }

  Future<void> _onLeaveSessionRequested(
      LeaveSessionRequested event, Emitter<HomeState> emit) async {
    // When leaving a session, return to the lobby
    emit(HomeLobby());
  }

// Future<void> _onSessionUpdated(
//     SessionUpdated event, Emitter<HomeState> emit) async {
//   // This handler would react to real-time updates from your session management system
//   // For example, if a DM assigns a role or starts the game.
//   // The logic here is highly dependent on your specific implementation.
//   // emit(newStateBasedOnSessionUpdate);
// }
}
