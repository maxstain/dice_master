import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/campaign/bloc/campaign_state.dart';
import 'package:dice_master/models/campaign.dart'; // Ensure Campaign model is imported if used directly
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'campaign_event.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore;

  CampaignBloc({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance,
        super(CampaignInitial()) {
    on<TriggerInitialLoad>(_onTriggerInitialLoadHandler);
    on<CampaignStarted>(_onCampaignStartedHandler);
    on<CreateCampaignRequested>(_onCreateCampaignRequestedHandler);
    on<JoinCampaignRequested>(
        _onJoinCampaignRequestedHandler); // This is what we are modifying
    on<LeaveCampaignRequested>(_onLeaveCampaignRequestedHandler);

    add(const TriggerInitialLoad());
  }

  Future<void> _onTriggerInitialLoadHandler(
      TriggerInitialLoad event, Emitter<CampaignState> emit) async {
    // ... (existing code for _onTriggerInitialLoadHandler)
    // No changes needed here for this request
    print(
        "CampaignBloc: _onTriggerInitialLoadHandler triggered for initial data load.");
    if (state is CampaignInitial ||
        state is CampaignFailure ||
        state is CampaignNotAuthenticated) {
      await _loadCampaigns(emit, isRefresh: false);
    } else {
      print(
          "CampaignBloc: Initial load triggered but state is already ${state.runtimeType}. Campaigns might already be loaded or loading.");
    }
  }

  Future<void> _onCampaignStartedHandler(
      CampaignStarted event, Emitter<CampaignState> emit) async {
    // ... (existing code for _onCampaignStartedHandler)
    // No changes needed here for this request
    print("CampaignBloc: _onCampaignStartedHandler triggered (user refresh).");
    await _loadCampaigns(emit, isRefresh: true);
  }

  Future<void> _loadCampaigns(Emitter<CampaignState> emit,
      {required bool isRefresh}) async {
    // ... (existing code for _loadCampaigns)
    // No changes needed here for this request
    print(
        "CampaignBloc: _loadCampaigns called. isRefresh: $isRefresh, currentState: ${state.runtimeType}");
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      print(
          "CampaignBloc: User not authenticated during _loadCampaigns. Emitting CampaignNotAuthenticated.");
      emit(CampaignNotAuthenticated());
      return;
    }

    if (state is CampaignLoading && !isRefresh) {
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
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const CampaignFailure(
          'User not authenticated to create a campaign.'));
      print(
          "CampaignBloc: User not authenticated for CreateCampaignRequested.");
      return;
    }

    try {
      DocumentReference ref = await firestore.collection('campaigns').add({
        'title': event.campaignName ?? 'New Campaign',
        'hostId': currentUser.uid,
        // 'players': [], // REMOVED: Inconsistent with players subcollection approach
        'sessionCode': FirebaseFirestore.instance
            .collection('campaigns')
            .doc()
            .id
            .substring(0, 6)
            .toUpperCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await ref.update({'id': ref.id});
      print("CampaignBloc: Campaign created with ID: ${ref.id}");
      add(const CampaignStarted());
    } catch (e, stackTrace) {
      print('CampaignBloc: Failed to create campaign: $e');
      print(
          'CampaignBloc: Stacktrace for campaign creation failure: $stackTrace');
      emit(CampaignFailure('Failed to create campaign: ${e.toString()}'));
    }
  }

  // MODIFIED HANDLER STARTS HERE
  Future<void> _onJoinCampaignRequestedHandler(
      JoinCampaignRequested event, Emitter<CampaignState> emit) async {
    print(
        "CampaignBloc: _onJoinCampaignRequestedHandler triggered for campaign ID: ${event.campaignId}");
    emit(CampaignLoading());

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const CampaignFailure('User not authenticated to join a campaign.'));
      print("CampaignBloc: User not authenticated for JoinCampaignRequested.");
      return;
    }

    try {
      final campaignDocRef =
          firestore.collection('campaigns').doc(event.campaignId);
      final campaignSnapshot = await campaignDocRef.get();

      if (!campaignSnapshot.exists) {
        emit(
            CampaignFailure('Campaign with ID ${event.campaignId} not found.'));
        print(
            "CampaignBloc: Campaign ${event.campaignId} not found for joining.");
        return;
      }

      final campaignData = campaignSnapshot.data() as Map<String, dynamic>;
      final String? hostId = campaignData['hostId'] as String?;

      // 1. Check if current user is the host
      if (hostId == currentUser.uid) {
        print(
            "CampaignBloc: User is the host. Entering campaign ${event.campaignId}.");
        emit(CampaignCampaignJoined(event.campaignId));
        return;
      }

      // 2. Check if user is already in the 'players' subcollection
      final playerDocRef =
          campaignDocRef.collection('players').doc(currentUser.uid);
      final playerDocSnapshot = await playerDocRef.get();

      if (playerDocSnapshot.exists) {
        print(
            "CampaignBloc: User is already a player. Entering campaign ${event.campaignId}.");
        emit(CampaignCampaignJoined(event.campaignId));
        return;
      }

      // 3. User is not the host and not an existing player, so add them.
      print(
          "CampaignBloc: User is new to campaign ${event.campaignId}. Adding player.");

      final newCharacterData = {
        'name': 'New Adventurer', // Default name
        'role': 'Unknown',
        'level': 1,
        'hp': 10,
        'race': 'Human',
        'imageUrl': '',
        'userId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        // Ensure these fields align with your Character.fromJson factory
      };

      // CRITICAL: Use .set() to create the document if it doesn't exist.
      await playerDocRef.set(newCharacterData); // <--- ENSURE THIS IS .set()

      print(
          "CampaignBloc: User ${currentUser.uid} added as a new player to campaign ${event.campaignId}.");
      emit(CampaignCampaignJoined(event.campaignId));
    } catch (e, stackTrace) {
      print(
          'CampaignBloc: Failed to join or enter campaign: $e'); // Your error message comes from here
      print(
          'CampaignBloc: Stacktrace for campaign joining/entering failure: $stackTrace');
      emit(
          CampaignFailure('Failed to join or enter campaign: ${e.toString()}'));
    }
  }

  // MODIFIED HANDLER ENDS HERE

  Future<void> _onLeaveCampaignRequestedHandler(
      LeaveCampaignRequested event, Emitter<CampaignState> emit) async {
    // ... (existing code for _onLeaveCampaignRequestedHandler)
    // No changes needed here for this request
    print("CampaignBloc: _onLeaveCampaignRequestedHandler triggered.");
    add(const CampaignStarted());
  }
}
