import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    on<TriggerSettingsInitial>(_onTriggerSettingsInitial);
    on<TriggerSettingsLoading>(_onTriggerSettingsLoading);
    on<TriggerSettingsSuccess>(_onTriggerSettingsSuccess);
  }
}

Future<void> _onTriggerSettingsSuccess(
    TriggerSettingsSuccess event, Emitter<SettingsState> emit) async {
  emit(const SettingsLoaded("John Doe"));
}

Future<void> _onTriggerSettingsLoading(
    TriggerSettingsLoading event, Emitter<SettingsState> emit) async {
  emit(const SettingsLoaded("John Doe"));
}

Future<void> _onTriggerSettingsInitial(
    TriggerSettingsInitial event, Emitter<SettingsState> emit) async {
  emit(const SettingsLoaded("John Doe"));
}
