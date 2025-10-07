import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(AuthInitial()) {
    // Start with AuthInitial
    // Listen to Firebase auth state changes
    _userSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(AuthUserChanged(user)); // Add internal event
    });

    on<AuthUserChanged>(_onAuthUserChanged);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      // Check if already authenticated with the same user
      if (state is AuthAuthenticated &&
          (state as AuthAuthenticated).user.uid == user.uid) {
        print(
            'AuthBloc: AuthUserChanged - User ${user.uid} already authenticated. No state change.');
        return;
      }
      print('AuthBloc: User Authenticated - ${user.uid}');
      emit(AuthAuthenticated(user));
    } else {
      // Check if already unauthenticated
      if (state is AuthUnauthenticated) {
        print(
            'AuthBloc: AuthUserChanged - Already unauthenticated. No state change.');
        return;
      }
      print('AuthBloc: User Unauthenticated - Emitting AuthUnauthenticated');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onDeleteAccountRequested(
      DeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = _firebaseAuth.currentUser;
      await user?.delete();
      emit(AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(
          AuthFailure(e.message ?? 'Delete account failed. Please try again.'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
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
      await user.user?.updateDisplayName(event.username);
      await _firestore.collection('users').doc(user.user!.uid).set({
        'username': event.username,
        'email': event.email,
        'profilePictureUrl': user.user!.photoURL ?? '',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
      // Auth state will be updated by _onAuthUserChanged via the stream
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Sign up failed. Please try again.'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Ensures loading state is emitted
    try {
      await _firebaseAuth.signOut();
      // Emit unauthenticated immediately as a fallback; stream will also update
      emit(AuthUnauthenticated());
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
