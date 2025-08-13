import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeState extends Equatable {
  final ThemeMode mode;

  const ThemeState(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.system));

  /// Cycles through: light -> dark -> system -> light ...
  void toggle() {
    final next = state.mode == ThemeMode.light
        ? ThemeMode.dark
        : state.mode == ThemeMode.dark
            ? ThemeMode.system
            : ThemeMode.light;
    emit(ThemeState(next));
  }
}
