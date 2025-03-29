import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/constants.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/route_data.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';

import 'manage_car_demo.dart';

class TheDemo extends StatefulWidget {
  const TheDemo({super.key, required this.association, required this.isDemo});

  final lib.Association association;
  final bool isDemo;

  @override
  TheDemoState createState() => TheDemoState();
}

class TheDemoState extends State<TheDemo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const mm = '😹😹😹 TheDemo 😹 ';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  List<lib.Route> routes = [];
  List<lib.Vehicle> cars = [];
  List<lib.User> users = [];
  List<lib.User> ambassadors = [];
  List<lib.User> marshals = [];

  AssociationRouteData? associationRouteData;
  RouteData? routeData;
  lib.Route? route;
  lib.Vehicle? car;
  bool busy = false;

  _getData() async {
    setState(() {
      busy = true;
    });

    associationRouteData = await listApiDog.getAssociationRouteData(
        widget.association.associationId!, false);
    for (var rd in associationRouteData!.routeDataList) {
      if (rd.landmarks.isEmpty) {
        pp('$mm Route has no landmarks: ${rd.route!.name}');
        continue;
      }
      ;
      routes.add(rd.route!);
    }
    routes.sort((a, b) => a.name!.compareTo(b.name!));
    cars = await listApiDog.getAssociationCars(
        widget.association.associationId!, false);
    cars.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));

    users = await listApiDog.getAssociationUsers(
        widget.association.associationId!, false);
    for (var u in users) {
      if (u.userType == Constants.AMBASSADOR) {
        ambassadors.add(u);
      }
      if (u.userType == Constants.MARSHAL) {
        marshals.add(u);
      }
    }
    setState(() {
      busy = false;
    });
  }

  RouteData? getRouteData(String routeId) {
    RouteData? xd;
    for (var rd in associationRouteData!.routeDataList) {
      if (rd.route!.routeId == routeId) {
        xd = rd;
        break;
      }
    }
    routeData = xd;
    return xd;
  }

  int? currentAmbassadorIndex;
  int? currentMarshalIndex;
  lib.User? ambassador;
  lib.User? marshal;

  _startCarDemo() async {
    setState(() {
      busy = true;
    });
    currentMarshalIndex ??= 0;
    currentAmbassadorIndex ??= 0;
    if (currentMarshalIndex! >= marshals.length) {
      currentMarshalIndex = 0;
    }
    if (currentAmbassadorIndex! >= ambassadors.length) {
      currentAmbassadorIndex = 0;
    }
    marshal = marshals[currentMarshalIndex!];
    ambassador = ambassadors[currentAmbassadorIndex!];

    currentMarshalIndex = currentMarshalIndex! + 1;
    currentAmbassadorIndex = currentAmbassadorIndex! + 1;

    getRouteData(route!.routeId!);

    if (widget.isDemo) {
       listApiDog.startCarDemo(route: route!,
          car: car!,
          ambassador: ambassador!,
          marshal: marshal!,
          associationId: marshal!.associationId!);

    if (mounted) {
      showOKToast(
          duration: Duration(seconds: 3),
          padding: 24,
          message: 'Car demo has started', context: context);

      pp('$mm ... navigating to ManageCarDemo');
      NavigationUtils.navigateTo(
          context: context,
          widget: ManageCarDemo(
            routeData: routeData!,
            route: route!,
            car: car!,
            ambassador: ambassador!,
            marshal: marshal!,
          ));
    }
    setState(() {
      busy = false;
      car = null;
    });
  }
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
        title: Text('Taxi Activity Demo', style: myTextStyleBold()),
      ),
      body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  route == null
                      ? gapW32
                      : Text(
                      '${route!.name}', style: myTextStyleBold(fontSize: 36)),
                  gapH32,
                  car == null
                      ? gapW32
                      : Text('${car!.vehicleReg}',
                      style:
                      myTextStyle(fontSize: 48, weight: FontWeight.w900)),
                  gapH32,
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Card(
                            elevation: 4,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 560,
                                  child: ListView.builder(
                                      itemCount: routes.length,
                                      itemBuilder: (_, index) {
                                        return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                route = routes[index];
                                              });
                                            },
                                            child: Card(
                                              elevation: 4,
                                              color: Colors.amber.shade100,
                                              child: ListTile(
                                                leading: FaIcon(
                                                    FontAwesomeIcons.route),
                                                title:
                                                Text('${routes[index].name}'),
                                              ),
                                            ));
                                      }),
                                ),
                                gapW32,
                                SizedBox(
                                  width: 300,
                                  child: ListView.builder(
                                      itemCount: cars.length,
                                      itemBuilder: (_, index) {
                                        return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                car = cars[index];
                                              });
                                            },
                                            child: Card(
                                              elevation: 8,
                                              color: Colors.teal.shade100,
                                              child: ListTile(
                                                leading:
                                                FaIcon(FontAwesomeIcons.car),
                                                title: Text(
                                                    '${cars[index]
                                                        .vehicleReg}'),
                                              ),
                                            ));
                                      }),
                                ),
                                gapW32,
                                car == null
                                    ? gapW32
                                    : Center(
                                    child: SizedBox(
                                      width: 400,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          elevation:
                                          WidgetStatePropertyAll(8.0),
                                          backgroundColor:
                                          WidgetStatePropertyAll(
                                              Colors.red),
                                        ),
                                        onPressed: () {
                                          _startCarDemo();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text(
                                            'Start ${car!.vehicleReg!} Demo',
                                            style: myTextStyleBold(
                                                color: Colors.white,
                                                fontSize: 24),
                                          ),
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                          )))
                ],
              ),
              busy
                  ? Center(
                  child: TimerWidget(
                    title: 'Loading data ...',
                    isSmallSize: true,
                  ))
                  : gapH32,
            ],
          )));
}}
//dpouble fashion sandwich
//salmon sushi roll
