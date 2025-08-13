import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashLoading extends SplashState {}

class SplashNavigateToSignIn extends SplashState {}

class SplashNavigateToHome extends SplashState {}
