import 'package:equatable/equatable.dart';

import '../../../models/campaign.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before anything happens
class HomeInitial extends HomeState {}

/// When campaigns are being loaded
class HomeLoading extends HomeState {}

/// When user is not authenticated
class HomeNotAuthenticated extends HomeState {}

/// When campaigns successfully loaded
class HomeLoaded extends HomeState {
  final List<Campaign> campaigns;

  const HomeLoaded({required this.campaigns});

  @override
  List<Object?> get props => [campaigns];
}

/// When something goes wrong
class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
