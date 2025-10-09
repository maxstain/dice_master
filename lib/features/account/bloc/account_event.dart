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

class TriggerAccountUpdate extends AccountEvent {
  final String displayName;
  final String photoURL;
  final String phoneNumber;
  final String email;

  const TriggerAccountUpdate({
    required this.displayName,
    required this.photoURL,
    required this.email,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [displayName, photoURL, email, phoneNumber];
}
