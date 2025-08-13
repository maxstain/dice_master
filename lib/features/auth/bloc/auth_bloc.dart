import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 900));
    // TODO: Replace with real auth; this is a dummy check
    if (event.email.contains('@') && event.password.length >= 6) {
      emit(AuthAuthenticated());
    } else {
      emit(const AuthFailure('Invalid credentials.'));
    }
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1200));
    // TODO: Replace with real sign-up
    if (event.email.contains('@') && event.password.length >= 6) {
      emit(AuthAuthenticated());
    } else {
      emit(const AuthFailure('Could not create account.'));
    }
  }
}
