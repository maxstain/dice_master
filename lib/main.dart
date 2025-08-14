import 'package:dice_master/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/themes.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DiceMasterApp());
}

class DiceMasterApp extends StatelessWidget {
  const DiceMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
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
          );
        },
      ),
    );
  }
}
