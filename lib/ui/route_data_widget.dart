import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/data/route_data.dart';
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
import 'package:kasie_transie_library/utils/route_update_listener.dart';
import 'package:kasie_transie_library/utils/zip_handler.dart';
import 'package:kasie_transie_library/widgets/dash_widgets/generic.dart';
import 'package:kasie_transie_library/widgets/language_and_color_chooser.dart';
import 'package:kasie_transie_library/widgets/route_info_widget.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:kasie_transie_library/widgets/tiny_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/ui/route_editor.dart';

import 'assoc_routes.dart';
import 'route_list.dart';

class RouteDataWidget extends StatefulWidget {
  const RouteDataWidget({super.key, required this.association});

  final Association association;

  @override
  State createState() => RouteDataState();
}

class RouteDataState extends State<RouteDataWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '😡😡😡😡 RouteDataWidget: 💪 ';
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  Prefs prefs = GetIt.instance<Prefs>();
  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  ZipHandler zipHandler = GetIt.instance<ZipHandler>();
  SemCache semCache = GetIt.instance<SemCache>();
  FCMService fcmService = GetIt.instance<FCMService>();

  RouteUpdateListener routeUpdateListener =
      GetIt.instance<RouteUpdateListener>();
  late StreamSubscription<lib.Route> _routeUpdateListenerSubscription;
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
    _getData(false);
  }

  void _listen() async {
    _routeUpdateSubscription = fcmService.routeUpdateRequestStream.listen((event) {
      pp('$mm fcmService.routeUpdateRequestStream delivered: ${event.routeName}');
      _noteRouteUpdate(event);
    });

    _routeUpdateListenerSubscription =
        routeUpdateListener.routeUpdateStream.listen((route) {
      pp('$mm routeUpdateListener.routeUpdateStream delivered: ${route.toJson()}');
      _handleRouteRefresh(route);
    });
  }

  void _handleRouteRefresh(lib.Route route) async {
    pp('$mm This route was updated somewhere: ${route.name}');
    _getData(true);
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

  int routeCitiesTotal = 0;

  Future _getData(bool refresh) async {
    pp('\n\n$mm ................... get data for routeBuilder dashboard ...');
    user = prefs.getUser();
    if (user == null) {
      throw Exception('Blown up! No User');
    }
    setState(() {
      busy = true;
    });
    try {
      AssociationRouteData? routeData = await listApiDog
            .getAssociationRouteData(widget.association.associationId!, refresh);
      _populate(routeData!);
    } catch (e, stack) {
      pp('$mm ERROR getting route data $e : $stack');
      if (mounted) {
        showErrorToast(
            duration: Duration(seconds: 10),
            padding: 16,
            message: '$e',
            context: context);
      }
    }
    //
    setState(() {
      busy = false;
    });
  }

  _populate(AssociationRouteData routeData) {
    routes.clear();
    routeLandmarks.clear();
    routeCitiesTotal = 0;
    routePointsTotal = 0;

    for (var t in routeData.routeDataList) {
      routes.add(t.route!);
    }

    for (var t in routeData.routeDataList) {
      routeLandmarks.addAll(t.landmarks);
    }
    for (var t in routeData.routeDataList) {
      routeCitiesTotal += t.cities.length;
    }
    for (var t in routeData.routeDataList) {
      routePointsTotal += t.routePoints.length;
    }
    routeLandmarksTotal = routeLandmarks.length;
    routesTotal = routes.length;
    routes.sort((a, b) => a.name!.compareTo(b.name!));

    pp('\n\n$mm Association Route Data');
    pp('$mm ...  dashboard; routes found : 🥬$routesTotal ...');
    pp('$mm ...  dashboard; routeLandmarks found : 🥬 $routeLandmarksTotal ...');
    pp('$mm ...  dashboard; routePoints found : 🥬 $routePointsTotal ...');
    pp('$mm ...  dashboard; routeCities found : 🥬 $routeCitiesTotal ...');
  }

  bool popDetails = false;
  lib.Route? route;

  void popupDetails(lib.Route route) {
    this.route = route;

    NavigationUtils.navigateTo(
        context: context,
        widget: RouteInfoWidget(
          route: route,
          onClose: () {
            Navigator.of(context).pop();
          },
          onNavigateToMapViewer: () {},
          onColorChanged: (color, str) {
            pp('$mm onColorChanged ... $str');
            _updateRouteColor(str);
          },
        ),
        transitionType: PageTransitionType.leftToRight);
  }

  void _updateRouteColor(String color) async {
    setState(() {
      busy = true;
    });
    try {
      route!.color = color;
      var result = await dataApiDog.updateRouteColor(routeId: route!.routeId!, color: color);
    } catch (e,s) {
      pp('$mm $e $s');
      if (mounted) {
        showErrorToast(message: 'Route colour update failed: $e', context: context);
      }
    }
    setState(() {
      busy = false;
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
      if (mounted) {
        showToast(
            duration: const Duration(seconds: 5),
            padding: 20,
            textStyle: myTextStyleMedium(context),
            backgroundColor: Colors.green,
            message: 'Route Update message sent OK',
            context: context);
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorSnackBar(message: '$e', context: context);
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
            route: route,
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
    NavigationUtils.navigateTo(context: context, widget: CityCreatorMap(onCityAdded: (c){
      pp('$mm ... city added: ${c.name}');

    }), transitionType: PageTransitionType.leftToRight);
  }

  _onCreateNewRoute() async {
    NavigationUtils.navigateTo(
        context: context,
        widget: RouteEditor(
          association: widget.association,
          onRouteAdded: (r) {
            _getData(true);
          },
        ),
        transitionType: PageTransitionType.leftToRight);
  }

  @override
  Widget build(BuildContext context) {
    final type = getThisDeviceType();
    var fontSize = 20.0;
    var centerTitle = true;
    if (type == 'phone') {
      fontSize = 24;
      centerTitle = false;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
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
                tooltip: 'Create new Place (city, town, kasie) etc.',
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  _navigateToColor();
                },
                tooltip: 'Change your colours',
                icon: Icon(
                  Icons.color_lens,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  _getData(true);
                },
                tooltip: 'Refresh the association route data',
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                )),
            gapW32,
            // IconButton(
            //     onPressed: () {
            //       navigateToRoutes();
            //     },
            //     icon: Icon(
            //       Icons.route,
            //       color: Theme.of(context).primaryColor,
            //     )),
          ],
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(36), child: SizedBox()),
        ),
        body: Stack(
          children: [
            ScreenTypeLayout.builder(
              mobile: (ctx) {
                return Stack(
                  children: [
                    user == null
                        ? gapW16
                        : DashContent(
                            user: user!,
                            routesText: routesText,
                            workWithRoutes: workWithRoutes,
                            landmarksText: landmarksText,
                            routePointsText: routePointsText,
                            routePointsTotal: routePointsTotal,
                            routeLandmarksTotal: routeLandmarksTotal,
                            routesTotal: routes.length,
                            heightPadding: 48,
                            crossAxisCount: 2,
                            onNavigateToRoutes: () {
                              navigateToRoutes();
                            },
                            citiesText: citiesText,
                            citiesTotal: routeCitiesTotal,
                            height: 1200,
                            association: widget.association,
                          ),
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
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: DashContent(
                                  user: user!,
                                  routesText: routesText,
                                  workWithRoutes: workWithRoutes,
                                  landmarksText: landmarksText,
                                  routePointsText: routePointsText,
                                  routePointsTotal: routePointsTotal,
                                  routeLandmarksTotal: routeLandmarksTotal,
                                  routesTotal: routes.length,
                                  heightPadding: 48,
                                  crossAxisCount: 2,
                                  onNavigateToRoutes: () {
                                    navigateToRoutes();
                                  },
                                  citiesText: citiesText,
                                  citiesTotal: routeCitiesTotal,
                                  height: 1200,
                                  association: widget.association,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: (width / 2) - 60,
                              child: Padding(
                                  padding: EdgeInsets.only(right: 24),
                                  child: RouteListWidget(
                                    navigateToMapViewer: (r) {
                                      navigateToMapViewer(r);
                                    },
                                    navigateToLandmarks: (r) {
                                      navigateToLandmarks(r);
                                    },
                                    navigateToCreatorMap: (r) {
                                      navigateToCreatorMap(r);
                                    },
                                    onSendRouteUpdateMessage: (r) {
                                      onSendRouteUpdateMessage(r);
                                    },
                                    onCalculateDistances: (r) {
                                      _calculateDistances(r);
                                    },
                                    showRouteDetails: (r) {
                                      popupDetails(r);
                                    },
                                    association: widget.association,
                                    onCreateNewRoute: () {
                                      _onCreateNewRoute();
                                    },
                                  )),
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
                              child: DashContent(
                                user: user!,
                                routesText: routesText,
                                workWithRoutes: workWithRoutes,
                                landmarksText: landmarksText,
                                routePointsText: routePointsText,
                                routePointsTotal: routePointsTotal,
                                routeLandmarksTotal: routeLandmarksTotal,
                                routesTotal: routes.length,
                                heightPadding: 48,
                                crossAxisCount: 2,
                                onNavigateToRoutes: () {
                                  navigateToRoutes();
                                },
                                citiesText: citiesText,
                                citiesTotal: routeCitiesTotal,
                                height: 1200,
                                association: widget.association,
                              ),
                            ),
                            SizedBox(
                              width: (width / 2) - 40,
                              child: RouteListWidget(
                                navigateToMapViewer: (r) {
                                  navigateToMapViewer(r);
                                },
                                navigateToLandmarks: (r) {
                                  navigateToLandmarks(r);
                                },
                                navigateToCreatorMap: (r) {
                                  navigateToCreatorMap(r);
                                },
                                onSendRouteUpdateMessage: (r) {
                                  onSendRouteUpdateMessage(r);
                                },
                                onCalculateDistances: (r) {
                                  _calculateDistances(r);
                                },
                                showRouteDetails: (r) {
                                  popupDetails(r);
                                },
                                association: widget.association,
                                onCreateNewRoute: () {
                                  _onCreateNewRoute();
                                },
                              ),
                            ),
                          ],
                        );
                });
              },
            ),
            busy
                ? const Positioned(
                    child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: TimerWidget(
                          title: 'Data refreshing ...', isSmallSize: false),
                    ),
                  ))
                : gapH16,
          ],
        ),
      ),
    );
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
      required this.citiesTotal,
      required this.association});

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
        shape: getDefaultRoundedBorder(),
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              SizedBox(
                height: heightPadding,
              ),
              Text(
                association.associationName!,
                style: myTextStyleMediumLarge(context, 24),
              ),
              const SizedBox(
                height: 32,
              ),
              Text(
                user.name,
                style: myTextStyleSmall(context),
              ),
              SizedBox(
                height: 8,
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
                            fontSize: 40,
                            onTapped: () {}),
                        TotalWidget(
                            caption: landmarksText,
                            number: routeLandmarksTotal,
                            fontSize: 28,
                            onTapped: () {}),
                        TotalWidget(
                            caption: routePointsText,
                            number: routePointsTotal,
                            fontSize: 28,
                            onTapped: () {}),
                        TotalWidget(
                            caption: citiesText,
                            number: citiesTotal,
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
