import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashLoading()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(
      SplashStarted event, Emitter<SplashState> emit) async {
    // Simulate startup work & auth check
    await Future.delayed(const Duration(milliseconds: 1400));
    // TODO: Plug your auth status here
    final isAuthenticated = false;
    if (isAuthenticated) {
      emit(SplashNavigateToHome());
    } else {
      emit(SplashNavigateToSignIn());
    }
  }
}
