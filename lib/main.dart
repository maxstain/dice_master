import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dice_master/core/connectivity/connectivity_cubit.dart';
import 'package:dice_master/core/connectivity/connectivity_snackbar_wrapper.dart';
import 'package:dice_master/core/notifications/notification_cubit.dart';
import 'package:dice_master/features/campaign/bloc/campaign_bloc.dart';
import 'package:dice_master/features/home/bloc/home_bloc.dart';
import 'package:dice_master/features/splash/bloc/splash_bloc.dart';
import 'package:dice_master/features/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/themes.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AwesomeNotifications().initialize(
    null, // use default icon, or provide drawable resource name on Android
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'General notifications',
        defaultColor: const Color(0xFF9D50DD),
        importance: NotificationImportance.High,
        ledColor: Colors.white,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_group',
        channelGroupName: 'Basic group',
      ),
    ],
    debug: kDebugMode,
  );

  // Request permission if needed
  final isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
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
        BlocProvider(create: (_) => NotificationCubit()),
        BlocProvider(
          create: (context) => SplashBloc(),
        ),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(
            create: (_) => HomeBloc()..add(const HomeTriggerInitialLoad())),
        BlocProvider(create: (_) => CampaignBloc())
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Dice Master',
            debugShowCheckedModeBanner: false,
            navigatorKey: appNavigatorKey,
            themeMode: themeState.mode,
            theme: DiceThemes.light(),
            darkTheme: DiceThemes.dark(),
            home: const SplashScreen(),
            builder: (context, child) {
              return BlocListener<AuthBloc, Object?>(
                listener: (context, state) {
                  if (state != null &&
                      state.runtimeType.toString() == 'AuthUnauthenticated') {
                    appNavigatorKey.currentState?.pushAndRemoveUntil(
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
