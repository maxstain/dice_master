import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  // Removed _auth from here, it will be in the BLoC
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  // Removed the validation logic from here, it's better handled in the UI or BLoC
  const SignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  const SignUpRequested(this.username, this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {}
