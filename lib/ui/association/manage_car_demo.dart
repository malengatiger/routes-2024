import 'dart:async';
import 'dart:collection';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/commuter_cash_payment.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/route_data.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as web;
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class ManageCarDemo extends StatefulWidget {
  const ManageCarDemo(
      {super.key,
      required this.route,
      required this.car,
      required this.ambassador,
      required this.marshal,
      required this.routeData});

  final RouteData routeData;
  final lib.Route route;
  final lib.Vehicle car;
  final lib.User ambassador;
  final lib.User marshal;

  @override
  ManageCarDemoState createState() => ManageCarDemoState();
}

class ManageCarDemoState extends State<ManageCarDemo> {
  static const mm = '😡😡😡😡😡 ManageCarDemo 😡';

  List<lib.VehicleTelemetry> telemetry = [];
  List<lib.DispatchRecord> dispatches = [];
  List<lib.AmbassadorPassengerCount> passengerCounts = [];
  List<CommuterCashPayment> cashPayments = [];
  List<lib.Trip> trips = [];
  bool busy = false;

  late StreamSubscription<lib.VehicleTelemetry> telemetrySub;
  late StreamSubscription<lib.DispatchRecord> dispatchesSub;
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerCountSub;
  late StreamSubscription<CommuterCashPayment> commuterCashSub;
  late StreamSubscription<lib.Trip> tripSub;

  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};
  List<lib.RoutePoint> rpList = [];
  List<lib.RoutePoint> routePoints = [];
  List<lib.RouteLandmark> routeLandmarks = [];
  int landmarkIndex = 0;
  String? stringColor;
  List<LatLng>? polylinePoints;
  Color color = Colors.black;
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  Prefs prefs = GetIt.instance<Prefs>();

  bool gettingData = false;
  @override
  void initState() {
    super.initState();
    _setCameraPosition();
  }

  _setCameraPosition() {
    var landmark = widget.routeData.landmarks[0];
    var latLng = LatLng(
        landmark.position!.coordinates[1], landmark.position!.coordinates[0]);
    _myCurrentCameraPosition = CameraPosition(target: latLng);
    pp('$mm ... _myCurrentCameraPosition: $latLng');
  }

  Future _putMarkersOnMap() async {
    pp('$mm _putMarkersOnMap ...  route: ${widget.routeData.route!.name!}; dispatches: ${dispatches.length} ');

    _markers.clear();
    landmarkIndex = 0;
    // routeLandmarks.sort((a,b) => a.index!.compareTo(b.index!));
    for (var dr in dispatches) {
      final latLng =
          LatLng(dr.position!.coordinates.last, dr.position!.coordinates.first);
      pp('$mm  ... latLng: $latLng} ... ');

      final icon = await getMarkerBitmap(72,
          text: '${landmarkIndex + 1}',
          color: widget.routeData.route!.color! ?? 'black',
          fontSize: 14,
          fontWeight: FontWeight.w900);
      pp('$mm  ... landmarkIndex: $landmarkIndex} ... adding marker');

      _markers.add(Marker(
          markerId: MarkerId('${dr.dispatchRecordId}'),
          icon: icon,
          onTap: () {
            pp('$mm .............. marker tapped, index: '
                'dispatchRecordId: ${dr.dispatchRecordId} - routeId: ${dr.routeId}');
          },
          infoWindow: InfoWindow(
              snippet:
                  '\nThis dr happened the route:\n ${widget.routeData.route!.name}\n\n',
              title: '🍎 ${dr.landmarkName}',
              onTap: () {
                pp('$mm ............. infoWindow tapped, car: ${dr.vehicleReg}');
                //_deleteLandmark(dr);
              }),
          position: latLng));
      landmarkIndex++;
    }

    setState(() {});
  }

  bool isHybrid = true;
  final Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController googleMapController;
  CameraPosition? _myCurrentCameraPosition;

  @override
  Widget build(BuildContext context) {
    var pCounts = 0;
    for (var pc in passengerCounts) {
      pCounts += pc.passengersIn!;
    }
    var nf = NumberFormat('###,###,##0.00');
    var cash = 0.0;
    for (var pc in cashPayments) {
      cash += pc.amount!;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Car Demo'),
        ),
        body: SafeArea(
            child: Stack(
          children: [
            Row(
              children: [
                SizedBox(
                    width: 1000,
                    child: _myCurrentCameraPosition == null
                        ? gapW32
                        : GoogleMap(
                            mapType: isHybrid ? MapType.hybrid : MapType.normal,
                            myLocationEnabled: true,
                            markers: _markers,
                            circles: _circles,
                            polylines: _polyLines,
                            initialCameraPosition: _myCurrentCameraPosition ??
                                CameraPosition(target: LatLng(0, 0)),
                            onTap: (latLng) {
                              pp('$mm .......... on map tapped : $latLng .');
                            },
                            onMapCreated:
                                (GoogleMapController controller) async {
                              pp('$mm ......... GoogleMap: onMapCreated : ${controller.toString()} ....... on to Cleveland!');
                              _mapController.complete(controller);
                            },
                          )),
                gapW32,
                SizedBox(
                    width: 600,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            DataCard(
                                number: dispatches.length,
                                text: 'Taxi Dispatches',
                                color: Colors.teal),
                            DataCard(number: trips.length, text: 'Trips'),
                            gapH16,
                            DataCard(
                              number: pCounts,
                              text: 'Passengers',
                              color: Colors.red,
                            ),
                            gapH16,
                            DataCard(
                                number: cashPayments.length,
                                text: 'Cash Payment Transactions'),
                            gapH16,
                            Row(
                              children: [
                                Text(nf.format(cash),
                                    style: myTextStyle(fontSize: 16)),
                                gapW32,
                                Text(nf.format(cash),
                                    style: myTextStyle(
                                        fontSize: 24, weight: FontWeight.w900)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ))
              ],
            )
          ],
        )));
  }
}

class DataCard extends StatelessWidget {
  const DataCard(
      {super.key, required this.number, required this.text, this.color});

  final int number;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    var nf = NumberFormat('###,##0');
    return Card(
        elevation: 8,
        child: SizedBox(
            height: 200,
            child: Column(
              children: [
                bd.Badge(
                  badgeContent: Text(nf.format(number)),
                  badgeStyle: bd.BadgeStyle(
                      badgeColor: color ?? Colors.black,
                      padding: EdgeInsets.all(16)),
                ),
                gapH16,
                Text(text, style: myTextStyle(fontSize: 16))
              ],
            )));
  }
}
