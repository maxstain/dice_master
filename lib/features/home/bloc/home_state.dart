part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

/// Extended campaign with live metadata
class CampaignWithMeta extends Equatable {
  final Campaign campaign;
  final String hostName;
  final int playerCount;

  const CampaignWithMeta({
    required this.campaign,
    required this.hostName,
    required this.playerCount,
  });

  CampaignWithMeta copyWith({
    Campaign? campaign,
    String? hostName,
    int? playerCount,
  }) {
    return CampaignWithMeta(
      campaign: campaign ?? this.campaign,
      hostName: hostName ?? this.hostName,
      playerCount: playerCount ?? this.playerCount,
    );
  }

  @override
  List<Object?> get props => [campaign, hostName, playerCount];
}

class HomeLoaded extends HomeState {
  final List<CampaignWithMeta> campaigns;

  const HomeLoaded({required this.campaigns});

  @override
  List<Object?> get props => [campaigns];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
