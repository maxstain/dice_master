part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeTriggerInitialLoad extends HomeEvent {
  const HomeTriggerInitialLoad();
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

class _CampaignsUpdated extends HomeEvent {
  final List<Campaign> campaigns;

  const _CampaignsUpdated(this.campaigns);

  @override
  List<Object?> get props => [campaigns];
}

class _CampaignsUpdatedError extends HomeEvent {
  final String message;

  const _CampaignsUpdatedError(this.message);

  @override
  List<Object?> get props => [message];
}

class _CampaignWarning extends HomeEvent {
  final String message;

  const _CampaignWarning(this.message);

  @override
  List<Object?> get props => [message];
}
