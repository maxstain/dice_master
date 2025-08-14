import 'dart:async';

import 'package:dice_master/features/home/bloc/home_event.dart';
import 'package:dice_master/features/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoading()) {
    on<HomeStarted>(_onStarted);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    // Simulate startup work & auth check
    await Future.delayed(const Duration(seconds: 2));
    // Here you would typically check if the user is authenticated
    final isAuthenticated = true; // Replace with actual auth check
    if (isAuthenticated) {
      emit(HomeAuthenticated());
    } else {
      emit(HomeNotAuthenticated());
    }
  }
}
