import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(AuthInitial()) {
    // Start with AuthInitial
    // Listen to Firebase auth state changes
    _userSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(_AuthUserChanged(user)); // Add internal event
    });

    on<_AuthUserChanged>(_onAuthUserChanged);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  void _onAuthUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      print('AuthBloc: User Authenticated - ${event.user!.uid}');
      emit(AuthAuthenticated(event.user!));
    } else {
      print(
          'AuthBloc: User Unauthenticated - Emitting AuthUnauthenticated'); // Key log
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Basic validation (consider moving to UI or a form validation helper)
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthFailure('Email and password cannot be empty.'));
        return;
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(event.email)) {
        emit(const AuthFailure('Invalid email format.'));
        return;
      }

      await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      // Auth state will be updated by _onAuthUserChanged via the stream
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Sign in failed. Please try again.'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Basic validation
      if (event.username.isEmpty ||
          event.email.isEmpty ||
          event.password.isEmpty) {
        emit(const AuthFailure('Fields cannot be empty.'));
        return;
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(event.email)) {
        emit(const AuthFailure('Invalid email format.'));
        return;
      }
      if (event.password.length < 6) {
        // Firebase requires 6 chars min
        emit(const AuthFailure('Password must be at least 6 characters.'));
        return;
      }

      var user = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: event.email,
            password: event.password,
          )
          .then(
            (userCredential) => userCredential,
          );
      // Set display name after user creation
      await user.user?.updateProfile(displayName: event.username);
      // Auth state will be updated by _onAuthUserChanged via the stream
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Sign up failed. Please try again.'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Optional: show loading state during sign out
    try {
      await _firebaseAuth.signOut();
      // Auth state will be updated by _onAuthUserChanged via the stream
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

class _AuthUserChanged extends AuthEvent {
  final User? user;

  const _AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
