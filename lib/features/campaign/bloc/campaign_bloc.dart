import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';
import 'campaign_event.dart';
import 'campaign_state.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  StreamSubscription<DocumentSnapshot>? _campaignSub;
  StreamSubscription<QuerySnapshot>? _playersSub;
  StreamSubscription<QuerySnapshot>? _notesSub;

  CampaignBloc() : super(CampaignLoading()) {
    on<CampaignStarted>(_onStarted);

    on<AddCharacterRequested>(_onAddCharacter);
    on<AddSessionRequested>(_onAddSession);

    on<AddNoteRequested>(_onAddNote);
    on<UpdateNoteRequested>(_onUpdateNote);
    on<DeleteNoteRequested>(_onDeleteNote);

    on<UpdateNotesRequested>(_onUpdateNotes);
    on<JoinSessionRequested>(_onJoinSession);
    on<ClearMessagesRequested>(_onClearMessages);

    // Private stream events
    on<CampaignUpdated>(_onCampaignUpdated);
    on<PlayersUpdated>(_onPlayersUpdated);
    on<NotesUpdated>(_onNotesUpdated);
  }

  Future<void> _onStarted(
      CampaignStarted event, Emitter<CampaignState> emit) async {
    emit(CampaignLoading());

    final campaignRef = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(event.campaignId);

    await _campaignSub?.cancel();
    await _playersSub?.cancel();
    await _notesSub?.cancel();

    _campaignSub = campaignRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        add(const CampaignUpdated(null));
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final campaign = Campaign.fromJson({...data, 'id': snapshot.id});
      add(CampaignUpdated(campaign));

      // Players sub
      _playersSub = campaignRef.collection('players').snapshots().listen((qs) {
        final players = qs.docs
            .map((doc) => Character.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
        add(PlayersUpdated(campaign, players));
      });

      // Notes sub
      _notesSub = campaignRef.collection('notes').snapshots().listen((qs) {
        final notes = qs.docs
            .map((doc) => {...doc.data(), "id": doc.id})
            .cast<Map<String, dynamic>>()
            .toList();
        add(NotesUpdated(notes));
      });
    });
  }

  // === Characters ===
  Future<void> _onAddCharacter(
      AddCharacterRequested event, Emitter<CampaignState> emit) async {
    final ref = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(event.campaignId)
        .collection('players')
        .doc(event.characterData['id']);
    await ref.set(event.characterData);
  }

  // === Sessions ===
  Future<void> _onAddSession(
      AddSessionRequested event, Emitter<CampaignState> emit) async {
    final ref = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(event.campaignId);

    await ref.update({
      "sessions": FieldValue.arrayUnion([event.sessionData]),
    });
  }

  // === Notes ===
  Future<void> _onAddNote(
      AddNoteRequested event, Emitter<CampaignState> emit) async {
    final ref = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(event.campaignId)
        .collection('notes')
        .doc();

    await ref.set(event.noteData);
  }

  Future<void> _onUpdateNote(
      UpdateNoteRequested event, Emitter<CampaignState> emit) async {
    final ref = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(event.campaignId)
        .collection('notes')
        .doc(event.noteId);

    await ref.update(event.noteData);
  }

  Future<void> _onDeleteNote(
      DeleteNoteRequested event, Emitter<CampaignState> emit) async {
    final ref = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(event.campaignId)
        .collection('notes')
        .doc(event.noteId);

    await ref.delete();
  }

  // === Misc ===
  Future<void> _onUpdateNotes(
      UpdateNotesRequested event, Emitter<CampaignState> emit) async {
    // Deprecated: we now use subcollection
  }

  Future<void> _onJoinSession(
      JoinSessionRequested event, Emitter<CampaignState> emit) async {
    final ref = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(event.campaignId)
        .collection('sessions')
        .doc(event.sessionId);

    await ref.update({
      "participants": FieldValue.arrayUnion([event.characterId]),
    });
  }

  void _onClearMessages(
      ClearMessagesRequested event, Emitter<CampaignState> emit) {
    if (state is CampaignLoaded) {
      emit((state as CampaignLoaded).copyWith(clearMessages: true));
    }
  }

  // === Private events ===
  void _onCampaignUpdated(CampaignUpdated event, Emitter<CampaignState> emit) {
    if (event.campaign == null) {
      emit(const CampaignFailure("Campaign not found"));
      return;
    }

    emit(CampaignLoaded(
      campaign: event.campaign!,
      players: const [],
      notes: const [],
      isDungeonMaster: false,
    ));
  }

  void _onPlayersUpdated(PlayersUpdated event, Emitter<CampaignState> emit) {
    if (state is CampaignLoaded) {
      emit((state as CampaignLoaded).copyWith(
        players: event.players.cast<Character>(),
      ));
    }
  }

  void _onNotesUpdated(NotesUpdated event, Emitter<CampaignState> emit) {
    if (state is CampaignLoaded) {
      emit((state as CampaignLoaded).copyWith(
        notes: event.notes,
      ));
    }
  }

  @override
  Future<void> close() {
    _campaignSub?.cancel();
    _playersSub?.cancel();
    _notesSub?.cancel();
    return super.close();
  }
}
