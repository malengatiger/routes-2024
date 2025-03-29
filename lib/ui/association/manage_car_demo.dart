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
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:routes_2024/library/firebase_messaging_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  late StreamSubscription<lib.VehicleTelemetry> telemetrySub;
  late StreamSubscription<lib.DispatchRecord> dispatchesSub;
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerCountSub;
  late StreamSubscription<CommuterCashPayment> commuterCashSub;
  late StreamSubscription<lib.Trip> tripSub;
  late StreamSubscription<lib.VehicleArrival> arrivalsSub;

  final Set<Marker> _markers = HashSet();
  final Set<Marker> _landmarkMarkers = HashSet();
  final Set<Marker> _allMarkers = HashSet();

  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};
  List<lib.RoutePoint> rpList = [];
  List<lib.RoutePoint> routePoints = [];
  List<lib.RouteLandmark> routeLandmarks = [];
  List<lib.VehicleArrival> arrivals = [];

  int landmarkIndex = 0;
  String? stringColor;
  List<LatLng>? polylinePoints;
  Color color = Colors.black;
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  Prefs prefs = GetIt.instance<Prefs>();
  FirebaseMessagingHandler handler = GetIt.instance<FirebaseMessagingHandler>();

  bool gettingData = false;

  @override
  void initState() {
    super.initState();
    _setCameraPosition();
    _listen();
   
  }

  @override
  void dispose() {
    telemetrySub.cancel();
    dispatchesSub.cancel();
    passengerCountSub.cancel();
    commuterCashSub.cancel();
    tripSub.cancel();
    arrivalsSub.cancel();
    super.dispose();
  }

  _listen() async {
    arrivalsSub = handler.arrivalStream.listen((onData) {
      pp('\n\n$mm arrivalStream received arrival car: ... ${onData.toJson()}');
      var isFound = false;
      for (var arrival in arrivals) {
        if (arrival.vehicleArrivalId == onData.vehicleArrivalId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate arrival record. 🥏🥏🥏');
        return;
      }
      arrivals.add(onData);
      pp('$mm arrivals ... ${arrivals.length}');

      _putArrivalMarkerOnMap(onData);
      _animateToVehicle(onData);
      
    });
    telemetrySub = handler.telemetryStream.listen((onData) {
      pp('\n\n$mm telemetryStream received Telemetry ... ${onData.toJson()}');
      var isFound = false;
      for (var vh in telemetry) {
        if (vh.vehicleTelemetryId == onData.vehicleTelemetryId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate telemetry record. 🥏🥏🥏');
        return;
      }
      telemetry.add(onData);
      pp('$mm telemetry ... ${telemetry.length}');
      
    });
    dispatchesSub = handler.dispatchStream.listen((onData) {
      pp('\n\n$mm dispatchStream received Dispatch ... ${onData.toJson()}');
      var isFound = false;
      for (var arrival in dispatches) {
        if (arrival.dispatchRecordId == onData.dispatchRecordId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate dispatch record. 🥏🥏🥏');
        return;
      }
      dispatches.add(onData);
      
    });
    commuterCashSub = handler.commuterCashStream.listen((onData) {
      pp('\n\n$mm commuterCashStream received Commuter Cash ... ${onData.toJson()}');
      var isFound = false;
      for (var arrival in cashPayments) {
        if (arrival.commuterCashPaymentId == onData.commuterCashPaymentId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate commuter cash record. 🥏🥏🥏');
        return;
      }
      cashPayments.add(onData);
      _calculate();
      pp('$mm cashPayments ... ${cashPayments.length}');
      
    });
    passengerCountSub = handler.passengerCountStream.listen((onData) {
      pp('\n\n$mm passengerCountStream received Passenger Count ... ${onData.toJson()}');
      var isFound = false;
      for (var arrival in passengerCounts) {
        if (arrival.passengerCountId == onData.passengerCountId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate passengerCount record. 🥏🥏🥏');
        return;
      }
      passengerCounts.add(onData);
      pp('$mm passengerCounts ... ${passengerCounts.length}');
      
      _calculate();
    });

    tripSub = handler.tripStream.listen((onData) {
      pp('\n\n$mm tripStream received Trip ... ${onData.toJson()}');
      pp('$mm trips ... ${trips.length}');
      var isFound = false;
      for (var arrival in trips) {
        if (arrival.tripId == onData.tripId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate trip record. 🥏🥏🥏');
        return;
      }
      trips.add(onData);
      
    });
  }

  _setCameraPosition() {
    var landmark = widget.routeData.landmarks[0];
    var latLng = LatLng(
        landmark.position!.coordinates[1], landmark.position!.coordinates[0]);
    _myCurrentCameraPosition = CameraPosition(target: latLng, zoom: 15);
    pp('$mm ... _myCurrentCameraPosition: $latLng');
  }

  Future _putArrivalMarkerOnMap(lib.VehicleArrival arrival) async {
    pp('$mm _putMarkerOnMap ...  route: ${widget.routeData.route!.name!}; arrival: ${arrival.landmarkName} ${arrival.position!.coordinates} ');

    //delete existing arrival marker
    _allMarkers.removeWhere(
        (marker) => marker.markerId.value.contains(arrival.vehicleReg!));
    //add arrival marker
    var index = 0;
    for (var mark in widget.routeData.landmarks) {
      final latLng = LatLng(
          mark.position!.coordinates.last, mark.position!.coordinates.first);
      final icon = await getMarkerBitmap(72,
          text: '${index + 1}',
          color: widget.route.color ?? 'black',
          fontSize: 14,
          fontWeight: FontWeight.w900);
      var marker = Marker(
          markerId: MarkerId('${arrival.vehicleArrivalId}'),
          icon: icon,
          onTap: () {
            pp('$mm .............. marker tapped, index: '
                'car: ${arrival.vehicleReg} - ');
          },
          infoWindow: InfoWindow(
              snippet:
                  '\nThis landmark stopped at route:\n ${arrival.landmarkName}\n\n',
              title: '🍎 ${arrival.landmarkName}',
              onTap: () {
                pp('$mm ............. infoWindow tapped, car: ${arrival.vehicleReg}');
                //_deleteLandmark(dr);
              }),
          position: latLng);
      _allMarkers.add(marker);
      index++;
    }
    final latLng0 = LatLng(arrival.position!.coordinates.last,
        arrival.position!.coordinates.first);
    //add Taxi
    final icon0 = await getTaxiMapIcon(
        text: '${arrival.vehicleReg}',
        iconSize: 72,
        style: myTextStyle(
          fontSize: 8,
        ),
        path: 'assets/car1.png');

    var marker0 = Marker(
        markerId: MarkerId('${arrival.vehicleReg}'),
        icon: icon0,
        zIndex: 3,
        anchor: Offset(1.0, 1.0),
        onTap: () {
          pp('$mm .............. marker tapped, index: '
              'car: ${arrival.vehicleReg} - ');
        },
        infoWindow: InfoWindow(
            snippet:
                '\nThis car stopped at route:\n ${arrival.landmarkName}\n\n',
            title: '🍎 ${arrival.landmarkName}',
            onTap: () {
              pp('$mm ............. infoWindow tapped, car: ${arrival.vehicleReg}');
              //_deleteLandmark(dr);
            }),
        position: latLng0);

    _allMarkers.add(marker0);
    _animateToVehicle(arrival);
    setState(() {});
  }

  _addPolyLine() async {
    _polyLines.clear();
    var points = widget.routeData.routePoints;
    points.sort((a, b) => a.index!.compareTo(b.index!));

    List<LatLng> list = [];
    for (var point in points) {
      list.add(LatLng(
          point.position!.coordinates[1], point.position!.coordinates[0]));
    }
    var polyLine = Polyline(
        color: widget.route.color == null
            ? Colors.black
            : getColor(widget.route.color!),
        width: 8,
        points: list,
        polylineId: PolylineId(DateTime.now().toIso8601String()));

    _polyLines.add(polyLine);
    //
    widget.routeData.landmarks.sort((a, b) => a.index!.compareTo(b.index!));
    HashMap<int, lib.RouteLandmark> hashMap = HashMap();
    for (var mark in widget.routeData.landmarks) {
      if (!hashMap.containsKey(mark.index)) {
        hashMap[mark.index!] = mark;
      }
    }
    var myMarks = hashMap.values.toList();
    myMarks.sort((a, b) => a.index!.compareTo(b.index!));

    landmarkIndex = 0;
    for (var mark in myMarks) {
      var latLng =
          LatLng(mark.position!.coordinates[1], mark.position!.coordinates[0]);
      final icon = await getMarkerBitmap(72,
          text: '${landmarkIndex + 1}',
          color: widget.route.color ?? 'black',
          fontSize: 14,
          fontWeight: FontWeight.w900);
      var marker = Marker(
          markerId: MarkerId('${mark.landmarkId}'),
          icon: icon,
          onTap: () {
            pp('$mm .............. marker tapped, index: '
                'landmark: ${mark.landmarkName}  ');
          },
          infoWindow: InfoWindow(
              snippet:
                  '\nThis landmark is part of route:\n ${mark.landmarkName}\n\n',
              title: '🍎 ${mark.landmarkName}',
              onTap: () {
                pp('$mm ............. infoWindow tapped, car: ${mark.landmarkName}');
                //_deleteLandmark(dr);
              }),
          position: latLng);
      _allMarkers.add(marker);
      landmarkIndex++;
    }
    setState(() {});
  }

  bool isHybrid = true;
  final Completer<GoogleMapController> _mapController = Completer();
  late GoogleMapController googleMapController;
  CameraPosition? _myCurrentCameraPosition;

  Future<void> _animateToVehicle(lib.VehicleArrival vehicleArrival) async {
    pp('$mm _animateToVehicle .... ${vehicleArrival.vehicleReg} at ${vehicleArrival.landmarkName}');
    final GoogleMapController controller = await _mapController.future;
    // Create a new CameraPosition
    final CameraPosition newCameraPosition = CameraPosition(
        target: LatLng(vehicleArrival.position!.coordinates[1],
            vehicleArrival.position!.coordinates[0]),
        zoom: 14, // Adjust the zoom level as needed
        bearing: 0, // Optional: Adjust the bearing (rotation) of the camera
        tilt: 0 // Optional: Adjust the tilt of the camera
        );
    // Animate the camera to the new position
    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  int numPassengers = 0;
  double totalCash = 0.00;
  final df = NumberFormat('###,###,##0');
  final nf = NumberFormat('###,###,##0.00');

  _calculate() {
    pp('\n\n$mm _calculate: .... print numbers');
    var pCounts = 0;
    for (var pc in passengerCounts) {
      if (pc.passengersIn == null) {
        continue;
      }
      pCounts += pc.passengersIn!;
      //pp('$mm ... 💦 passengersIn: $pCounts');
    }
    pp('$mm total passengers: $pCounts');
    numPassengers = pCounts;
    var cash = 0.0;
    for (var pc in cashPayments) {
      cash += pc.amount!;
      //pp('$mm ... 🌿 amount: $cash');
    }
    //pp('$mm total cash: $cash\n\n');
    totalCash = cash;
  }

  @override
  Widget build(BuildContext context) {
    pp('\n\n$mm .............................. build ... \n\n');
    _calculate();
    var mark = '';
    if (arrivals.isNotEmpty) {
      if (arrivals.last.landmarkName != null) {
        mark = arrivals.last.landmarkName!;
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Car Activity Demo'),

        ),
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                ActivityHeader(
                    vehicleReg: widget.car.vehicleReg!,
                    totalCash: totalCash,
                    routeName: widget.route.name!,
                    passengers: numPassengers,
                    dispatches: dispatches.length,
                    trips: trips.length,
                    arrivals: arrivals.length,
                    cashPayments: cashPayments.length,
                    telemetry: telemetry.length,
                    landmarkName: mark),
                gapH32,
                _myCurrentCameraPosition == null
                    ? gapW32
                    : Expanded(
                        child: GoogleMap(
                          mapType: isHybrid ? MapType.hybrid : MapType.normal,
                          myLocationEnabled: true,
                          markers: _allMarkers,
                          circles: _circles,
                          polylines: _polyLines,
                          initialCameraPosition: _myCurrentCameraPosition ??
                              CameraPosition(target: LatLng(0, 0)),
                          onTap: (latLng) {
                            pp('$mm .......... on map tapped : $latLng .');
                          },
                          onMapCreated: (GoogleMapController controller) async {
                            pp('$mm ......... GoogleMap: onMapCreated : ${controller.toString()} ....... on to Cleveland!');
                            try {
                              _mapController.complete(controller);
                              googleMapController = controller;
                              _addPolyLine();
                            } catch (e) {
                              pp('$mm .......... error : $e .');
                            }
                          },
                        ),
                      ),
                gapH32,
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
    final nf = NumberFormat('###,###,##0');

    String? num;
    if (number > 1000) {
      num = nf.format((number / 1000).toStringAsFixed(2));
    } else {
      num = nf.format(number);
    }
    return Card(
      elevation: 8,
      child: SizedBox(
          height: 100,
          width: 140,
          child: Center(
            child: Column(
              children: [
                bd.Badge(
                  badgeContent:
                      Text(num, style: myTextStyle(color: Colors.white)),
                  badgeStyle: bd.BadgeStyle(
                      badgeColor: color ?? Colors.black,
                      padding: EdgeInsets.all(16)),
                ),
                gapH16,
                Text(text,
                    style: myTextStyle(fontSize: 12, color: Colors.black))
              ],
            ),
          )),
    );
  }
}

class ActivityHeader extends StatelessWidget {
  const ActivityHeader(
      {super.key,
      required this.vehicleReg,
      required this.totalCash,
      required this.routeName,
      required this.passengers,
      required this.dispatches,
      required this.trips,
      required this.arrivals,
      required this.cashPayments,
      required this.telemetry,
      required this.landmarkName});

  final String vehicleReg, routeName, landmarkName;
  final int passengers, dispatches, trips, arrivals, cashPayments, telemetry;
  final double totalCash;

  @override
  Widget build(BuildContext context) {
    var nf = NumberFormat('###,###,##0.00');
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            gapW32,
            Text(vehicleReg, style: myTextStyleBold(fontSize: 36)),
            gapW32,
            // Text('Route'),
            gapW8,
            Text(routeName, style: myTextStyleBold(fontSize: 24)),
          ],
        ),
        gapH8,
        gapH8,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              DataCard(
                  number: dispatches,
                  text: 'Taxi Dispatches',
                  color: Colors.teal),
              gapW16,
              DataCard(number: trips, text: 'Trips', color: Colors.blue),
              gapW16,
              DataCard(
                  number: arrivals,
                  text: 'Taxi Arrivals',
                  color: Colors.amber.shade700),
              gapW16,
              DataCard(
                number: passengers,
                text: 'Passengers',
                color: Colors.red,
              ),
              gapW16,
              DataCard(
                  number: cashPayments,
                  text: 'Cash Transactions',
                  color: Colors.green.shade700),
              gapW32,
              Row(
                children: [
                  Text('Total Cash', style: myTextStyle(fontSize: 14)),
                  gapW32,
                  Text(nf.format(totalCash ?? '0.00'),
                      style:
                          myTextStyle(fontSize: 56, weight: FontWeight.w900)),
                ],
              ),
              gapW32,
              Text(landmarkName,
                  style: myTextStyleBold(fontSize: 20, color: Colors.blue)),
            ],
          ),
        ),
      ],
    );
  }
}
