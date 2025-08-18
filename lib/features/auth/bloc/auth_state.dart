import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {} // Represents the state before we've checked auth status

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user; // Hold the Firebase User object

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {} // Explicitly unauthenticated

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
