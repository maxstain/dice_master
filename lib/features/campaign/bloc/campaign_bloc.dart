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
  StreamSubscription<QuerySnapshot>? _sessionsSub;

  CampaignBloc() : super(CampaignLoading()) {
    on<CampaignStarted>(_onStarted);

    // Characters
    on<AddCharacterRequested>(_onAddCharacter);
    on<UpdateCharacterRequested>(_onUpdateCharacter);

    // Sessions (subcollection)
    on<AddSessionRequested>(_onAddSession);
    on<UpdateSessionRequested>(_onUpdateSession);
    on<DeleteSessionRequested>(_onDeleteSession);
    on<JoinSessionRequested>(_onJoinSession);

    // Notes (subcollection)
    on<AddNoteRequested>(_onAddNote);
    on<UpdateNoteRequested>(_onUpdateNote);
    on<DeleteNoteRequested>(_onDeleteNote);

    // Misc
    on<ClearMessagesRequested>(_onClearMessages);

    // Private events
    on<CampaignUpdated>(_onCampaignUpdated);
    on<PlayersUpdated>(_onPlayersUpdated);
    on<NotesUpdated>(_onNotesUpdated);
    on<SessionsUpdated>(_onSessionsUpdated);
  }

  // ===== Core =====
  Future<void> _onStarted(
      CampaignStarted event, Emitter<CampaignState> emit) async {
    emit(CampaignLoading());

    final campaignRef = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(event.campaignId);

    await _campaignSub?.cancel();
    await _playersSub?.cancel();
    await _notesSub?.cancel();
    await _sessionsSub?.cancel();

    _campaignSub = campaignRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        add(const CampaignUpdated(null));
        return;
      }
      final data = snapshot.data() as Map<String, dynamic>;
      final campaign = Campaign.fromJson({...data, 'id': snapshot.id});
      add(CampaignUpdated(campaign));

      _playersSub = campaignRef.collection('players').snapshots().listen((qs) {
        final players = qs.docs
            .map((doc) => Character.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
        add(PlayersUpdated(campaign, players));
      });

      _notesSub = campaignRef.collection('notes').snapshots().listen((qs) {
        final notes = qs.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .cast<Map<String, dynamic>>()
            .toList();
        add(NotesUpdated(notes));
      });

      _sessionsSub =
          campaignRef.collection('sessions').snapshots().listen((qs) {
        final sessions = qs.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .cast<Map<String, dynamic>>()
            .toList();
        add(SessionsUpdated(sessions));
      });
    });
  }

  // ===== Characters =====
  Future<void> _onAddCharacter(
      AddCharacterRequested event, Emitter<CampaignState> emit) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('players')
          .doc(event.characterData['id']);
      await ref.set(event.characterData);

      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded)
            .copyWith(successMessage: 'Character added successfully'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to add character: $e'));
    }
  }

  Future<void> _onUpdateCharacter(
      UpdateCharacterRequested event, Emitter<CampaignState> emit) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('players')
          .doc(event.characterId);
      await ref.update(event.characterData);

      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded)
            .copyWith(successMessage: 'Character updated successfully'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to update character: $e'));
    }
  }

  // ===== Sessions (subcollection) =====
  Future<void> _onAddSession(
      AddSessionRequested event, Emitter<CampaignState> emit) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('sessions')
          .doc(); // auto id
      await ref.set({
        ...event.sessionData,
        'createdAt': FieldValue.serverTimestamp(),
        // You can add 'participants': [] here if you want to initialize it
      });

      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded)
            .copyWith(successMessage: 'Session added successfully'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to add session: $e'));
    }
  }

  Future<void> _onSessionsUpdated(
      SessionsUpdated event, Emitter<CampaignState> emit) async {
    try {
      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded).copyWith(sessions: event.sessions));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to update sessions: $e'));
    }
  }

  Future<void> _onUpdateSession(
      UpdateSessionRequested event, Emitter<CampaignState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('sessions')
          .doc(event.sessionId)
          .update(event.sessionData);

      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded)
            .copyWith(successMessage: 'Session updated'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to update session: $e'));
    }
  }

  Future<void> _onDeleteSession(
      DeleteSessionRequested event, Emitter<CampaignState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('sessions')
          .doc(event.sessionId)
          .delete();

      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded)
            .copyWith(successMessage: 'Session deleted'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to delete session: $e'));
    }
  }

  Future<void> _onJoinSession(
      JoinSessionRequested event, Emitter<CampaignState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('sessions')
          .doc(event.sessionId)
          .update({
        'participants': FieldValue.arrayUnion([event.characterId]),
      });

      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded)
            .copyWith(successMessage: 'Joined session'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to join session: $e'));
    }
  }

  // ===== Notes (subcollection) =====
  Future<void> _onAddNote(
      AddNoteRequested event, Emitter<CampaignState> emit) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('notes')
          .doc();
      await ref.set(event.noteData);

      if (state is CampaignLoaded) {
        emit((state as CampaignLoaded).copyWith(successMessage: 'Note added'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to add note: $e'));
    }
  }

  Future<void> _onUpdateNote(
      UpdateNoteRequested event, Emitter<CampaignState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('notes')
          .doc(event.noteId)
          .update(event.noteData);

      if (state is CampaignLoaded) {
        emit(
            (state as CampaignLoaded).copyWith(successMessage: 'Note updated'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to update note: $e'));
    }
  }

  Future<void> _onDeleteNote(
      DeleteNoteRequested event, Emitter<CampaignState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('notes')
          .doc(event.noteId)
          .delete();

      if (state is CampaignLoaded) {
        emit(
            (state as CampaignLoaded).copyWith(successMessage: 'Note deleted'));
      }
    } catch (e) {
      emit(CampaignFailure('Failed to delete note: $e'));
    }
  }

  // ===== Misc =====
  void _onClearMessages(
      ClearMessagesRequested event, Emitter<CampaignState> emit) {
    if (state is CampaignLoaded) {
      emit((state as CampaignLoaded).copyWith(clearMessages: true));
    }
  }

  // ===== Private events =====
  void _onCampaignUpdated(CampaignUpdated event, Emitter<CampaignState> emit) {
    if (event.campaign == null) {
      emit(const CampaignFailure('Campaign not found'));
      return;
    }
    emit(CampaignLoaded(
      campaign: event.campaign!,
      players: const [],
      notes: const [],
      sessions: const [],
      isDungeonMaster: event.campaign!.hostId == event.campaign!.hostId,
    ));
  }

  /* ============================ Players =================================== */

  void _onPlayersUpdated(PlayersUpdated event, Emitter<CampaignState> emit) {
    if (state is CampaignLoaded) {
      emit((state as CampaignLoaded)
          .copyWith(players: event.players.cast<Character>()));
    }
  }

  void _onNotesUpdated(NotesUpdated event, Emitter<CampaignState> emit) {
    if (state is CampaignLoaded) {
      emit((state as CampaignLoaded).copyWith(notes: event.notes));
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
