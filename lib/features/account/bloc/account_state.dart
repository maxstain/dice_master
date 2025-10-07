part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountLoaded extends AccountState {
  final User user;

  const AccountLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class AccountFailure extends AccountState {
  final String message;

  const AccountFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AccountSuccess extends AccountState {
  const AccountSuccess();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountInitial extends AccountState {
  const AccountInitial();
}
