import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

class HomeAuthenticated extends HomeState {}

class HomeNotAuthenticated extends HomeState {}
