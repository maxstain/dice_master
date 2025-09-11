import 'package:dice_master/core/connectivity/connectivity_cubit.dart';
import 'package:dice_master/core/connectivity/connectivity_snackbar_wrapper.dart';
import 'package:dice_master/features/splash/bloc/splash_bloc.dart';
import 'package:dice_master/features/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/themes.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DiceMasterApp());
}

class DiceMasterApp extends StatelessWidget {
  const DiceMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider(
          // Provide SplashBloc here
          create: (context) => SplashBloc(),
        ),
        BlocProvider(create: (_) => AuthBloc()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Dice Master',
            debugShowCheckedModeBanner: false,
            themeMode: themeState.mode,
            theme: DiceThemes.light(),
            darkTheme: DiceThemes.dark(),
            home: const SplashScreen(),
            builder: (context, child) {
              return BlocListener<AuthBloc, Object?>(
                listener: (context, state) {
                  if (state != null &&
                      state.runtimeType.toString() == 'AuthUnauthenticated') {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  }
                },
                child: ConnectivitySnackbarWrapper(child: child!),
              );
            },
          );
        },
      ),
    );
  }
}
