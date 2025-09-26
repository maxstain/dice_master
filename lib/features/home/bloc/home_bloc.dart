import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../models/campaign.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  StreamSubscription<QuerySnapshot>? _campaignsSub;
  final Map<String, StreamSubscription<QuerySnapshot>> _playersSubs = {};
  final Map<String, StreamSubscription<DocumentSnapshot>> _hostSubs = {};

  HomeBloc() : super(HomeLoading()) {
    on<HomeTriggerInitialLoad>(_onTriggerInitialLoad);
    on<_CampaignsUpdated>(_onCampaignsUpdated);
    on<_CampaignMetaUpdated>(_onCampaignMetaUpdated);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<_CampaignsUpdatedError>((event, emit) {
      emit(HomeFailure(event.message));
    });
    on<_CampaignWarning>((event, emit) {
      if (state is HomeLoaded) {
        emit(HomeLoaded(
          campaigns: (state as HomeLoaded).campaigns,
          warning: event.message,
        ));
      }
    });
  }

  Future<void> _onTriggerInitialLoad(
      HomeTriggerInitialLoad event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await _campaignsSub?.cancel();
    for (var sub in _playersSubs.values) {
      await sub.cancel();
    }
    _playersSubs.clear();
    for (var sub in _hostSubs.values) {
      await sub.cancel();
    }
    _hostSubs.clear();
    _campaignsSub = FirebaseFirestore.instance
        .collection('campaigns')
        .snapshots()
        .listen((qs) {
      try {
        final campaigns = qs.docs.map((doc) {
          final data = doc.data();
          final campaign = Campaign.fromJson({...data, 'id': doc.id});
          return campaign;
        }).toList();
        add(_CampaignsUpdated(campaigns));
      } catch (e) {
        add(_CampaignsUpdatedError("Firestore stream error: $e"));
      }
    }, onError: (error) {
      add(_CampaignsUpdatedError("Firestore stream error: $error"));
    });
  }

  Future<void> _onCampaignsUpdated(
      _CampaignsUpdated event, Emitter<HomeState> emit) async {
    // campaigns from Firestore (no players loaded yet)
    final List<CampaignWithMeta> base = event.campaigns
        .map((c) => CampaignWithMeta(
              campaign: c,
              hostName: c.hostId,
              playerCount: 0,
            ))
        .toList();
    emit(HomeLoaded(campaigns: base)); // subscribe to players + host updates
    for (final c in event.campaigns) {
      _hostSubs[c.id]?.cancel();
      _hostSubs[c.id] = FirebaseFirestore.instance
          .collection('users')
          .doc(c.hostId)
          .snapshots()
          .listen((doc) {
        final username = (doc.data() ?? {})['username'] ?? c.hostId;
        add(_CampaignMetaUpdated(campaignId: c.id, hostName: username));
      }, onError: (e) {
        add(_CampaignWarning("Failed to load host for ${c.title}: $e"));
      });
      _playersSubs[c.id]?.cancel();
      _playersSubs[c.id] = FirebaseFirestore.instance
          .collection('campaigns')
          .doc(c.id)
          .collection('players')
          .snapshots()
          .listen((qs) {
        add(_CampaignMetaUpdated(campaignId: c.id, playerCount: qs.size));
      }, onError: (e) {
        add(_CampaignWarning("Failed to load players for ${c.title}: $e"));
      });
    }
  }

  Future<void> _onCampaignMetaUpdated(
      _CampaignMetaUpdated event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final current = (state as HomeLoaded).campaigns;
    final updated = current.map((cwm) {
      if (cwm.campaign.id != event.campaignId) return cwm;
      return cwm.copyWith(
        hostName: event.hostName ?? cwm.hostName,
        playerCount: event.playerCount ?? cwm.playerCount,
      );
    }).toList();
    emit(HomeLoaded(campaigns: updated));
  }

  Future<void> _onRefreshRequested(
      HomeRefreshRequested event, Emitter<HomeState> emit) async {
    add(const HomeTriggerInitialLoad());
  }

  @override
  Future<void> close() {
    _campaignsSub?.cancel();
    for (var sub in _playersSubs.values) {
      sub.cancel();
    }
    for (var sub in _hostSubs.values) {
      sub.cancel();
    }
    return super.close();
  }
}
