import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:dice_master/models/campaign.dart'; // Make sure this is used or remove if not
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore;

  HomeBloc({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance,
        super(HomeInitial()) {
    on<TriggerInitialLoad>(_onTriggerInitialLoadHandler);
    on<HomeStarted>(_onHomeStartedHandler);
    on<CreateCampaignRequested>(_onCreateCampaignRequestedHandler);
    on<JoinCampaignRequested>(_onJoinCampaignRequestedHandler);
    on<LeaveCampaignRequested>(_onLeaveCampaignRequestedHandler);

    add(const TriggerInitialLoad());
  }

  Future<void> _onTriggerInitialLoadHandler(
      TriggerInitialLoad event, Emitter<HomeState> emit) async {
    print(
        "HomeBloc: _onTriggerInitialLoadHandler triggered for initial data load.");
    if (state is HomeInitial ||
        state is HomeFailure ||
        state is HomeNotAuthenticated) {
      await _loadCampaigns(emit, isRefresh: false);
    } else {
      print(
          "HomeBloc: Initial load triggered but state is already ${state.runtimeType}. Campaigns might already be loaded or loading.");
    }
  }

  Future<void> _onHomeStartedHandler(
      HomeStarted event, Emitter<HomeState> emit) async {
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

    if (state is HomeLoading && !isRefresh) {
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
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const HomeFailure('User not authenticated to create a campaign.'));
      print("HomeBloc: User not authenticated for CreateCampaignRequested.");
      return;
    }

    try {
      DocumentReference ref =
          await firestore.collection('campaigns').add(Campaign.newCampaign(
                event.campaignName ?? 'New Campaign',
                currentUser.uid,
                [],
                FirebaseFirestore.instance
                    .collection('campaigns')
                    .doc()
                    .id
                    .substring(0, 6)
                    .toUpperCase(),
              ));

      await ref.update({'id': ref.id});
      print("HomeBloc: Campaign created with ID: ${ref.id}");
      add(const HomeStarted());
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
    emit(HomeLoading());
    print(
        "HomeBloc: Emitted HomeLoading in _onJoinCampaignRequestedHandler."); // ADDED

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      print(
          "HomeBloc: User not authenticated in _onJoinCampaignRequestedHandler. Emitting HomeFailure."); // ADDED
      emit(const HomeFailure('User not authenticated to join a campaign.'));
      return;
    }

    try {
      final campaignDocRef =
          firestore.collection('campaigns').doc(event.campaignId);
      final campaignSnapshot = await campaignDocRef.get();

      if (!campaignSnapshot.exists) {
        print(
            "HomeBloc: Campaign ${event.campaignId} not found. Emitting HomeFailure."); // ADDED
        emit(HomeFailure('Campaign with ID ${event.campaignId} not found.'));
        return;
      }
      print("HomeBloc: Campaign ${event.campaignId} found."); // ADDED

      final campaignData = campaignSnapshot.data() as Map<String, dynamic>;
      final String? hostId = campaignData['hostId'] as String?;

      if (hostId == currentUser.uid) {
        print(
            "HomeBloc: User IS THE HOST of ${event.campaignId}. Preparing to emit HomeCampaignEntered."); // ADDED
        emit(HomeCampaignEntered(event.campaignId));
        print("HomeBloc: Emitted HomeCampaignEntered for host."); // ADDED
        return;
      }
      print(
          "HomeBloc: User is NOT THE HOST of ${event.campaignId}. Checking if player."); // ADDED

      final playerDocRef =
          campaignDocRef.collection('players').doc(currentUser.uid);
      final playerDocSnapshot = await playerDocRef.get();

      if (playerDocSnapshot.exists) {
        print(
            "HomeBloc: User IS ALREADY A PLAYER in ${event.campaignId}. Preparing to emit HomeCampaignEntered."); // ADDED
        emit(HomeCampaignEntered(event.campaignId));
        print(
            "HomeBloc: Emitted HomeCampaignEntered for existing player."); // ADDED
        return;
      }
      print(
          "HomeBloc: User is NOT an existing player in ${event.campaignId}. Adding as new player."); // ADDED

      final newCharacterData = {
        'name': currentUser.displayName ?? 'New Adventurer',
        'role': 'Unknown',
        'level': 1,
        'hp': 10,
        'race': 'Human',
        'imageUrl': currentUser.photoURL ?? '',
        'userId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await playerDocRef.set(newCharacterData);
      print(
          "HomeBloc: User ${currentUser.uid} ADDED as new player to ${event.campaignId}. Preparing to emit HomeCampaignJoined."); // ADDED
      emit(HomeCampaignJoined(event.campaignId));
      print("HomeBloc: Emitted HomeCampaignJoined for new player."); // ADDED
    } catch (e, stackTrace) {
      print('HomeBloc: ERROR in _onJoinCampaignRequestedHandler: $e');
      print(
          'HomeBloc: Stacktrace for _onJoinCampaignRequestedHandler error: $stackTrace');
      emit(HomeFailure('Failed to join or enter campaign: ${e.toString()}'));
      print(
          "HomeBloc: Emitted HomeFailure due to error in _onJoinCampaignRequestedHandler."); // ADDED
    }
  }

  Future<void> _onLeaveCampaignRequestedHandler(
      LeaveCampaignRequested event, Emitter<HomeState> emit) async {
    print(
        "HomeBloc: _onLeaveCampaignRequestedHandler triggered for campaign ID: ${event.campaignId}.");

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const HomeFailure('User not authenticated to leave a campaign.'));
      print("HomeBloc: User not authenticated for LeaveCampaignRequested.");
      return;
    }

    try {
      final campaignDocRef =
          firestore.collection('campaigns').doc(event.campaignId);
      final playerDocRef =
          campaignDocRef.collection('players').doc(currentUser.uid);
      final playerDocSnapshot = await playerDocRef.get();

      if (!playerDocSnapshot.exists) {
        print(
            "HomeBloc: Player ${currentUser.uid} not found in campaign ${event.campaignId} to leave.");
        add(const HomeStarted());
        return;
      }

      await playerDocRef.delete();
      print(
          "HomeBloc: Player ${currentUser.uid} removed from campaign ${event.campaignId}");
      add(const HomeStarted());
    } catch (e, stackTrace) {
      print('HomeBloc: Failed to leave campaign: $e');
      print('HomeBloc: Stacktrace for campaign leaving failure: $stackTrace');
      emit(HomeFailure('Failed to leave campaign: ${e.toString()}'));
    }
  }
}
