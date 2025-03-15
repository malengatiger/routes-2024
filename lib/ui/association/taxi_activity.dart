import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/commuter_cash_payment.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:intl/intl.dart';
import 'package:routes_2024/ui/association/manage_car_demo.dart';
import '../../library/firebase_messaging_handler.dart';
import 'package:badges/badges.dart' as bd;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssociationTaxiActivity extends StatefulWidget {
  const AssociationTaxiActivity({super.key, required this.association});

  final lib.Association association;

  @override
  AssociationTaxiActivityState createState() => AssociationTaxiActivityState();
}

class AssociationTaxiActivityState extends State<AssociationTaxiActivity>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<lib.VehicleTelemetry> telemetry = [];
  List<lib.DispatchRecord> dispatches = [];
  List<lib.AmbassadorPassengerCount> passengerCounts = [];
  List<CommuterCashPayment> cashPayments = [];
  List<lib.Trip> trips = [];
  List<lib.VehicleArrival> arrivals = [];
  List<lib.Vehicle> cars = [];
  List<lib.Vehicle> selectedCars = [];

  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  Prefs prefs = GetIt.instance<Prefs>();
  FirebaseMessagingHandler handler = GetIt.instance<FirebaseMessagingHandler>();

  late StreamSubscription<lib.VehicleTelemetry> telemetrySub;
  late StreamSubscription<lib.DispatchRecord> dispatchesSub;
  late StreamSubscription<lib.AmbassadorPassengerCount> passengerCountSub;
  late StreamSubscription<CommuterCashPayment> commuterCashSub;
  late StreamSubscription<lib.Trip> tripSub;
  late StreamSubscription<lib.VehicleArrival> arrivalsSub;

  static const mm = '😹😹😹 AssociationTaxiActivity 🍎 ';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _getCars();
  }

  _getCars() async {
    cars = await listApiDog.getAssociationCars(
        widget.association.associationId!, false);
    cars.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));
    setState(() {});
    pp('$mm getCars found: ${cars.length}');
    _selectCars();
  }

  _selectCars() async {
    NavigationUtils.navigateNormal(
        context,
        VehicleSelectionWidget(
          vehicles: cars,
          onCarsSelected: (list) {
            setState(() {
              selectedCars = list;
            });
            for (var s in selectedCars) {
              pp('$mm selected car: 🌿${s.vehicleReg} 🌿');
            }
          },
        ));
  }

  bool isOneOfTheCars(String vehicleReg) {
    for (var car in selectedCars) {
      if (car.vehicleReg == vehicleReg) {
        pp('$mm isOneOfTheCars; is recognized: ${car.vehicleReg} ...');
        return true;
      }
    }
    pp('$mm isOneOfTheCars; is NOT being monitored! IGNORED!');
    return false;
  }

  _listen() async {
    handler.initialize();
    arrivalsSub = handler.arrivalStream.listen((onData) {
      if (!isOneOfTheCars(onData.vehicleReg!)) {
        return;
      }
      pp('\n\n$mm arrivalStream received arrival car: ... ${onData.toJson()}');
      var isFound = false;
      for (var arrival in arrivals) {
        if (arrival.vehicleArrivalId == onData.vehicleArrivalId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate record. ');
        return;
      }
      arrivals.add(onData);
      if (mounted) {
        setState(() {
          _getLandmarkName();
        });
      }
    });
    telemetrySub = handler.telemetryStream.listen((onData) {
      if (!isOneOfTheCars(onData.vehicleReg!)) {
        return;
      }
      pp('\n\n$mm telemetryStream received Telemetry ... ${onData.toJson()}');
      var isFound = false;
      for (var vh in telemetry) {
        if (vh.vehicleTelemetryId == onData.vehicleTelemetryId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate record. ');
        return;
      }
      telemetry.add(onData);
      pp('$mm telemetry ... ${telemetry.length}');
    });
    dispatchesSub = handler.dispatchStream.listen((onData) {
      if (!isOneOfTheCars(onData.vehicleReg!)) {
        return;
      }
      pp('\n\n$mm dispatchStream received Dispatch ... ${onData.toJson()}');

      var isFound = false;
      for (var arrival in dispatches) {
        if (arrival.dispatchRecordId == onData.dispatchRecordId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate record. ');
        return;
      }
      dispatches.add(onData);
    });
    commuterCashSub = handler.commuterCashStream.listen((onData) {
      if (!isOneOfTheCars(onData.vehicleReg!)) {
        return;
      }
      pp('\n\n$mm commuterCashStream received Commuter Cash ... ${onData.toJson()}');
      var isFound = false;
      for (var arrival in cashPayments) {
        if (arrival.commuterCashPaymentId == onData.commuterCashPaymentId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate record. ');
        return;
      }
      cashPayments.add(onData);
      _calculate();
      pp('$mm cashPayments ... ${cashPayments.length}');
    });
    passengerCountSub = handler.passengerCountStream.listen((onData) {
      if (!isOneOfTheCars(onData.vehicleReg!)) {
        return;
      }
      pp('\n\n$mm passengerCountStream received Passenger Count ... ${onData.toJson()}');
      var isFound = false;
      for (var arrival in passengerCounts) {
        if (arrival.passengerCountId == onData.passengerCountId) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        pp('$mm 🦐🦐🦐 this is a duplicate record. ');
        return;
      }
      passengerCounts.add(onData);
      pp('$mm passengerCounts ... ${passengerCounts.length}');

      _calculate();
    });

    tripSub = handler.tripStream.listen((onData) {
      if (!isOneOfTheCars(onData.vehicleReg!)) {
        return;
      }
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
        pp('$mm 🦐🦐🦐 this is a duplicate record. ');
        return;
      }
      trips.add(onData);
    });
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
      pp('$mm ... 💦 passengersIn: $pCounts');
    }
    pp('$mm total passengers: $pCounts');
    numPassengers = pCounts;
    var cash = 0.0;
    for (var pc in cashPayments) {
      cash += pc.amount!;
      pp('$mm ... 🌿 amount: $cash');
    }
    pp('$mm total cash: $cash\n\n');
    totalCash = cash;
  }

  String landmarkName = '';

  _getLandmarkName() {
    if (arrivals.isEmpty) {
      return;
    }
    landmarkName = arrivals.last.landmarkName!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Association Taxi Activity'),
        ),
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                ActivityHeader(
                    vehicleReg: '',
                    totalCash: totalCash,
                    routeName: widget.association.associationName!,
                    passengers: numPassengers,
                    dispatches: dispatches.length,
                    trips: trips.length,
                    arrivals: arrivals.length,
                    cashPayments: cashPayments.length,
                    telemetry: telemetry.length,
                    landmarkName: landmarkName),
                gapH8,
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    gapW32, gapW32,
                    Text('${selectedCars.length}', style: myTextStyleBold(fontSize: 24)),
                    gapW8,
                    Text('Cars Monitored')
                  ],
                ),
                gapH32,
                Expanded(
                    child: ListView.builder(
                        itemCount: arrivals.length,
                        itemBuilder: (_, index) {
                          var arrival = arrivals[index];
                          return Card(
                              elevation: 4,
                              child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Text('${arrival.created}'),
                                      gapW32,
                                      Text('${arrival.vehicleReg}',
                                          style: myTextStyleBold(fontSize: 18)),
                                      gapW32,
                                      Text('${arrival.routeName}'),
                                      gapW32,
                                      Text('${arrival.landmarkName}')
                                    ],
                                  )));
                        }))
              ],
            )
          ],
        )));
  }
}

class VehicleSelectionWidget extends StatefulWidget {
  final List<lib.Vehicle> vehicles;
  final Function(List<lib.Vehicle>) onCarsSelected;

  const VehicleSelectionWidget(
      {super.key, required this.vehicles, required this.onCarsSelected});

  @override
  VehicleSelectionWidgetState createState() => VehicleSelectionWidgetState();
}

class VehicleSelectionWidgetState extends State<VehicleSelectionWidget> {
  lib.Vehicle? _selectedVehicle;
  final List<lib.Vehicle> _selectedVehicles = [];
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Multiple Car Selection'),
        ),
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                Text('Select Cars you want to monitor'),
                gapH8,
                Expanded(
                    child: bd.Badge(
                  badgeContent: Text(
                    '${_selectedVehicles.length}',
                    style: myTextStyle(color: Colors.white, fontSize: 16),
                  ),
                  badgeStyle: bd.BadgeStyle(
                    padding: EdgeInsets.all(16),
                    badgeColor: Colors.indigo,
                    elevation: 8,
                  ),
                  position: bd.BadgePosition.topEnd(
                    top: -16,
                    end: 16,
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(
                        32,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 10,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        itemCount: widget.vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = widget.vehicles[index];
                          final isSelected =
                              _selectedVehicles.contains(vehicle);
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedVehicles.remove(vehicle);
                                  } else {
                                    _selectedVehicles.add(vehicle);
                                    pp(' _selectedVehicles: ${_selectedVehicles.length}');
                                  }
                                });
                              },
                              child: Card(
                                elevation: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // FaIcon(FontAwesomeIcons.car),
                                      // gapW8,
                                      Text(
                                        vehicle.vehicleReg == null
                                            ? ''
                                            : vehicle.vehicleReg!,
                                        style: myTextStyle(
                                          fontSize: 14,
                                          weight: FontWeight.w900,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  )),
                                ),
                              ));
                        },
                      )),
                )),
                gapH32,
                gapH32,

              ],
            ),
            _selectedVehicles.isEmpty
                ? gapW32
                : Positioned(
              right: 16,
              bottom: 24,
              child: SizedBox(
                width: 400,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStatePropertyAll(Colors.red),
                    padding:
                    WidgetStatePropertyAll(EdgeInsets.all(16)),
                    elevation: WidgetStatePropertyAll(16),
                  ),
                  onPressed: () {
                    widget.onCarsSelected(_selectedVehicles);
                    Navigator.pop(context);
                  },
                  child: Text(
                      'Start Taxi Activity for ${_selectedVehicles.length} cars',
                      style: myTextStyleBold(color: Colors.white)),
                ),
              ),
            )
          ],
        )));
  }
}
