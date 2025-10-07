part of 'settings_bloc.dart';

class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class TriggerSettingsInitial extends SettingsEvent {
  const TriggerSettingsInitial();
}

class TriggerSettingsLoading extends SettingsEvent {
  const TriggerSettingsLoading();
}

class TriggerSettingsSuccess extends SettingsEvent {
  const TriggerSettingsSuccess();
}

class TriggerSettingsFailure extends SettingsEvent {
  const TriggerSettingsFailure();
}
