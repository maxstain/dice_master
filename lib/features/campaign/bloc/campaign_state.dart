import 'package:equatable/equatable.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';

abstract class CampaignState extends Equatable {
  const CampaignState();

  @override
  List<Object?> get props => [];
}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {}

class CampaignLoaded extends CampaignState {
  final Campaign campaign;
  final List<Character> players;
  final bool isDungeonMaster;

  const CampaignLoaded({
    required this.campaign,
    required this.players,
    required this.isDungeonMaster,
  });

  @override
  List<Object?> get props => [campaign, players, isDungeonMaster];
}

class CampaignFailure extends CampaignState {
  final String message;

  const CampaignFailure(this.message);

  @override
  List<Object?> get props => [message];
}
