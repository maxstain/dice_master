part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class TriggerAccountLoaded extends AccountEvent {
  const TriggerAccountLoaded();
}

class TriggerAccountFailure extends AccountEvent {
  final String message;

  const TriggerAccountFailure(this.message);
}

class TriggerAccountSuccess extends AccountEvent {
  const TriggerAccountSuccess();
}

class TriggerAccountLoading extends AccountEvent {
  const TriggerAccountLoading();
}

class TriggerAccountInitial extends AccountEvent {
  const TriggerAccountInitial();
}
