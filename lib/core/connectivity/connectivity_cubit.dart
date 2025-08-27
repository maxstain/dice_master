import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// States for the Cubit
enum ConnectivityStatus { initial, connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  ConnectivityCubit() : super(ConnectivityStatus.initial) {
    // Check initial connectivity status
    _checkInitialStatus();

    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialStatus() async {
    List<ConnectivityResult> connectivityResult;
    try {
      connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResult);
    } catch (e) {
      print("Couldn't check connectivity status: $e");
      emit(ConnectivityStatus.disconnected); // Assume disconnected if error
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    // The result is a list because some platforms might support multiple network interfaces.
    // For simplicity, we're checking if any of them is not 'none'.
    if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet) ||
        result.contains(ConnectivityResult.vpn)) {
      if (state == ConnectivityStatus.disconnected ||
          state == ConnectivityStatus.initial) {
        // Only emit connected if it was previously disconnected or initial to avoid spamming
        emit(ConnectivityStatus.connected);
      }
    } else if (result.contains(ConnectivityResult.none)) {
      if (state == ConnectivityStatus.connected ||
          state == ConnectivityStatus.initial) {
        // Only emit disconnected if it was previously connected or initial
        emit(ConnectivityStatus.disconnected);
      }
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
