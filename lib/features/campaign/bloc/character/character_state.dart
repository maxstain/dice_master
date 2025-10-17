part of 'character_bloc.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object?> get props => [];
}

class CharacterInitial extends CharacterState {
  const CharacterInitial();
}

class CharacterLoading extends CharacterState {
  @override
  List<Object?> get props => [];
}

class CharacterLoaded extends CharacterState {
  final Character character;

  const CharacterLoaded(this.character);

  @override
  List<Object?> get props => [character];
}

class CharacterFailure extends CharacterState {
  final String message;

  const CharacterFailure(this.message);

  @override
  List<Object?> get props => [message];
}
