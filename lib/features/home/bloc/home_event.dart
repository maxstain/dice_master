import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class CreateCampaignRequested extends HomeEvent {
  final String? campaignName;

  const CreateCampaignRequested({this.campaignName});

  @override
  List<Object?> get props => [campaignName];
}

class JoinCampaignRequested extends HomeEvent {
  final String campaignId;

  const JoinCampaignRequested(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

class CampaignUpdated extends HomeEvent {
  const CampaignUpdated();

  @override
  List<Object?> get props => [];
}

class LeaveCampaignRequested extends HomeEvent {
  const LeaveCampaignRequested();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  // This is for user-initiated refresh
  const HomeStarted();

  @override
  List<Object?> get props => [];
}

class TriggerInitialLoad extends HomeEvent {
  // New event for initial load
  const TriggerInitialLoad();

  @override
  List<Object?> get props => [];
}

// HomeLoaded event was previously discussed. If it was intended as a state, it should be in home_state.dart.
// If it was an event, its purpose needs to be clear. For now, assuming HomeStarted and TriggerInitialLoad cover needs.
// class HomeLoaded extends HomeEvent {
//   const HomeLoaded();
//   @override
//   List<Object?> get props => [];
// }
