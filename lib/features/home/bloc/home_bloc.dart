import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/campaign.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  StreamSubscription<User?>? _authSub;

  HomeBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(HomeInitial()) {
    on<TriggerInitialLoad>(_onTriggerInitialLoadHandler);
    on<HomeStarted>(_onHomeStartedHandler);
    on<CreateCampaignRequested>(_onCreateCampaignRequestedHandler);
    on<JoinCampaignRequested>(_onJoinCampaignRequestedHandler);
    on<LeaveCampaignRequested>(_onLeaveCampaignRequestedHandler);
    on<HomeUserChanged>(_onUserChangedHandler);

    // 🔑 Listen to Firebase auth changes
    _authSub = _firebaseAuth.authStateChanges().listen((user) {
      add(HomeUserChanged(user));
    });
  }

  // Clean up subscription
  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }

  Future<void> _onTriggerInitialLoadHandler(
      TriggerInitialLoad event, Emitter<HomeState> emit) async {
    await _loadCampaigns(emit, isRefresh: false);
  }

  Future<void> _onHomeStartedHandler(
      HomeStarted event, Emitter<HomeState> emit) async {
    await _loadCampaigns(emit, isRefresh: true);
  }

  void _onUserChangedHandler(
      HomeUserChanged event, Emitter<HomeState> emit) async {
    if (event.user == null) {
      emit(HomeNotAuthenticated());
    } else {
      add(const TriggerInitialLoad());
    }
  }

  Future<void> _loadCampaigns(Emitter<HomeState> emit,
      {required bool isRefresh}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(HomeNotAuthenticated());
      return;
    }

    emit(HomeLoading());

    try {
      final snap = await _firestore
          .collection('campaigns')
          .where('players', arrayContains: currentUser.uid)
          .get();

      // 🔑 Use fromDoc to convert Firestore document to Campaign model
      final campaigns = snap.docs
          .map((doc) =>
              Campaign.fromDoc(doc)) // 🔑 use fromDoc instead of fromJson
          .toList();

      emit(HomeLoaded(campaigns: campaigns as List<Campaign>));
    } catch (e, st) {
      print("HomeBloc: Firestore error $e\n$st");
      emit(HomeFailure(e.toString()));
    }
  }

  Future<void> _onCreateCampaignRequestedHandler(
      CreateCampaignRequested event, Emitter<HomeState> emit) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(HomeNotAuthenticated());
      return;
    }

    try {
      final doc = _firestore.collection('campaigns').doc();
      final campaign = Campaign(
        id: doc.id,
        title: event.title,
        hostId: currentUser.uid,
        players: [],
        sessions: [],
        sessionCode: doc.id.substring(0, 6).toUpperCase(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await doc.set(campaign.toJson());
      add(const TriggerInitialLoad());
    } catch (e) {
      emit(HomeFailure("Failed to create campaign: $e"));
    }
  }

  Future<void> _onJoinCampaignRequestedHandler(
      JoinCampaignRequested event, Emitter<HomeState> emit) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(HomeNotAuthenticated());
      return;
    }

    try {
      final query = await _firestore
          .collection('campaigns')
          .where('sessionCode', isEqualTo: event.sessionCode)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first.reference;
        await doc.update({
          'players': FieldValue.arrayUnion([currentUser.uid])
        });
        add(const TriggerInitialLoad());
      } else {
        emit(const HomeFailure("Invalid session code"));
      }
    } catch (e) {
      emit(HomeFailure("Failed to join campaign: $e"));
    }
  }

  Future<void> _onLeaveCampaignRequestedHandler(
      LeaveCampaignRequested event, Emitter<HomeState> emit) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(HomeNotAuthenticated());
      return;
    }

    try {
      final doc = _firestore.collection('campaigns').doc(event.campaignId);
      await doc.update({
        'players': FieldValue.arrayRemove([currentUser.uid])
      });
      add(const TriggerInitialLoad());
    } catch (e) {
      emit(HomeFailure("Failed to leave campaign: $e"));
    }
  }
}
