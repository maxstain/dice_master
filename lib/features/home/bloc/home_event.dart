import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger initial campaign load when app starts or user logs in
class TriggerInitialLoad extends HomeEvent {
  const TriggerInitialLoad();
}

/// Manual refresh of campaign list
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Fired when Firebase auth state changes
class HomeUserChanged extends HomeEvent {
  final User? user;

  const HomeUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

/// Create a new campaign
class CreateCampaignRequested extends HomeEvent {
  final String title;

  const CreateCampaignRequested(this.title);

  @override
  List<Object?> get props => [title];
}

/// Join an existing campaign by code
class JoinCampaignRequested extends HomeEvent {
  final String sessionCode;

  const JoinCampaignRequested(this.sessionCode);

  @override
  List<Object?> get props => [sessionCode];
}

/// Leave a campaign
class LeaveCampaignRequested extends HomeEvent {
  final String campaignId;

  const LeaveCampaignRequested(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}
