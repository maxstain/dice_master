import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountInitial()) {
    on<TriggerAccountInitial>(_onTriggerAccountInitial);
    on<TriggerAccountLoaded>(_onTriggerAccountLoaded);
    on<TriggerAccountFailure>(_onTriggerAccountFailure);
    on<TriggerAccountUpdate>(_onTriggerAccountUpdate);
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

Future<void> _onTriggerAccountUpdate(
    TriggerAccountUpdate event, Emitter<AccountState> emit) async {
  emit(const AccountLoading());
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not found");
    if (event.email != user.email) {
      await user.verifyBeforeUpdateEmail(event.email);
    }

    if (event.displayName.isNotEmpty) {
      await user.updateDisplayName(event.displayName);
    }
    if (event.photoURL.isNotEmpty) await user.updatePhotoURL(event.photoURL);
    if (event.phoneNumber != user.phoneNumber) {
      // await user.updatePhoneNumber(
      //     PhoneAuthProvider.credential(verificationId: '', smsCode: ''));
    }
    final updatedUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(updatedUser!.uid)
        .update({
      'displayName': event.displayName,
      'profilePictureUrl': event.photoURL,
      'email': event.email,
      'phoneNumber': event.phoneNumber,
    });
    emit(AccountLoaded(updatedUser!));
  } catch (e) {
    emit(AccountFailure(e.toString()));
  }
}
