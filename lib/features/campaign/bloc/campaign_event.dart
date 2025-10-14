import 'package:dice_master/models/campaign.dart';
import 'package:equatable/equatable.dart';

/// Base
abstract class CampaignEvent extends Equatable {
  const CampaignEvent();

  @override
  List<Object?> get props => [];
}

/// ==== Core ====
class CampaignStarted extends CampaignEvent {
  final String campaignId;

  const CampaignStarted(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

/// ==== Characters ====
class AddCharacterRequested extends CampaignEvent {
  final String campaignId;
  final Map<String, dynamic> characterData;

  const AddCharacterRequested(this.campaignId, this.characterData);

  @override
  List<Object?> get props => [campaignId, characterData];
}

class UpdateCharacterRequested extends CampaignEvent {
  final String campaignId;
  final String characterId;
  final Map<String, dynamic> characterData;

  const UpdateCharacterRequested(
    this.campaignId,
    this.characterId,
    this.characterData,
  );

  @override
  List<Object?> get props => [campaignId, characterId, characterData];
}

/// ==== Sessions (now a subcollection) ====
class AddSessionRequested extends CampaignEvent {
  final String campaignId;
  final Map<String, dynamic> sessionData; // title, description, date
  const AddSessionRequested(this.campaignId, this.sessionData);

  @override
  List<Object?> get props => [campaignId, sessionData];
}

class UpdateSessionRequested extends CampaignEvent {
  final String campaignId;
  final String sessionId;
  final Map<String, dynamic> sessionData;

  const UpdateSessionRequested(
      this.campaignId, this.sessionId, this.sessionData);

  @override
  List<Object?> get props => [campaignId, sessionId, sessionData];
}

class DeleteSessionRequested extends CampaignEvent {
  final String campaignId;
  final String sessionId;

  const DeleteSessionRequested(this.campaignId, this.sessionId);

  @override
  List<Object?> get props => [campaignId, sessionId];
}

/// ==== Notes (subcollection) ====
class AddNoteRequested extends CampaignEvent {
  final String campaignId;
  final Map<String, dynamic> noteData;

  const AddNoteRequested(this.campaignId, this.noteData);

  @override
  List<Object?> get props => [campaignId, noteData];
}

class UpdateNoteRequested extends CampaignEvent {
  final String campaignId;
  final String noteId;
  final Map<String, dynamic> noteData;

  const UpdateNoteRequested(this.campaignId, this.noteId, this.noteData);

  @override
  List<Object?> get props => [campaignId, noteId, noteData];
}

class DeleteNoteRequested extends CampaignEvent {
  final String campaignId;
  final String noteId;

  const DeleteNoteRequested(this.campaignId, this.noteId);

  @override
  List<Object?> get props => [campaignId, noteId];
}

/// ==== Misc ====
class JoinSessionRequested extends CampaignEvent {
  final String campaignId;
  final String sessionId;
  final String characterId;

  const JoinSessionRequested(this.campaignId, this.sessionId, this.characterId);

  @override
  List<Object?> get props => [campaignId, sessionId, characterId];
}

class ClearMessagesRequested extends CampaignEvent {
  const ClearMessagesRequested();
}

/// ==== Private stream events ====
class CampaignUpdated extends CampaignEvent {
  final Campaign? campaign;

  const CampaignUpdated(this.campaign);

  @override
  List<Object?> get props => [campaign ?? "null"];
}

class PlayersUpdated extends CampaignEvent {
  final Campaign campaign;
  final List<dynamic> players;

  const PlayersUpdated(this.campaign, this.players);

  @override
  List<Object?> get props => [campaign, players];
}

class NotesUpdated extends CampaignEvent {
  final List<Map<String, dynamic>> notes;

  const NotesUpdated(this.notes);

  @override
  List<Object?> get props => [notes];
}

class SessionsUpdated extends CampaignEvent {
  final List<Map<String, dynamic>> sessions;

  const SessionsUpdated(this.sessions);

  @override
  List<Object?> get props => [sessions];
}
