import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:dice_master/models/campaign.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'campaign_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore;

  HomeBloc({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance,
        super(HomeInitial()) {
    // Start with HomeInitial
    on<TriggerInitialLoad>(_onTriggerInitialLoadHandler);
    on<HomeStarted>(_onHomeStartedHandler); // For user-initiated refresh
    on<CreateCampaignRequested>(_onCreateCampaignRequestedHandler);
    on<JoinCampaignRequested>(_onJoinCampaignRequestedHandler);
    on<LeaveCampaignRequested>(_onLeaveCampaignRequestedHandler);
    // on<CampaignUpdated>(_onCampaignUpdated); // If you have this handler

    add(const TriggerInitialLoad()); // Dispatch the initial load event
  }

  Future<void> _onTriggerInitialLoadHandler(
      TriggerInitialLoad event, Emitter<HomeState> emit) async {
    print(
        "HomeBloc: _onTriggerInitialLoadHandler triggered for initial data load.");
    // Only proceed if we are in an initial or failed state to avoid redundant loads on hot reload with BLoC already loaded
    if (state is HomeInitial ||
        state is HomeFailure ||
        state is HomeNotAuthenticated) {
      await _loadCampaigns(emit, isRefresh: false);
    } else {
      print(
          "HomeBloc: Initial load triggered but state is already ${state.runtimeType}. Campaigns might already be loaded or loading.");
      // If state is HomeSuccess, it means campaigns are loaded. If HomeLoading, it's in progress.
      // If you want TriggerInitialLoad to ALWAYS reload, then remove this if condition.
      // For now, this makes initial load idempotent if BLoC is preserved across hot restarts and already loaded.
    }
  }

  Future<void> _onHomeStartedHandler(
      // This is for user-initiated refresh
      HomeStarted event,
      Emitter<HomeState> emit) async {
    print("HomeBloc: _onHomeStartedHandler triggered (user refresh).");
    await _loadCampaigns(emit, isRefresh: true);
  }

  Future<void> _loadCampaigns(Emitter<HomeState> emit,
      {required bool isRefresh}) async {
    print(
        "HomeBloc: _loadCampaigns called. isRefresh: $isRefresh, currentState: ${state.runtimeType}");
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      print(
          "HomeBloc: User not authenticated during _loadCampaigns. Emitting HomeNotAuthenticated.");
      emit(HomeNotAuthenticated());
      return;
    }

    // Only emit HomeLoading if not already loading, or if it's a forced refresh from a stable state
    if (state is HomeLoading && !isRefresh) {
      // Avoid emitting loading if already loading unless it's a refresh
      print(
          "HomeBloc: Already in HomeLoading state and not a refresh. Aborting redundant _loadCampaigns call.");
      return;
    }

    print(
        "HomeBloc: User authenticated. Proceeding to load campaigns in _loadCampaigns.");
    emit(HomeLoading());
    print("HomeBloc: Emitted HomeLoading state from _loadCampaigns.");

    try {
      final snapshot = await firestore.collection('campaigns').get();
      print(
          "HomeBloc: Fetched ${snapshot.docs.length} campaigns from Firestore in _loadCampaigns.");

      if (snapshot.docs.isEmpty) {
        print(
            "HomeBloc: No campaigns found in Firestore. Emitting HomeSuccess with empty list from _loadCampaigns.");
        emit(const HomeSuccess("No campaigns found.", []));
        return;
      }

      final campaigns = snapshot.docs.map((doc) {
        print("HomeBloc: Mapping document ID: ${doc.id}");
        final data = doc.data();
        return Campaign.fromJson(data);
      }).toList();

      print(
          "HomeBloc: Successfully mapped ${campaigns.length} campaigns in _loadCampaigns.");
      emit(HomeSuccess("Campaigns loaded successfully", campaigns));
      print(
          "HomeBloc: Emitted HomeSuccess state with campaigns from _loadCampaigns.");
    } catch (e, stackTrace) {
      print('HomeBloc: Failed to load campaigns in _loadCampaigns: $e');
      print('HomeBloc: Stacktrace for _loadCampaigns failure: $stackTrace');
      emit(HomeFailure('Failed to load campaigns: ${e.toString()}'));
      print("HomeBloc: Emitted HomeFailure state from _loadCampaigns.");
    }
  }

  Future<void> _onCreateCampaignRequestedHandler(
      CreateCampaignRequested event, Emitter<HomeState> emit) async {
    print(
        "HomeBloc: _onCreateCampaignRequestedHandler triggered with name: ${event.campaignName}");
    // emit(HomeLoading()); // Don't emit HomeLoading here if UI handles it, or if it makes UI jumpy
    // The list will refresh via HomeStarted after creation.
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(HomeFailure('User not authenticated to create a campaign.'));
      print("HomeBloc: User not authenticated for CreateCampaignRequested.");
      return;
    }

    try {
      DocumentReference ref = await firestore.collection('campaigns').add({
        'title': event.campaignName ?? 'New Campaign',
        'hostId': currentUser.uid,
        'players': [],
        'sessionCode': FirebaseFirestore.instance
            .collection('campaigns')
            .doc()
            .id
            .substring(0, 6)
            .toUpperCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // 'id': null, // ID will be set in the next step
      });

      await ref
          .update({'id': ref.id}); // Store the document ID within the document
      print("HomeBloc: Campaign created with ID: ${ref.id}");

      // Instead of HomeStarted which reloads all, consider optimistically updating or a specific "CampaignAdded" state.
      // For now, refreshing all campaigns:
      add(const HomeStarted()); // This will trigger _loadCampaigns with isRefresh: true
    } catch (e, stackTrace) {
      print('HomeBloc: Failed to create campaign: $e');
      print('HomeBloc: Stacktrace for campaign creation failure: $stackTrace');
      emit(HomeFailure('Failed to create campaign: ${e.toString()}'));
    }
  }

  Future<void> _onJoinCampaignRequestedHandler(
      JoinCampaignRequested event, Emitter<HomeState> emit) async {
    print(
        "HomeBloc: _onJoinCampaignRequestedHandler triggered for campaign ID: ${event.campaignId}");
    // emit(HomeLoading()); // Similar to create, consider UI impact.
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(HomeFailure('User not authenticated to join a campaign.'));
      print("HomeBloc: User not authenticated for JoinCampaignRequested.");
      return;
    }

    try {
      final campaignDocRef =
          firestore.collection('campaigns').doc(event.campaignId);
      final campaignDoc = await campaignDocRef.get();

      if (!campaignDoc.exists) {
        emit(HomeFailure('Campaign with ID ${event.campaignId} not found.'));
        print("HomeBloc: Campaign ${event.campaignId} not found for joining.");
        return;
      }

      await campaignDocRef.update({
        'players': FieldValue.arrayUnion([currentUser.uid])
      });

      print(
          "HomeBloc: User ${currentUser.uid} joined campaign ${event.campaignId}");
      // After joining, refresh the campaign list to show updated player counts etc.
      add(const HomeStarted()); // This will trigger _loadCampaigns with isRefresh: true
    } catch (e, stackTrace) {
      print('HomeBloc: Failed to join campaign: $e');
      print('HomeBloc: Stacktrace for campaign joining failure: $stackTrace');
      emit(HomeFailure('Failed to join campaign: ${e.toString()}'));
    }
  }

  Future<void> _onLeaveCampaignRequestedHandler(
      // Basic structure
      LeaveCampaignRequested event,
      Emitter<HomeState> emit) async {
    print("HomeBloc: _onLeaveCampaignRequestedHandler triggered.");
    // Actual logic to remove player from Firestore campaign document would go here.
    // Example:
    // final currentUser = _firebaseAuth.currentUser;
    // if (currentUser != null && state is HomePlayer) { // Assuming state holds current campaign
    //   final campaignId = (state as HomePlayer).campaignId; // Need campaignId to leave
    //   await firestore.collection('campaigns').doc(campaignId).update({
    //     'players': FieldValue.arrayRemove([currentUser.uid])
    //   });
    // }
    // After leaving, refresh campaign list or navigate
    add(const HomeStarted()); // Refresh list
    // Or emit a state that causes UI to go back to lobby explicitly
    // emit(HomeLobby()); // This might be too abrupt or handled by UI structure
  }
}
