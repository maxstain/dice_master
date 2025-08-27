import 'package:equatable/equatable.dart';

abstract class CampaignEvent extends Equatable {
  const CampaignEvent();

  @override
  List<Object?> get props => [];
}

class CreateCampaignRequested extends CampaignEvent {
  final String? campaignName;

  const CreateCampaignRequested({this.campaignName});

  @override
  List<Object?> get props => [campaignName];
}

class JoinCampaignRequested extends CampaignEvent {
  final String campaignId;

  const JoinCampaignRequested(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

class CampaignUpdated extends CampaignEvent {
  const CampaignUpdated();

  @override
  List<Object?> get props => [];
}

class LeaveCampaignRequested extends CampaignEvent {
  const LeaveCampaignRequested();

  @override
  List<Object?> get props => [];
}

class CampaignStarted extends CampaignEvent {
  // This is for user-initiated refresh
  const CampaignStarted();

  @override
  List<Object?> get props => [];
}

class TriggerInitialLoad extends CampaignEvent {
  // New event for initial load
  const TriggerInitialLoad();

  @override
  List<Object?> get props => [];
}

// CampaignLoaded event was previously discussed. If it was intended as a state, it should be in campaign_state.dart.
// If it was an event, its purpose needs to be clear. For now, assuming CampaignStarted and TriggerInitialLoad cover needs.
// class CampaignLoaded extends CampaignEvent {
//   const CampaignLoaded();
//   @override
//   List<Object?> get props => [];
// }
