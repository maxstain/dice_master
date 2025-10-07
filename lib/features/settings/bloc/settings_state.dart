part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final String username;

  const SettingsLoaded(this.username);
}

class SettingsFailure extends SettingsState {
  final String message;

  const SettingsFailure(this.message);
}
