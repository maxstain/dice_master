import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum NotificationTypes { alert, error, warning, info }

class NotificationCubit extends Cubit<NotificationTypes> {
  StreamSubscription<ReceivedAction>? _actionSub;

  NotificationCubit() : super(NotificationTypes.alert) {
    _listenToActions();
  }

  void _listenToActions() {
    _actionSub =
        AwesomeNotifications().actionStream.listen((ReceivedAction action) {
      final type = _mapCategoryToType(action.category);
      emit(type);
    });
  }

  NotificationTypes _mapCategoryToType(NotificationCategory? category) {
    switch (category) {
      case NotificationCategory.Alarm:
        return NotificationTypes.alert;
      case NotificationCategory.Error:
        return NotificationTypes.error;
      case NotificationCategory.Social:
        return NotificationTypes.info;
      default:
        return NotificationTypes.info;
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String channelKey = 'basic_channel',
    NotificationTypes type = NotificationTypes.info,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: _mapTypeToCategory(type),
        payload: payload,
      ),
    );
    emit(type); // reflect last shown type (optional)
  }

  NotificationCategory _mapTypeToCategory(NotificationTypes type) {
    switch (type) {
      case NotificationTypes.alert:
        return NotificationCategory.Alarm;
      case NotificationTypes.error:
        return NotificationCategory.Error;
      case NotificationTypes.warning:
        return NotificationCategory.Reminder;
      case NotificationTypes.info:
        return NotificationCategory.Social;
    }
  }

  Color getColor(NotificationTypes type) {
    switch (type) {
      case NotificationTypes.alert:
      case NotificationTypes.error:
        return Colors.red;
      case NotificationTypes.warning:
        return Colors.orange;
      case NotificationTypes.info:
        return Colors.blue;
    }
  }

  @override
  Future<void> close() async {
    await _actionSub?.cancel();
    return super.close();
  }
}

extension on AwesomeNotifications {
  get actionStream => null;
}
