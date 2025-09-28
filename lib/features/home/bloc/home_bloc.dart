import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/campaignWithMeta.dart';
import 'package:equatable/equatable.dart';

import '../../../models/campaign.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  StreamSubscription<QuerySnapshot>? _campaignsSub;

  HomeBloc() : super(const HomeLoading()) {
    on<HomeTriggerInitialLoad>(_onTriggerInitialLoad);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<_CampaignsUpdated>(_onCampaignsUpdated);
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
    emit(const HomeLoading());

    await _campaignsSub?.cancel();

    _campaignsSub = FirebaseFirestore.instance
        .collection('campaigns')
        .snapshots()
        .listen((qs) {
      try {
        final campaigns = qs.docs.map((doc) {
          final data = doc.data();
          return Campaign.fromJson({...data, 'id': doc.id});
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
    final enriched =
        event.campaigns.map(CampaignWithMeta.fromCampaign).toList();
    emit(HomeLoaded(campaigns: enriched));
  }

  Future<void> _onRefreshRequested(
      HomeRefreshRequested event, Emitter<HomeState> emit) async {
    add(const HomeTriggerInitialLoad());
  }

  @override
  Future<void> close() {
    _campaignsSub?.cancel();
    return super.close();
  }
}
