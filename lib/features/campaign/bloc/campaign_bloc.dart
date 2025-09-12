import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';
import 'campaign_event.dart';
import 'campaign_state.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<DocumentSnapshot>? _campaignSub;
  StreamSubscription<QuerySnapshot>? _playersSub;

  Campaign? _currentCampaign;
  List<Character> _currentPlayers = [];

  CampaignBloc({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(CampaignInitial()) {
    on<CampaignStarted>(_onStarted);
    on<CampaignUpdated>(_onUpdated);
    on<AddSessionRequested>(_onAddSessionRequested);
    on<UpdateNotesRequested>(_onUpdateNotesRequested);
    on<JoinSessionRequested>(_onJoinSessionRequested);
    on<CampaignDataChanged>(_onCampaignDataChanged);
  }

  Future<void> _onStarted(
      CampaignStarted event, Emitter<CampaignState> emit) async {
    emit(CampaignLoading());

    try {
      _campaignSub?.cancel();
      _campaignSub = _firestore
          .collection('campaigns')
          .doc(event.campaignId)
          .snapshots()
          .listen((snap) {
        if (snap.exists) {
          final campaign = Campaign.fromDoc(snap);
          add(CampaignDataChanged(campaign, _currentPlayers));
        } else {
          add(const CampaignDataChanged(null, []));
        }
      });

      _playersSub?.cancel();
      _playersSub = _firestore
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('players')
          .snapshots()
          .listen((snap) {
        final characters =
            snap.docs.map((d) => Character.fromJson(d.data())).toList();
        add(CampaignDataChanged(_currentCampaign, characters));
      });
    } catch (e) {
      emit(CampaignFailure("Failed to load campaign: $e"));
    }
  }

  void _onCampaignDataChanged(
      CampaignDataChanged event, Emitter<CampaignState> emit) {
    if (event.campaign == null) {
      emit(const CampaignFailure("Campaign not found"));
      return;
    }
    _currentCampaign = event.campaign;
    _currentPlayers = event.players;

    final currentUser = _auth.currentUser;
    final isDm =
        currentUser != null && _currentCampaign!.hostId == currentUser.uid;

    emit(CampaignLoaded(
      campaign: _currentCampaign!,
      players: _currentPlayers,
      isDungeonMaster: isDm,
    ));
  }

  void _emitCombinedState(Emitter<CampaignState> emit) {
    if (_currentCampaign == null) return;

    final currentUser = _auth.currentUser;
    final isDm =
        currentUser != null && _currentCampaign!.hostId == currentUser.uid;

    emit(CampaignLoaded(
      campaign: _currentCampaign!,
      players: _currentPlayers,
      isDungeonMaster: isDm,
    ));
  }

  void _onUpdated(CampaignUpdated event, Emitter<CampaignState> emit) {
    // No longer used, state emitted via _emitCombinedState
  }

  Future<void> _onAddSessionRequested(
      AddSessionRequested event, Emitter<CampaignState> emit) async {
    try {
      final doc = _firestore.collection('campaigns').doc(event.campaignId);
      await doc.update({
        'sessions': FieldValue.arrayUnion([event.session])
      });
    } catch (e) {
      emit(CampaignFailure("Failed to add session: $e"));
    }
  }

  Future<void> _onUpdateNotesRequested(
      UpdateNotesRequested event, Emitter<CampaignState> emit) async {
    try {
      final doc = _firestore.collection('campaigns').doc(event.campaignId);
      await doc.update({
        'notes': event.notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(CampaignFailure("Failed to update notes: $e"));
    }
  }

  Future<void> _onJoinSessionRequested(
      JoinSessionRequested event, Emitter<CampaignState> emit) async {
    try {
      final campaignRef =
          _firestore.collection('campaigns').doc(event.campaignId);

      final snap = await campaignRef.get();
      if (!snap.exists) {
        emit(CampaignFailure("Campaign not found"));
        return;
      }

      final data = snap.data() as Map<String, dynamic>;
      final sessions = List<Map<String, dynamic>>.from(data['sessions'] ?? []);

      final index = sessions.indexWhere((s) => s['id'] == event.sessionId);
      if (index == -1) {
        emit(CampaignFailure("Session not found"));
        return;
      }

      final participants =
          (sessions[index]['participants'] as List<dynamic>? ?? []);
      if (!participants.contains(event.userId)) {
        participants.add(event.userId);
        sessions[index]['participants'] = participants;
        await campaignRef.update({'sessions': sessions});
      }

      // 🔑 Ensure Character doc exists in subcollection
      final charRef = campaignRef.collection('players').doc(event.userId);
      final charSnap = await charRef.get();
      if (!charSnap.exists) {
        final defaultCharacter = Character(
          id: event.userId,
          name: "New Adventurer",
          role: "adventurer",
          race: "human",
          level: 1,
          hp: 10,
          maxHp: 30,
          xp: 0.0,
          items: [],
          imageUrl: "",
        );
        await charRef.set(defaultCharacter.toJson());
      }
    } catch (e) {
      emit(CampaignFailure("Failed to join session: $e"));
    }
  }

  @override
  Future<void> close() {
    _campaignSub?.cancel();
    _playersSub?.cancel();
    return super.close();
  }
}
