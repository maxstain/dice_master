import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Types for the Cubit
enum NotificationTypes { alert, error, warning, info }

class NotificationCubit extends Cubit<NotificationTypes> {
  late StreamSubscription<FlutterLocalNotificationsPlugin>
      _notificationSubscription;

  NotificationCubit() : super(NotificationTypes.alert);

  void _showNotification(NotificationTypes type) {
    emit(type);
  }

  void _hideNotification() {
    emit(NotificationTypes.alert);
  }

  String _getNotificationText(NotificationTypes type) {
    switch (type) {
      case NotificationTypes.alert:
        return 'Alert';
      case NotificationTypes.error:
        return 'Error';
      case NotificationTypes.warning:
        return 'Warning';
      case NotificationTypes.info:
        return 'Info';
    }
  }

  Color _getNotificationColor(NotificationTypes type) {
    switch (type) {
      case NotificationTypes.alert:
        return Colors.red;
      case NotificationTypes.error:
        return Colors.red;
      case NotificationTypes.warning:
        return Colors.orange;
      case NotificationTypes.info:
        return Colors.blue;
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription.cancel();
    return super.close();
  }
}
