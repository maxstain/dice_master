import 'package:dice_master/models/character.dart';
import 'package:equatable/equatable.dart';

import '../../../models/campaign.dart';

abstract class CampaignEvent extends Equatable {
  const CampaignEvent();

  @override
  List<Object?> get props => [];
}

class CampaignStarted extends CampaignEvent {
  final String campaignId;

  const CampaignStarted(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

class CampaignUpdated extends CampaignEvent {
  final Campaign campaign;

  const CampaignUpdated(this.campaign);

  @override
  List<Object?> get props => [campaign];
}

/// DM adds a new session
class AddSessionRequested extends CampaignEvent {
  final String campaignId;
  final Map<String, dynamic> session;

  const AddSessionRequested(this.campaignId, this.session);

  @override
  List<Object?> get props => [campaignId, session];
}

/// DM updates notes
class UpdateNotesRequested extends CampaignEvent {
  final String campaignId;
  final Map<String, dynamic> notes;

  const UpdateNotesRequested(this.campaignId, this.notes);

  @override
  List<Object?> get props => [campaignId, notes];
}

class CampaignDataChanged extends CampaignEvent {
  final Campaign? campaign;
  final List<Character> players;

  const CampaignDataChanged(this.campaign, this.players);

  @override
  List<Object?> get props => [campaign, players];
}

/// Player joins a session
class JoinSessionRequested extends CampaignEvent {
  final String campaignId;
  final String sessionId;
  final String userId;

  const JoinSessionRequested(this.campaignId, this.sessionId, this.userId);

  @override
  List<Object?> get props => [campaignId, sessionId, userId];
}
