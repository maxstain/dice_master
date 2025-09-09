import 'package:dice_master/models/campaign.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];

  get campaigns => List<Campaign>.empty;
}

class HomeLoading extends HomeState {}

class HomeAuthenticated extends HomeState {}

class HomeLobby extends HomeState {}

class HomeNotAuthenticated extends HomeState {}

class HomeCampaign extends HomeState {
  final String sessionId;

  const HomeCampaign(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeSuccess extends HomeState {
  final String message;
  final List<Campaign>? campaigns;

  const HomeSuccess(this.message, this.campaigns);

  @override
  List<Object?> get props => [message, campaigns];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeInitial extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeDungeonMaster extends HomeState {
  final String dungeonMasterName;

  const HomeDungeonMaster(this.dungeonMasterName);

  @override
  List<Object?> get props => [dungeonMasterName];
}

class HomePlayer extends HomeState {
  final String playerName;

  const HomePlayer(this.playerName);

  @override
  List<Object?> get props => [playerName];
}

class HomeCampaignCreated extends HomeState {
  final String sessionId;

  const HomeCampaignCreated(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class HomeCampaignJoined extends HomeState {
  final String campaignId; // Renamed from sessionId

  const HomeCampaignJoined(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

class HomeCampaignLeft extends HomeState {
  final String sessionId;

  const HomeCampaignLeft(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class HomeCampaignUpdated extends HomeState {
  final String sessionId;
  final String updatedInfo;

  const HomeCampaignUpdated(this.sessionId, this.updatedInfo);

  @override
  List<Object?> get props => [sessionId, updatedInfo];
}

class HomeCampaignError extends HomeState {
  final String sessionId;
  final String errorMessage;

  const HomeCampaignError(this.sessionId, this.errorMessage);

  @override
  List<Object?> get props => [sessionId, errorMessage];
}
