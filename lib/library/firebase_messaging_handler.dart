import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kasie_transie_library/data/constants.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
class FirebaseMessagingHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const mm = '🍅🍅🍅🍅 FirebaseMessagingHandler  🍅 🔵🔵';

  final StreamController<VehicleTelemetry> _dispatchesController = StreamController.broadcast();
  final StreamController<VehicleTelemetry> _tripsController = StreamController.broadcast();
  final StreamController<VehicleTelemetry> _commuterCashController = StreamController.broadcast();
  final StreamController<VehicleTelemetry> _passengerCountController = StreamController.broadcast();
  final StreamController<VehicleTelemetry> _telemetryController = StreamController.broadcast();

  setUp(RemoteMessage msg) async {
    pp('$mm process received message: ${msg.messageId}');
    var type = msg.data['type'];
    switch (type) {
      case Constants.passengerCount:
        pp('$mm ... received PassengerCount');
        break;
      case Constants.dispatchRecord:
        pp('$mm ... received DispatchRecord');
        break;
      case Constants.commuterCashPayment:
        pp('$mm ... received CommuterCashPayment');
        break;
      case Constants.vehicleArrival:
        pp('$mm ... received VehicleArrival');
        break;
      case Constants.telemetry:
        pp('$mm ... received VehicleTelemetry');
        break;
    }

  }

  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      pp('User granted permission');
    } else {
      pp('User declined or has not accepted permission');
    }

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    pp('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      pp('$mm ... Received a message while in the foreground:');
      pp('$mm Message data: ${message.data}');

      setUp(message);
      if (message.notification != null) {
        pp('$mm Message notification title: ${message.notification?.title}');
        pp('$mm Message notification body: ${message.notification?.body}');
      }
    });



    // Handle background messages (already handled in firebase-messaging-sw.js)
  }
}
