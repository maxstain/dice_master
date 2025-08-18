import 'package:dice_master/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme_cubit.dart';
import './features.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final curved =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme (light/dark/system)',
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<ThemeCubit>().toggle(),
          )
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to home screen on successful sign-in
            Navigator.of(context).pushAndRemoveUntil(
              _animated(const HomeScreen()),
              (route) => false,
            );
          } else if (state is AuthFailure) {
            // Show error message if unauthenticated
            // FIXME: This condition is duplicated below. The first one might be intended for a different state.
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please sign in to continue')));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, .06), end: Offset.zero)
                        .animate(curved),
                    child: Card(
                      elevation: 0,
                      color: cs.surfaceContainer,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          // Added SingleChildScrollView here
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.casino, color: cs.primary),
                                    const SizedBox(width: 8),
                                    Text('Welcome back',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _email,
                                  decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined)),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v != null && v.contains('@')
                                      ? null
                                      : 'Enter a valid email',
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _password,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                      icon: Icon(_obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                  ),
                                  obscureText: _obscure,
                                  validator: (v) => v != null && v.length >= 6
                                      ? null
                                      : 'Min 6 characters',
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: loading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<AuthBloc>().add(
                                                SignInRequested(
                                                    _email.text.trim(),
                                                    _password.text.trim()));
                                          }
                                        },
                                  child: loading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Text('Sign In'),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .push(_animated(const SignUpScreen())),
                                  child: const Text(
                                      "Don't have an account? Sign Up"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PageRouteBuilder _animated(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, .03), end: Offset.zero)
                    .animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
