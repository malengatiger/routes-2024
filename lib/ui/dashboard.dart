import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/isolates/routes_isolate.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/maps/city_creator_map.dart';
import 'package:kasie_transie_library/maps/landmark_creator_map.dart';
import 'package:kasie_transie_library/maps/route_creator_map2.dart';
import 'package:kasie_transie_library/maps/route_map_viewer.dart';
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/utils/route_distance_calculator.dart';
import 'package:kasie_transie_library/utils/zip_handler.dart';
import 'package:kasie_transie_library/widgets/dash_widgets/generic.dart';
import 'package:kasie_transie_library/widgets/language_and_color_chooser.dart';
import 'package:kasie_transie_library/widgets/route_info_widget.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:kasie_transie_library/widgets/tiny_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/ui/route_editor.dart';
import 'package:get_it/get_it.dart';
import 'assoc_routes.dart';
import 'route_list.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard(this.association, {super.key});

  final Association association;

  @override
  ConsumerState createState() => DashboardState();
}

class DashboardState extends ConsumerState<Dashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '😡😡😡😡 RouteBuilder Dashboard: 💪 ';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  ZipHandler zipHandler = GetIt.instance<ZipHandler>();

  RouteDistanceCalculator routeDistanceCalculator =
      GetIt.instance<RouteDistanceCalculator>();
  lib.User? user;
  var cars = <lib.Vehicle>[];
  var routes = <lib.Route>[];
  var routeLandmarks = <lib.RouteLandmark>[];
  var dispatchRecords = <lib.DispatchRecord>[];
  bool busy = false;
  late ColorAndLocale colorAndLocale;
  bool authed = false;
  var totalPassengers = 0;
  late StreamSubscription<lib.RouteUpdateRequest> _routeUpdateSubscription;

  int routePointsTotal = 0;
  String dispatchWithScan = '',
      manualDispatch = '',
      routePointsText = '',
      routesText = 'Routes',
      landmarksText = '',
      days = '',
      citiesText = 'Cities',
      passengerCount = '',
      dispatchesText = '',
      passengers = '',
      workWithRoutes = '',
      ambassadorText = '';
  String notRegistered =
      'You are not registered yet. Please call your administrator';
  String emailNotFound = 'emailNotFound';
  String welcome = 'Welcome';
  String firstTime =
      'This is the first time that you have opened the app and you '
      'need to sign in to your Taxi Association. Thank you!';

  String changeLanguage = 'Change Language or Color';
  String startEmailLinkSignin = 'Start Email Link Sign In';
  String signInWithPhone = 'Start Phone Sign In';

  Future _setTexts() async {
    colorAndLocale = prefs.getColorAndLocale();
    pp('$mm setTexts: color and locale : $colorAndLocale');
    final loc = colorAndLocale.locale;
    routePointsText = await translator.translate('routePoints', loc);
    routesText = await translator.translate('taxiRoutes', loc);
    landmarksText = await translator.translate('landmarks', loc);
    workWithRoutes = await translator.translate('workWithRoutes', loc);
    notRegistered = await translator.translate('notRegistered', loc);
    firstTime = await translator.translate('firstTime', loc);
    changeLanguage = await translator.translate('changeLanguage', loc);
    welcome = await translator.translate('welcome', loc);
    signInWithPhone = await translator.translate('signInWithPhone', loc);
    citiesText = await translator.translate('cities', loc);

    setState(() {});
  }

  int daysForData = 1;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setTexts();
    _control();
  }

  void _control() async {
    user = prefs.getUser();
    //
    // try {
    //   fcmBloc.subscribeToTopics('RouteBuilder');
    // } catch (e) {
    //   pp(e);
    // }
    _getData(false);
  }

  void _listen() async {
    _routeUpdateSubscription = fcmBloc.routeUpdateRequestStream.listen((event) {
      pp('$mm fcmBloc.routeUpdateRequestStream delivered: ${event.routeName}');
      _noteRouteUpdate(event);
    });
  }

  void _noteRouteUpdate(lib.RouteUpdateRequest request) async {
    pp('$mm route update started in isolate for ${request.routeName} ...  ');
    if (mounted) {
      showSnackBar(
          duration: const Duration(seconds: 10),
          message: 'Route ${request.routeName} has been refreshed! Thanks',
          context: context);
    }
  }

  int citiesTotal = 0;

  Future _getData(bool refresh) async {
    pp('$mm ................... get data for routeBuilder dashboard ... refresh: $refresh');
    user = prefs.getUser();
    if (user == null) {
      throw Exception('Blown up! No User');
    }
    pp('\n\n ...cached user found: ${user!.toJson()}\n');
    setState(() {
      busy = true;
    });
    try {
      if (user != null) {
        await _getRoutes(refresh);
        var cities = await zipHandler.getCities(user!.countryId!, false);
        citiesTotal = cities.length;
      }
    } catch (e, stack) {
      pp('$mm ERROR $e : $stack');
      if (mounted) {
        showSnackBar(
            padding: 16, message: 'Error getting data', context: context);
      }
    }
    //
    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  SemCache semCache = GetIt.instance<SemCache>();
  Future _getRoutes(bool refresh) async {
    pp('$mm ... routeBuilder dashboard; getting routes ... refresh: $refresh');
    try {
      setState(() {
        busy = true;
      });
      var routesIsolate = GetIt.instance<RoutesIsolate>();
      if (kIsWeb) {
        routes = await zipHandler.getRoutes(
            associationId: widget.association.associationId!, refresh: false);
        pp('$mm ... routeBuilder dashboard; routes found by zipHandler: ${routes.length} ...');
      } else {
        routes = await routesIsolate.getRoutes(
            widget.association.associationId!, refresh);
      }
      routes.sort((a,b) => a.name!.compareTo(b.name!));
      await _countPoints();
      await _countLandmarks();
    } catch (e, stack) {
      pp('$e, $stack');
      if (mounted) {
        showErrorSnackBar(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
    pp('$mm ... routeBuilder dashboard; routes: ${routes.length} ...');
  }

  bool popDetails = false;
  lib.Route? route;

  void popupDetails(lib.Route route) {
    this.route = route;
    setState(() {
      popDetails = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _routeUpdateSubscription.cancel();
    super.dispose();
  }

  Future _navigateToColor() async {
    pp('$mm _navigateToColor ......');
    NavigationUtils.navigateTo(
        context: context,
        widget: LanguageAndColorChooser(
          onLanguageChosen: () {
            _setTexts();
          },
        ),
        transitionType: PageTransitionType.leftToRight);

    colorAndLocale = prefs.getColorAndLocale();
    await _setTexts();
  }

  int routeLandmarksTotal = 0;
  int routesTotal = 0;
  bool sendingRouteUpdateMessage = false;

  void onSendRouteUpdateMessage(lib.Route route) async {
    pp("$mm onSendRouteUpdateMessage .........");
    tinyBloc.setRouteId(route.routeId!);
    prefs.saveRoute(route);

    setState(() {
      sendingRouteUpdateMessage = true;
    });
    try {
      final req = lib.RouteUpdateRequest(
        associationId: route.associationId,
        created: DateTime.now().toUtc().toIso8601String(),
        routeId: route.routeId,
        routeName: route.name,
        userId: user!.userId,
        userName: user!.name,
      );
      await dataApiDog.sendRouteUpdateMessage(req);
      pp('$mm onSendRouteUpdateMessage happened OK! ${E.nice}');
    } catch (e) {
      pp(e);
      if (mounted) {
        showToast(
            duration: const Duration(seconds: 5),
            padding: 20,
            textStyle: myTextStyleMedium(context),
            backgroundColor: Colors.amber,
            message: 'Route Update message sent OK',
            context: context);
      }
    }
    setState(() {
      sendingRouteUpdateMessage = false;
    });
  }

  void _calculateDistances(lib.Route route) async {
    tinyBloc.setRouteId(route.routeId!);
    prefs.saveRoute(route);

    routeDistanceCalculator.calculateRouteDistances(
        route.routeId!, route.associationId!);
  }

  lib.Route? selectedRoute;
  String? selectedRouteId;

  void navigateToLandmarks(lib.Route route) async {
    pp('$mm navigateToLandmarksEditor .....  route: ${route.name}');
    tinyBloc.setRouteId(route.routeId!);
    prefs.saveRoute(route);
    setState(() {
      selectedRoute = route;
      selectedRouteId = route.routeId;
    });
    pp('$mm Future.delayed(const Duration(seconds: 2) .....  ');

    await Future.delayed(const Duration(milliseconds: 2));
    if (mounted) {
      NavigationUtils.navigateTo(
          context: context,
          widget: LandmarkCreatorMap(
            route: route,
          ),
          transitionType: PageTransitionType.leftToRight);
    }
  }

  void navigateToMapViewer(lib.Route route) async {
    pp('$mm navigateToMapViewer .....  route: ${route.name}');
    tinyBloc.setRouteId(route.routeId!);
    prefs.saveRoute(route);

    setState(() {
      selectedRoute = route;
      selectedRouteId = route.routeId;
    });
    pp('$mm Future.delayed(const Duration(seconds: 2) .....  ');

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      NavigationUtils.navigateTo(
          context: context,
          widget: RouteMapViewer(
            routeId: route.routeId!,
            onRouteUpdated: () {
              pp('\n\n$mm onRouteUpdated ... do something Boss!');
              // _refresh(true);
            },
          ),
          transitionType: PageTransitionType.leftToRight);
    }
  }

  void navigateToCreatorMap(lib.Route route) async {
    pp('$mm navigateToCreatorMap .....  route: ${route.name}');
    tinyBloc.setRouteId(route.routeId!);
    prefs.saveRoute(route);
    setState(() {
      selectedRoute = route;
      selectedRouteId = route.routeId;
    });
    pp('$mm Future.delayed(const Duration(seconds: 2) .....  ');

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      NavigationUtils.navigateTo(
          context: context,
          widget: RouteCreatorMap2(
            route: route,
          ),
          transitionType: PageTransitionType.leftToRight);
    }
  }

  void navigateToAssocMaps() {
    NavigationUtils.navigateTo(
        context: context,
        widget: AssociationRoutes(user!.associationId!, user!.associationName!),
        transitionType: PageTransitionType.leftToRight);
  }

  void navigateToRoutes() {
    pp('$mm ............... navigateToRoutes');
    if (user != null) {
      final w = AssociationRoutes(user!.associationId!, user!.associationName!);
      NavigationUtils.navigateTo(
          context: context,
          widget: w,
          transitionType: PageTransitionType.leftToRight);
    }
  }

  void _navigateToCityCreator() {
    NavigationUtils.navigateTo(
        context: context,
        widget: const CityCreatorMap(),
        transitionType: PageTransitionType.leftToRight);
  }

  _countPoints() async {
    routePointsTotal = await semCache.countRoutePoints(widget.association.associationId!);
  }
  _countLandmarks() async {
    routeLandmarksTotal = await semCache.countRouteLandmarks(widget.association.associationId!);
  }
  Widget _getDashContent() {
    if (widget.association.associationName == null) {
      return Container(color: Colors.teal,);
    }
    return DashContent(
      user: user!,
      routesText: routesText,
      workWithRoutes: workWithRoutes,
      landmarksText: landmarksText,
      routePointsText: routePointsText,
      routePointsTotal: routePointsTotal,
      routeLandmarksTotal: routeLandmarksTotal,
      routesTotal: routes.length,
      heightPadding: 52,
      crossAxisCount: 2,
      onNavigateToRoutes: () {
        navigateToRoutes();
      },
      citiesText: citiesText,
      citiesTotal: citiesTotal,
      height: 1200, association: widget.association,
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    var padding = 16.0;
    var fontSize = 16.0;
    var centerTitle = true;
    if (type == 'phone') {
      padding = 12.0;
      fontSize = 24;
      centerTitle = false;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          centerTitle: centerTitle,
          title: Text(
            'Taxi Route Builder',
            style: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, fontSize),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _navigateToCityCreator();
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  _navigateToColor();
                },
                icon: Icon(
                  Icons.color_lens,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  _getData(true);
                },
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  navigateToRoutes();
                },
                icon: Icon(
                  Icons.route,
                  color: Theme.of(context).primaryColor,
                )),
          ],
          bottom: PreferredSize(preferredSize: Size.fromHeight(64), child: SizedBox()),
        ),
        body: Stack(
          children: [
            ScreenTypeLayout.builder(
              mobile: (ctx) {
                return Stack(
                  children: [
                    user == null ? gapW16 : _getDashContent(),
                  ],
                );
              },
              tablet: (ctx) {
                return OrientationLayoutBuilder(landscape: (ctx) {
                  final width = MediaQuery.of(context).size.width;
                  return user == null
                      ? gapW16
                      : Row(
                          children: [
                            SizedBox(
                              width: (width / 2) + 60,
                              child: _getDashContent(),
                            ),
                            SizedBox(
                              width: (width / 2) - 60,
                              child: RouteList(
                                navigateToMapViewer: (r) {
                                  navigateToMapViewer(r);
                                },
                                navigateToLandmarks: (r) {
                                  navigateToLandmarks(r);
                                },
                                navigateToCreatorMap: (r) {
                                  navigateToCreatorMap(r);
                                },
                                routes: routes,
                                onSendRouteUpdateMessage: (r) {
                                  onSendRouteUpdateMessage(r);
                                },
                                onCalculateDistances: (r) {
                                  _calculateDistances(r);
                                },
                                showRouteDetails: (r) {
                                  popupDetails(r);
                                },
                              ),
                            ),
                          ],
                        );
                }, portrait: (ctx) {
                  final width = MediaQuery.of(context).size.width;
                  return user == null
                      ? gapW16
                      : Row(
                          children: [
                            SizedBox(
                              width: (width / 2) + 40,
                              child: _getDashContent(),
                            ),
                            SizedBox(
                              width: (width / 2) - 40,
                              child: RouteList(
                                navigateToMapViewer: (r) {
                                  navigateToMapViewer(r);
                                },
                                navigateToLandmarks: (r) {
                                  navigateToLandmarks(r);
                                },
                                navigateToCreatorMap: (r) {
                                  navigateToCreatorMap(r);
                                },
                                routes: routes,
                                onSendRouteUpdateMessage: (r) {
                                  onSendRouteUpdateMessage(r);
                                },
                                onCalculateDistances: (r) {
                                  _calculateDistances(r);
                                },
                                showRouteDetails: (r) {
                                  popupDetails(r);
                                },
                              ),
                            ),
                          ],
                        );
                });
              },
            ),
            popDetails
                ? Positioned(
                    top: 0,
                    bottom: 0,
                    left: padding,
                    right: padding,
                    child: RouteInfoWidget(
                      routeId: route!.routeId,
                      onClose: () {
                        setState(() {
                          popDetails = false;
                        });
                      },
                      onNavigateToMapViewer: () {
                        navigateToMapViewer(route!);
                      },
                      onColorChanged: (color, stringColor) {
                        _sendColorChange(color, stringColor);
                      },
                    ))
                : const SizedBox(),
            busy
                ? const Positioned(
                    child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: TimerWidget(
                          title: 'Data refreshing ...', isSmallSize: true),
                    ),
                  ))
                : gapH16,
          ],
        ),
        drawer: SizedBox(
          width: 400,
          child: Drawer(
            child: Card(
              elevation: 8,
              child: ListView(
                children: [
                  DrawerHeader(
                      decoration: const BoxDecoration(
                          color: Colors.black12,
                          image: DecorationImage(
                              image: AssetImage('assets/gio.png'),
                              scale: 0.1,
                              opacity: 0.1)),
                      child: SizedBox(
                          height: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(routesText,
                                  style: myTextStyleMediumLargeWithColor(
                                      context, Colors.grey, 32)),
                              const SizedBox(
                                height: 48,
                              )
                            ],
                          ))),
                  const SizedBox(
                    height: 64,
                  ),
                  ListTile(
                    title: const Text('Add Place/Town/City'),
                    leading: Icon(
                      Icons.account_balance,
                      color: Theme.of(context).primaryColor,
                    ),
                    subtitle: Text(
                        'Create a new place that wil be used in your routes',
                        style: myTextStyleSmall(context)),
                    onTap: () {
                      pp('$mm navigate to city creator map .......');
                      NavigationUtils.navigateTo(
                          context: context,
                          widget: const CityCreatorMap(),
                          transitionType: PageTransitionType.leftToRight);
                    },
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ListTile(
                    title: const Text('Add New Route'),
                    leading: Icon(Icons.directions_bus,
                        color: Theme.of(context).primaryColor),
                    subtitle: Text('Create a new route',
                        style: myTextStyleSmall(context)),
                    onTap: () {
                      NavigationUtils.navigateTo(
                          context: context,
                          widget: RouteEditor(
                            dataApiDog: dataApiDog,
                            prefs: prefs,
                            association: widget.association,
                          ),
                          transitionType: PageTransitionType.leftToRight);
                    },
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ListTile(
                    title: const Text('Calculate Route Distances'),
                    leading: Icon(Icons.calculate,
                        color: Theme.of(context).primaryColor),
                    subtitle: Text(
                      'Calculate distances between landmarks in the route',
                      style: myTextStyleSmall(context),
                    ),
                    onTap: () {
                      pp('$mm starting distance calculation ...');
                      routeDistanceCalculator
                          .calculateAssociationRouteDistances();
                    },
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ListTile(
                    title: const Text('Refresh Route Data'),
                    leading: Icon(Icons.refresh,
                        color: Theme.of(context).primaryColor),
                    subtitle: Text(
                      'Fetch refreshed route data from the Mother Ship',
                      style: myTextStyleSmall(context),
                    ),
                    onTap: () {
                      _getData(true);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendColorChange(Color color, stringColor) async {
    pp('$mm send color change to : $color');
    setState(() {
      busy = true;
    });
    try {
      selectedRoute = await dataApiDog.updateRouteColor(
          routeId: selectedRoute!.routeId!, color: stringColor);
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(message: 'Colour update failed\n$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }
}

class DashContent extends StatelessWidget {
  const DashContent(
      {super.key,
      required this.user,
      required this.routesText,
      required this.workWithRoutes,
      required this.landmarksText,
      required this.routePointsText,
      required this.routePointsTotal,
      required this.routeLandmarksTotal,
      required this.routesTotal,
      required this.onNavigateToRoutes,
      required this.height,
      required this.crossAxisCount,
      required this.heightPadding,
      required this.citiesText,
      required this.citiesTotal, required this.association});

  final lib.User user;
  final lib.Association association;
  final String routesText,
      workWithRoutes,
      landmarksText,
      routePointsText,
      citiesText;
  final int routePointsTotal, routeLandmarksTotal, routesTotal, citiesTotal;
  final Function onNavigateToRoutes;
  final double height;
  final int crossAxisCount;
  final double heightPadding;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              SizedBox(
                height: heightPadding,
              ),
              Text(
                association.associationName!,
                style: myTextStyleMediumLargeWithColor(
                    context, Theme.of(context).primaryColor, 18),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                user.name,
                style: myTextStyleSmall(context),
              ),
              SizedBox(
                height: heightPadding,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                    width: 400,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.roundabout_left),
                      style: const ButtonStyle(
                        elevation: WidgetStatePropertyAll(8.0),
                      ),
                      onPressed: () {
                        onNavigateToRoutes();
                      },
                      label: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(workWithRoutes),
                      ),
                    )),
              ),
              SizedBox(
                height: heightPadding,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 600,
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        crossAxisCount: crossAxisCount,
                      ),
                      children: [
                        TotalWidget(
                            caption: routesText,
                            number: routesTotal,
                            color: Theme.of(context).primaryColor,
                            fontSize: 28,
                            onTapped: () {}),
                        TotalWidget(
                            caption: landmarksText,
                            number: routeLandmarksTotal,
                            color: Theme.of(context).primaryColor,
                            fontSize: 28,
                            onTapped: () {}),
                        TotalWidget(
                            caption: routePointsText,
                            number: routePointsTotal,
                            color: Colors.grey.shade600,
                            fontSize: 28,
                            onTapped: () {}),
                        TotalWidget(
                            caption: citiesText,
                            number: citiesTotal,
                            color: Colors.grey.shade600,
                            fontSize: 28,
                            onTapped: () {}),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
