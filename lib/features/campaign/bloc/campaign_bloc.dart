import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/campaign/bloc/campaign_state.dart';
import 'package:dice_master/models/campaign.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'campaign_event.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore;

  CampaignBloc({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance,
        super(CampaignInitial()) {
    // Start with CampaignInitial
    on<TriggerInitialLoad>(_onTriggerInitialLoadHandler);
    on<CampaignStarted>(
        _onCampaignStartedHandler); // For user-initiated refresh
    on<CreateCampaignRequested>(_onCreateCampaignRequestedHandler);
    on<JoinCampaignRequested>(_onJoinCampaignRequestedHandler);
    on<LeaveCampaignRequested>(_onLeaveCampaignRequestedHandler);
    // on<CampaignUpdated>(_onCampaignUpdated); // If you have this handler

    add(const TriggerInitialLoad()); // Dispatch the initial load event
  }

  Future<void> _onTriggerInitialLoadHandler(
      TriggerInitialLoad event, Emitter<CampaignState> emit) async {
    print(
        "CampaignBloc: _onTriggerInitialLoadHandler triggered for initial data load.");
    // Only proceed if we are in an initial or failed state to avoid redundant loads on hot reload with BLoC already loaded
    if (state is CampaignInitial ||
        state is CampaignFailure ||
        state is CampaignNotAuthenticated) {
      await _loadCampaigns(emit, isRefresh: false);
    } else {
      print(
          "CampaignBloc: Initial load triggered but state is already ${state.runtimeType}. Campaigns might already be loaded or loading.");
      // If state is CampaignSuccess, it means campaigns are loaded. If CampaignLoading, it's in progress.
      // If you want TriggerInitialLoad to ALWAYS reload, then remove this if condition.
      // For now, this makes initial load idempotent if BLoC is preserved across hot restarts and already loaded.
    }
  }

  Future<void> _onCampaignStartedHandler(
      // This is for user-initiated refresh
      CampaignStarted event,
      Emitter<CampaignState> emit) async {
    print("CampaignBloc: _onCampaignStartedHandler triggered (user refresh).");
    await _loadCampaigns(emit, isRefresh: true);
  }

  Future<void> _loadCampaigns(Emitter<CampaignState> emit,
      {required bool isRefresh}) async {
    print(
        "CampaignBloc: _loadCampaigns called. isRefresh: $isRefresh, currentState: ${state.runtimeType}");
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      print(
          "CampaignBloc: User not authenticated during _loadCampaigns. Emitting CampaignNotAuthenticated.");
      emit(CampaignNotAuthenticated());
      return;
    }

    // Only emit CampaignLoading if not already loading, or if it's a forced refresh from a stable state
    if (state is CampaignLoading && !isRefresh) {
      // Avoid emitting loading if already loading unless it's a refresh
      print(
          "CampaignBloc: Already in CampaignLoading state and not a refresh. Aborting redundant _loadCampaigns call.");
      return;
    }

    print(
        "CampaignBloc: User authenticated. Proceeding to load campaigns in _loadCampaigns.");
    emit(CampaignLoading());
    print("CampaignBloc: Emitted CampaignLoading state from _loadCampaigns.");

    try {
      final snapshot = await firestore.collection('campaigns').get();
      print(
          "CampaignBloc: Fetched ${snapshot.docs.length} campaigns from Firestore in _loadCampaigns.");

      if (snapshot.docs.isEmpty) {
        print(
            "CampaignBloc: No campaigns found in Firestore. Emitting CampaignSuccess with empty list from _loadCampaigns.");
        emit(const CampaignSuccess("No campaigns found.", []));
        return;
      }

      final campaigns = snapshot.docs.map((doc) {
        print("CampaignBloc: Mapping document ID: ${doc.id}");
        final data = doc.data();
        return Campaign.fromJson(data);
      }).toList();

      print(
          "CampaignBloc: Successfully mapped ${campaigns.length} campaigns in _loadCampaigns.");
      emit(CampaignSuccess("Campaigns loaded successfully", campaigns));
      print(
          "CampaignBloc: Emitted CampaignSuccess state with campaigns from _loadCampaigns.");
    } catch (e, stackTrace) {
      print('CampaignBloc: Failed to load campaigns in _loadCampaigns: $e');
      print('CampaignBloc: Stacktrace for _loadCampaigns failure: $stackTrace');
      emit(CampaignFailure('Failed to load campaigns: ${e.toString()}'));
      print("CampaignBloc: Emitted CampaignFailure state from _loadCampaigns.");
    }
  }

  Future<void> _onCreateCampaignRequestedHandler(
      CreateCampaignRequested event, Emitter<CampaignState> emit) async {
    print(
        "CampaignBloc: _onCreateCampaignRequestedHandler triggered with name: ${event.campaignName}");
    // emit(CampaignLoading()); // Don't emit CampaignLoading here if UI handles it, or if it makes UI jumpy
    // The list will refresh via CampaignStarted after creation.
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(CampaignFailure('User not authenticated to create a campaign.'));
      print(
          "CampaignBloc: User not authenticated for CreateCampaignRequested.");
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
      print("CampaignBloc: Campaign created with ID: ${ref.id}");

      // Instead of CampaignStarted which reloads all, consider optimistically updating or a specific "CampaignAdded" state.
      // For now, refreshing all campaigns:
      add(const CampaignStarted()); // This will trigger _loadCampaigns with isRefresh: true
    } catch (e, stackTrace) {
      print('CampaignBloc: Failed to create campaign: $e');
      print(
          'CampaignBloc: Stacktrace for campaign creation failure: $stackTrace');
      emit(CampaignFailure('Failed to create campaign: ${e.toString()}'));
    }
  }

  Future<void> _onJoinCampaignRequestedHandler(
      JoinCampaignRequested event, Emitter<CampaignState> emit) async {
    print(
        "CampaignBloc: _onJoinCampaignRequestedHandler triggered for campaign ID: ${event.campaignId}");
    // emit(CampaignLoading()); // Similar to create, consider UI impact.
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(CampaignFailure('User not authenticated to join a campaign.'));
      print("CampaignBloc: User not authenticated for JoinCampaignRequested.");
      return;
    }

    try {
      final campaignDocRef =
          firestore.collection('campaigns').doc(event.campaignId);
      final campaignDoc = await campaignDocRef.get();

      if (!campaignDoc.exists) {
        emit(
            CampaignFailure('Campaign with ID ${event.campaignId} not found.'));
        print(
            "CampaignBloc: Campaign ${event.campaignId} not found for joining.");
        return;
      }

      await campaignDocRef.update({
        'players': FieldValue.arrayUnion([currentUser.uid])
      });

      print(
          "CampaignBloc: User ${currentUser.uid} joined campaign ${event.campaignId}");
      // After joining, refresh the campaign list to show updated player counts etc.
      add(const CampaignStarted()); // This will trigger _loadCampaigns with isRefresh: true
    } catch (e, stackTrace) {
      print('CampaignBloc: Failed to join campaign: $e');
      print(
          'CampaignBloc: Stacktrace for campaign joining failure: $stackTrace');
      emit(CampaignFailure('Failed to join campaign: ${e.toString()}'));
    }
  }

  Future<void> _onLeaveCampaignRequestedHandler(
      // Basic structure
      LeaveCampaignRequested event,
      Emitter<CampaignState> emit) async {
    print("CampaignBloc: _onLeaveCampaignRequestedHandler triggered.");
    // Actual logic to remove player from Firestore campaign document would go here.
    // Example:
    // final currentUser = _firebaseAuth.currentUser;
    // if (currentUser != null && state is CampaignPlayer) { // Assuming state holds current campaign
    //   final campaignId = (state as CampaignPlayer).campaignId; // Need campaignId to leave
    //   await firestore.collection('campaigns').doc(campaignId).update({
    //     'players': FieldValue.arrayRemove([currentUser.uid])
    //   });
    // }
    // After leaving, refresh campaign list or navigate
    add(const CampaignStarted()); // Refresh list
    // Or emit a state that causes UI to go back to lobby explicitly
    // emit(CampaignLobby()); // This might be too abrupt or handled by UI structure
  }
}
