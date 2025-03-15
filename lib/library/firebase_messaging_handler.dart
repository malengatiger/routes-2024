import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kasie_transie_library/data/commuter_cash_payment.dart';
import 'package:kasie_transie_library/data/constants.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
class FirebaseMessagingHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const mm = '🍅🍅🍅🍅 FirebaseMessagingHandler  🍅 🔵🔵';

  final StreamController<DispatchRecord> _dispatchesController = StreamController.broadcast();
  final StreamController<Trip> _tripsController = StreamController.broadcast();
  final StreamController<CommuterCashPayment> _commuterCashController = StreamController.broadcast();
  final StreamController<AmbassadorPassengerCount> _passengerCountController = StreamController.broadcast();
  final StreamController<VehicleTelemetry> _telemetryController = StreamController.broadcast();
  final StreamController<VehicleArrival> _arrivalController = StreamController.broadcast();

  Stream<DispatchRecord> get dispatchStream => _dispatchesController.stream;
  Stream<Trip> get tripStream => _tripsController.stream;
  Stream<CommuterCashPayment> get commuterCashStream => _commuterCashController.stream;
  Stream<AmbassadorPassengerCount> get passengerCountStream => _passengerCountController.stream;
  Stream<VehicleArrival> get arrivalStream => _arrivalController.stream;
  Stream<VehicleTelemetry> get telemetryStream => _telemetryController.stream;

  FirebaseMessagingHandler() {
    initialize();
  }

  deployMessage(RemoteMessage msg) async {
    var type = msg.data['type'];
    var json = jsonDecode(msg.data['data']);

    switch (type) {
      case Constants.passengerCount:
        pp('$mm ... received PassengerCount');
        _passengerCountController.sink.add(AmbassadorPassengerCount.fromJson(json));
        break;
      case Constants.dispatchRecord:
        pp('$mm ... received DispatchRecord');
        _dispatchesController.sink.add(DispatchRecord.fromJson(json));
        break;
      case Constants.commuterCashPayment:
        pp('$mm ... received CommuterCashPayment');
        _commuterCashController.sink.add(CommuterCashPayment.fromJson(json));
        break;
      case Constants.vehicleArrival:
        pp('$mm ... received VehicleArrival');
        _arrivalController.sink.add(VehicleArrival.fromJson(json));
        break;
      case Constants.telemetry:
        pp('$mm ... received VehicleTelemetry');
        _telemetryController.sink.add(VehicleTelemetry.fromJson(json));
        break;
      case Constants.trips:
        pp('$mm ... received Trip');
        _tripsController.sink.add(Trip.fromJson(json));
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
      pp('$mm User granted permission');
    } else {
      pp('User declined or has not accepted permission');
    }

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    pp('$mm FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // pp('\n\n$mm Received a message while in the foreground; data: ${message.data}');
      // if (message.notification != null) {
      //   pp('$mm Message notification title: ${message.notification?.title}');
      //   pp('$mm Message notification body: ${message.notification?.body}');
      // }

      deployMessage(message);

    });



    // Handle background messages (already handled in firebase-messaging-sw.js)
  }
}
