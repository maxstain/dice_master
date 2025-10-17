import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/character.dart';
import 'package:dice_master/models/item/itemRepo.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CharacterBloc({required this.firestore, required this.auth})
      : super(const CharacterInitial()) {
    on<LoadCharacter>(_onLoadCharacter);
    on<TriggerAddItemToCharacter>(_onAddItemToCharacter);
  }

  Future<void> _onLoadCharacter(
      LoadCharacter event, Emitter<CharacterState> emit) async {
    emit(CharacterLoading());
    try {
      final user = auth.currentUser;
      if (user == null) {
        emit(const CharacterFailure('User not authenticated'));
        return;
      }

      final characterDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('characters')
          .doc(event.characterId)
          .get();

      if (!characterDoc.exists) {
        emit(const CharacterFailure('Character not found'));
        return;
      }

      final character = Character.fromJson(characterDoc.data()!);

      emit(CharacterLoaded(character));
    } catch (e) {
      emit(CharacterFailure(e.toString()));
    }
  }

  Future<void> _onAddItemToCharacter(
      TriggerAddItemToCharacter event, Emitter<CharacterState> emit) async {
    if (state is! CharacterLoaded) return;

    final currentState = state as CharacterLoaded;
    final character = currentState.character;

    try {
      final user = auth.currentUser;
      if (user == null) {
        emit(const CharacterFailure('User not authenticated'));
        return;
      }

      // Update Firestore
      final characterRef = firestore
          .collection('campaigns')
          .doc(event.campaignId)
          .collection('players')
          .doc(event.characterId);

      await characterRef.update({
        'items': FieldValue.arrayUnion([event.item.toJson()]),
      });
      // Update local state
      character.items.add(event.item);
      emit(CharacterLoaded(character));
    } catch (e) {
      emit(CharacterFailure(e.toString()));
    }
  }
}
