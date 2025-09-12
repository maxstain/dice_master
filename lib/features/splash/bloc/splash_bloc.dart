import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashLoading()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(
      SplashStarted event, Emitter<SplashState> emit) async {
    await Future.delayed(const Duration(milliseconds: 3000));
    final user = FirebaseAuth.instance.currentUser;
    emit(user != null ? SplashNavigateToHome() : SplashNavigateToSignIn());
  }
}
