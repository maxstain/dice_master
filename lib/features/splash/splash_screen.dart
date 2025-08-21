import 'package:dice_master/features/auth/sign_in_screen.dart';
import 'package:dice_master/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'bloc/splash_bloc.dart';
import 'bloc/splash_event.dart';
import 'bloc/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .9, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    // Kick off splash logic post frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<SplashBloc>().add(SplashStarted());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToHome) {
          // Navigate to HomeScreen
          Navigator.of(context).pushReplacement(
            _animated(const HomeScreen()),
          ); // Or your preferred navigation method
        } else if (state is SplashNavigateToSignIn) {
          // Navigate to SignInScreen
          Navigator.of(context).pushReplacement(
            _animated(const SignInScreen()), // Replace with your SignInScreen
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primaryContainer, cs.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: cs.primary.withOpacity(.35),
                              blurRadius: 22,
                              spreadRadius: 2)
                        ],
                      ),
                      child: Lottie.asset(
                        'assets/lottie/d20_roll.json',
                        width: 120,
                        height: 120,
                        repeat: false, // play once like a dice roll
                        animate: true, // auto start
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Dice Master',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('D&D GM & Player Companion',
                        style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pushReplace(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(_animated(page));
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
