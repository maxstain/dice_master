import 'package:dice_master/core/connectivity/connectivity_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivitySnackbarWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivitySnackbarWrapper({super.key, required this.child});

  @override
  State<ConnectivitySnackbarWrapper> createState() =>
      _ConnectivitySnackbarWrapperState();
}

class _ConnectivitySnackbarWrapperState
    extends State<ConnectivitySnackbarWrapper> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _wasConnected = true; // To track previous state for "Restored" message

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityStatus>(
      listener: (context, status) {
        _handleConnectivityChange(context, status);
      },
      child: widget.child,
    );
  }

  void _handleConnectivityChange(
      BuildContext context, ConnectivityStatus status) {
    final scaffoldMessenger =
        ScaffoldMessenger.of(context); // Get the root ScaffoldMessenger
    scaffoldMessenger.hideCurrentSnackBar(); // Hide any previous snackbar

    if (status == ConnectivityStatus.disconnected) {
      _wasConnected = false;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
          duration: Duration(days: 1),
          // Keep it shown until connection is back or manually dismissed
          behavior: SnackBarBehavior.floating, // Or .fixed
        ),
      );
    } else if (status == ConnectivityStatus.connected) {
      if (!_wasConnected) {
        // Only show "restored" if it was previously disconnected
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Internet connection restored'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _wasConnected = true;
    }
  }
}
