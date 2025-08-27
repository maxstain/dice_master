import 'package:dice_master/models/campaign.dart';
import 'package:equatable/equatable.dart';

abstract class CampaignState extends Equatable {
  const CampaignState();

  @override
  List<Object?> get props => [];

  get campaign => null;
}

class CampaignLoading extends CampaignState {}

class CampaignAuthenticated extends CampaignState {}

class CampaignNotAuthenticated extends CampaignState {}

class CampaignFailure extends CampaignState {
  final String message;

  const CampaignFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CampaignSuccess extends CampaignState {
  final String message;
  final List<Campaign>? campaigns;

  const CampaignSuccess(this.message, this.campaigns);

  @override
  List<Object?> get props => [message, campaigns];
}

class CampaignError extends CampaignState {
  final String message;

  const CampaignError(this.message);

  @override
  List<Object?> get props => [message];
}

class CampaignInitial extends CampaignState {
  @override
  List<Object?> get props => [];
}

class CampaignDungeonMaster extends CampaignState {
  final String dungeonMasterName;

  const CampaignDungeonMaster(this.dungeonMasterName);

  @override
  List<Object?> get props => [dungeonMasterName];
}

class CampaignPlayer extends CampaignState {
  final String playerName;

  const CampaignPlayer(this.playerName);

  @override
  List<Object?> get props => [playerName];
}

class CampaignCampaignCreated extends CampaignState {
  final String campaignId;

  const CampaignCampaignCreated(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

class CampaignCampaignJoined extends CampaignState {
  final String campaignId;

  const CampaignCampaignJoined(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

class CampaignCampaignLeft extends CampaignState {
  final String campaignId;

  const CampaignCampaignLeft(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

class CampaignCampaignUpdated extends CampaignState {
  final String campaignId;
  final String updatedInfo;

  const CampaignCampaignUpdated(this.campaignId, this.updatedInfo);

  @override
  List<Object?> get props => [campaignId, updatedInfo];
}

class CampaignCampaignError extends CampaignState {
  final String campaignId;
  final String errorMessage;

  const CampaignCampaignError(this.campaignId, this.errorMessage);

  @override
  List<Object?> get props => [campaignId, errorMessage];
}
