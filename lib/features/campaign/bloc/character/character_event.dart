part of 'character_bloc.dart';

/// Base
abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object?> get props => [];
}

class LoadCharacter extends CharacterEvent {
  final String campaignId;
  final String characterId;

  const LoadCharacter({required this.campaignId, required this.characterId});

  @override
  List<Object?> get props => [campaignId, characterId];
}

class TriggerAddItemToCharacter extends CharacterEvent {
  final String campaignId;
  final String characterId;
  final ItemRepo item;

  const TriggerAddItemToCharacter({
    required this.campaignId,
    required this.characterId,
    required this.item,
  });

  @override
  List<Object?> get props => [campaignId, characterId, item];
}
