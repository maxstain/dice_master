import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:dice_master/models/session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore;

  HomeBloc({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance,
        super(HomeInitial()) {
    on<HomeLoaded>(_onHomeLoaded);
    on<HomeStarted>(_onStarted);
    on<CreateSessionRequested>(_onCreateSessionRequested);
    on<JoinSessionRequested>(_onJoinSessionRequested);
    on<LeaveSessionRequested>(_onLeaveSessionRequested);
    // Add other event handlers here if they exist
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

  Future<void> _onSessionUpdated(
      SessionUpdated event, Emitter<HomeState> emit) async {
    // This handler would react to real-time updates from your session management system
    // For example, if a DM assigns a role or starts the game.
    // The logic here is highly dependent on your specific implementation.
    // emit(newStateBasedOnSessionUpdate);
  }
}

Future<void> _onHomeLoaded(HomeLoaded event, Emitter<HomeState> emit) async {
  final firestore = FirebaseFirestore.instance;

  emit(HomeLoading()); // Indicate loading state
  try {
    final snapshot = await firestore.collection('Sessions').get();
    // Correctly map Firestore documents to Session objects
    final sessions = snapshot.docs.map((doc) {
      // It's good practice to ensure doc.data() is not null,
      // though for get(), data should exist if the doc does.
      final data = doc.data();
      return Session.fromJson(data);
    }).toList();
    emit(HomeSuccess("Sessions loaded successfully", sessions));
  } catch (e) {
    print('Failed to load sessions: $e'); // Log the error for debugging
    emit(HomeFailure('Failed to load sessions: ${e.toString()}'));
  }
}
