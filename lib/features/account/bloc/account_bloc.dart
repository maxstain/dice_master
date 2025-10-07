import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountInitial()) {
    on<TriggerAccountInitial>(_onTriggerAccountInitial);
    on<TriggerAccountLoaded>(_onTriggerAccountLoaded);
    on<TriggerAccountFailure>(_onTriggerAccountFailure);
  }
}

Future<void> _onTriggerAccountInitial(
    TriggerAccountInitial event, Emitter<AccountState> emit) async {
  emit(const AccountLoading());
}

Future<void> _onTriggerAccountLoaded(
    TriggerAccountLoaded event, Emitter<AccountState> emit) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not found");
    emit(AccountLoaded(user));
  } catch (e) {
    emit(const AccountFailure("Something went wrong"));
  }
}

Future<void> _onTriggerAccountFailure(
    TriggerAccountFailure event, Emitter<AccountState> emit) async {
  emit(AccountFailure(event.message));
}
