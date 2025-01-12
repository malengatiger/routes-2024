import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/isolates/local_finder.dart';
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/device_location_bloc.dart';
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/image_grid.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/widgets/city_selection.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:responsive_builder/responsive_builder.dart' as responsive;
import 'package:routes_2024/ui/route_detail_form_container.dart';
import 'package:uuid/uuid.dart' as uu;

class RouteEditor extends StatefulWidget {
  const RouteEditor({required this.onRouteAdded, super.key, this.route, required this.association});

  final lib.Route? route;
  final lib.Association association;
  final Function(lib.Route) onRouteAdded;

  @override
  State createState() => RouteEditorState();
}

class RouteEditorState extends State<RouteEditor>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _routeNumberController = TextEditingController();
  final mm = '🔵🔵🔵🔵🔵 RouteEditor 🔵🔵';
  lib.Route? route;
  lib.User? user;
  lib.Country? country;
  List<lib.Route> routes = [];
  final DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
  DeviceLocationBloc locationBloc = GetIt.instance<DeviceLocationBloc>();
  final Prefs prefs = GetIt.instance<Prefs>();
  String colorString = 'black';
  Color color = Colors.black;
  lib.SettingsModel? settingsModel;
  bool busy = false;
  var _cities = <lib.City>[];
  String routeEditor = 'Route Editor';
  String createOrUpdate = 'createOrUpdate';
  String routeStart = 'routeStart';
  String routeEnd = 'routeEnd';
  String selectStartEnd = 'selectStartEnd';
  String routeName = 'routeName';
  String saveRoute = 'saveRoute';
  String tapBelowToStart = 'Tap to start',
      routeColor = 'color',
      no = 'no',
      yes = 'yes',
      routeOnWay = '',
      selectStart = '',
      selectEnd = '',
      startOfRoute = '',
      endOfRoute = '',
      searchingCities = '',
      nextStep = '',
      pleaseEnterRouteName = 'please',
      selectSerachArea = '',
      doYouWantToMap = '';

  bool findStartCity = false;
  bool findEndCity = false;
  bool _showTheFuckingSearch = false;
  double radiusInKM = 600;
  bool sendingRouteUpdateMessage = false;
  SemCache semCache = GetIt.instance<SemCache>();
  ListApiDog listApiDog = GetIt.instance<ListApiDog>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _control();
  }


  void _control() async {
    setState(() {
      busy = true;
    });
    try {
      await _setTexts();
      await _getUser();
      await _getRoutes();
      await _getCities();
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorSnackBar(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  Future _getCities() async {
    final loc = await locationBloc.getLocation();
    _cities = await findCitiesByLocation(latitude: loc.latitude, 
        longitude: loc.longitude, radiusInKM: 600, limit: 600);
    setState(() {
      
    });
  }
  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    final loc = c.locale;
    routeEditor = await translator.translate('routeEditor', loc);
    createOrUpdate = await translator.translate('createOrUpdate', loc);
    routeStart = await translator.translate('routeStart', loc);
    routeEnd = await translator.translate('routeEnd', loc);
    selectStartEnd = await translator.translate('selectStartEnd', loc);
    routeName = await translator.translate('routeName', loc);
    saveRoute = await translator.translate('saveRoute', loc);
    routeEditor = await translator.translate('routeEditor', loc);
    tapBelowToStart = await translator.translate('tapBelowToStart', loc);
    routeColor = await translator.translate('routeColor', loc);
    selectSerachArea = await translator.translate('selectSerachArea', loc);
    doYouWantToMap = await translator.translate('doYouWantToMap', loc);

    pleaseEnterRouteName =
        await translator.translate('pleaseEnterRouteName', loc);

    routeOnWay = await translator.translate('routeOnWay', loc);
    selectStart = await translator.translate('selectStart', loc);
    selectEnd = await translator.translate('selectEnd', loc);

    startOfRoute = await translator.translate('startOfRoute', loc);
    endOfRoute = await translator.translate('endOfRoute', loc);
    searchingCities = await translator.translate('searchingCities', loc);

    no = await translator.translate('no', loc);
    yes = await translator.translate('yes', loc);
    nextStep = await translator.translate('nextStep', loc);

    setState(() {});
  }

  _getRoutes() async {
    routes = await semCache.getRoutes(associationId: widget.association.associationId!);
  }

  Future _getUser() async {
    user = prefs.getUser();
    country = prefs.getCountry();
    settingsModel = prefs.getSettings();
    if (settingsModel == null) {
      final res = await listApiDog.getSettings(user!.associationId!, false);
      if (res.isNotEmpty) {
        pp('$mm ${res.length} ${E.redDot} ${E.redDot} settings found.');
        myPrettyJsonPrint(res.first.toJson());
        prefs.saveSettings(res.first);
        settingsModel = prefs.getSettings();
        if (settingsModel == null) {
          pp('$mm ${E.redDot} ${E.redDot}${E.redDot} ${E.redDot} settings did not happen!!');
          settingsModel = getDefaultSettings();
        } else {
          pp('$mm we seem to be good now ${E.leaf2} what the fuck!');
          myPrettyJsonPrint(settingsModel!.toJson());
        }
      }
    } else {
      pp('$mm ${E.nice} ${E.nice} ${E.nice} ${E.nice} -- nice, check sign in widget!!');
    }
  }

  lib.SettingsModel getDefaultSettings() {
    var s = lib.SettingsModel.name();
    s.associationId = widget.association.associationId;
    s.commuterGeofenceRadius = 150;
    s.commuterSearchMinutes = 30;
    s.vehicleGeoQueryRadius = 100;
    s.vehicleSearchMinutes = 30;
    s.loiteringDelay = 30;
    s.geofenceRadius = 150;
    s.locale = 'en';
    return s;
  }

  Future<List<lib.City>> findCitiesByLocation({required double latitude, required double longitude, required double radiusInKM, required int limit}) async {
    List<lib.City> cities = [];
    try {
      pp('... starting findCitiesByLocation ... lng: $latitude lat: $longitude');
      var f = LocationFinderParameter(
          associationId: widget.association.associationId!,
          latitude: latitude,
          limit: limit,
          longitude: longitude,
          radiusInKM: radiusInKM);

      var cities = await listApiDog.findCitiesByLocation(f);
      pp('$mm cities found by location: ${_cities.length} cities within $radiusInKM km ....');
      if (_cities.isEmpty) {
        if (mounted) {
          showErrorSnackBar(
              message: 'No cities/towns/places found. Cannot execute!',
              context: context);
        }
      }
      return cities;
    } catch (e) {
      pp(e);
    }
    return cities;
  }

  lib.City? startCity, endCity;
  List<lib.City> startCities = [];
  List<lib.City> endCities = [];
  List<lib.City> finalCities = [];


  _onRoutePicked(lib.Route route) async {
    pp('\n\n$mm route picked: ${route.toJson()}');

    var sCity = await semCache.getCity(route.routeStartEnd!.startCityId!);
    var eCity = await semCache.getCity(route.routeStartEnd!.endCityId!);
    startCity = sCity;
    endCity = eCity;
    _nameController.text = route.name!;
    _routeNumberController.text = route.routeNumber ?? '';

    setState(() {});
  }

  Future<void> findNearestStartCity() async {
    _setRouteName();
    setState(() {
      findStartCity = true;
      findEndCity = false;
      _showTheFuckingSearch = true;
    });
  }

  void _setRouteName() {
    var s = StringBuffer();
    if (startCity != null) {
      s.write(startCity!.name);
      s.write(' - ');
    }
    if (endCity != null) {
      s.write(endCity!.name);
    }
    _nameController.text = s.toString();
    setState(() {});
  }

  Future<void> findNearestEndCity() async {
    _setRouteName();
    setState(() {
      findStartCity = false;
      findEndCity = true;
      _showTheFuckingSearch = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool sending = false;

  Future<void> onSubmitRequested() async {
    pp('$mm ................................. onSubmitRequested ...');
    //todo - validate!
    if (_formKey.currentState!.validate()) {
      pp('$mm ... validation is OK');
      showToast(
        message: routeOnWay,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        textStyle: myTextStyleMediumPrimaryColor(context),
        context: context,
        padding: 28.0,
        duration: const Duration(seconds: 3),
      );
    } else {
      return;
    }
    if (startCity == null) {
      showToast(
          message: selectStart,
          context: context,
          padding: 20.0,
          backgroundColor: Colors.amber,
          textStyle: myTextStyleMediumWithColor(context, Colors.red),
          duration: const Duration(seconds: 3));
      return;
    }
    if (endCity == null) {
      showToast(
          message: selectEnd,
          context: context,
          padding: 20.0,
          backgroundColor: Colors.amber,
          textStyle: myTextStyleMediumWithColor(context, Colors.black),
          duration: const Duration(seconds: 3));
      return;
    }
    startCities = await findCitiesByLocation(latitude: startCity!.position!.coordinates[1],
        longitude: startCity!.position!.coordinates[0], radiusInKM: 50, limit: 25);
    endCities = await findCitiesByLocation(latitude: endCity!.position!.coordinates[1],
        longitude: endCity!.position!.coordinates[0], radiusInKM: 50, limit: 25);
    _filterCities();
    setState(() {
      sending = true;
    });
    final se = lib.RouteStartEnd(
      startCityId: startCity!.cityId!,
      startCityName: startCity!.name,
      endCityId: endCity!.cityId!,
      endCityName: endCity!.name,
      startCityPosition: lib.Position(
        type: "Point",
        coordinates: startCity!.position!.coordinates,
      ),
      endCityPosition: lib.Position(
        type: 'Point',
        coordinates: endCity!.position!.coordinates,
      ),
    );

    final route = lib.Route(
      routeNumber: _routeNumberController.value.text,
      routeId: const uu.Uuid().v4(),
      associationId: widget.association.associationId!,
      associationName: widget.association.associationName,
      lengthInMetres: 0,
      routeStartEnd: se,
      created: DateTime.now().toUtc().toIso8601String(),
      color: colorString,
      userId: user!.userId,
      countryId: widget.association.countryId,
      isActive: true,
      countryName: widget.association.countryName,
      userUrl: user!.profileUrl,
      userName: user!.name,
      name: _nameController.value.text,
    );

    try {
      var res = await dataApiDog.addRoute(route);
      pp('$mm ... 🥬🥬🥬🥬🥬 route has been added ...');
      myPrettyJsonPrint(res.toJson());
      //add cities
      await _addRouteCities(route.routeId!, route.name!);
      _resetFields();
      widget.onRouteAdded(res);
      if (mounted) {
        //_showDialog(route);
        showToast(
          message: 'Route has been created:🥬🥬🥬🥬 ${route.name}',
          backgroundColor: Colors.green.shade700,
          textStyle: myTextStyleMediumBoldWithColor(
              context: context, color: Colors.white, fontSize: 16),
          context: context,
          padding: 28.0,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorToast(
            message: '$e',
            context: context);
      }
    }
    setState(() {
      sending = false;
    });
  }

  Future _addRouteCities(String routeId, String routeName) async {
    pp('$mm _addRouteCities ... ${finalCities.length}');
    int cnt = 0;
    for (var city in finalCities) {
      var rc = lib.RouteCity(routeId, routeName, city.cityId, city.name, DateTime.now().toUtc().toIso8601String(),
          widget.association.associationId, city.position);
      var res = await dataApiDog.addRouteCity(rc);
      if (res != null) {
        cnt++;
      }
    }
    pp('$mm ... route cities added, $cnt');

  }
  _filterCities() {
    HashMap<String, lib.City> map = HashMap();
    for (var sc in startCities) {
      map[sc.cityId!] = sc;
    }
    for (var sc in endCities) {
      map[sc.cityId!] = sc;
    }
    var list = map.values.toList();
    for (var value in list) {
      finalCities.add(value);
    }
    pp('$mm filtered cities: ${finalCities.length}');

  }
  _resetFields() {
    _nameController.text = '';
    _routeNumberController.text = '';
    startCity = null;
    endCity = null;
  }

  void onSendRouteUpdateMessage() async {
    pp("$mm onSendRouteUpdateMessage .........");
    setState(() {
      sendingRouteUpdateMessage = true;
    });
    try {
      if (widget.route != null) {
        final req = lib.RouteUpdateRequest(
          associationId: widget.route!.associationId,
          created: DateTime.now().toUtc().toIso8601String(),
          routeId: widget.route!.routeId,
          routeName: widget.route!.name,
          userId: user!.userId,
          userName: user!.name,
        );
        await dataApiDog.sendRouteUpdateMessage(req);
        pp('$mm onSendRouteUpdateMessage happened OK! ${E.nice}');
      }
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

  @override
  Widget build(BuildContext context) {
    var leftPadding = 24.0;
    final type = getDeviceType();
    if (type == 'phone') {
      leftPadding = 12.0;
    }
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                routeEditor,
                style: myTextStyleLarge(context),
              ),
              bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(8), child: Column()),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 64, horizontal: 64),
              child: Stack(
                children: [
                  responsive.ScreenTypeLayout.builder(
                    mobile: (ctx) {
                      return busy
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                  child: TimerWidget(
                                      title: searchingCities,
                                      isSmallSize: true)),
                            )
                          : sending
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    backgroundColor: Colors.indigo,
                                  ),
                                )
                              : RouteDetailFormContainer(
                                  formKey: _formKey,
                                  onSendRouteUpdateMessage:
                                      onSendRouteUpdateMessage,
                                  onRouteStartSearch: findNearestStartCity,
                                  onRouteEndSearch: findNearestEndCity,
                                  color: color,
                                  nameController: _nameController,
                                  routeNumberController: _routeNumberController,
                                  nearestEnd: endCity,
                                  nearestStart: startCity,
                                  onSubmit: onSubmitRequested,
                                  onColorSelected: (c, s) {
                                    setState(() {
                                      color = c;
                                      colorString = s;
                                    });
                                  },
                                  onRefresh: (radius) async {
                                    radiusInKM = radius;
                                    _getCities();
                                  },
                                  radiusInKM: 500,
                                  numberOfCities: _cities.length,
                                  createUpdate: createOrUpdate,
                                  routeName: routeName,
                                  routeColor: routeColor,
                                  pleaseEnterRouteName: pleaseEnterRouteName,
                                  routeEnd: routeEnd,
                                  routeStart: routeStart,
                                  tapBelowToStart: tapBelowToStart,
                                  saveRoute: saveRoute,
                                  selectSearchArea: selectSerachArea,
                                );
                    },
                    tablet: (ctx) {
                      return responsive.OrientationLayoutBuilder(
                        portrait: (ctx) {
                          return Row(
                            children: [
                              SizedBox(
                                width: (width / 2) + 48,
                                child: RouteDetailFormContainer(
                                  formKey: _formKey,
                                  onSendRouteUpdateMessage:
                                      onSendRouteUpdateMessage,
                                  numberOfCities: _cities.length,
                                  onRouteStartSearch: findNearestStartCity,
                                  onRouteEndSearch: findNearestEndCity,
                                  color: color,
                                  selectSearchArea: selectSerachArea,
                                  saveRoute: saveRoute,
                                  radiusInKM: radiusInKM,
                                  nameController: _nameController,
                                  routeNumberController: _routeNumberController,
                                  nearestEnd: endCity,
                                  nearestStart: startCity,
                                  onSubmit: onSubmitRequested,
                                  createUpdate: createOrUpdate,
                                  routeName: routeName,
                                  routeColor: routeColor,
                                  pleaseEnterRouteName: pleaseEnterRouteName,
                                  routeEnd: routeEnd,
                                  routeStart: routeStart,
                                  tapBelowToStart: tapBelowToStart,
                                  onColorSelected: (c, s) {
                                    setState(() {
                                      color = c;
                                      colorString = s;
                                    });
                                  },
                                  onRefresh: (radius) {
                                    radiusInKM = radius;
                                    _getCities();
                                  },
                                ),
                              ),
                              SizedBox(
                                width: (width / 2) - 64,
                                child: ImageGrid(crossAxisCount: 3),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    desktop: (ctx) {
                      return responsive.OrientationLayoutBuilder(
                          portrait: (ctx) {
                        return Row(
                          children: [
                            SizedBox(
                              width: (width / 2) - 200,
                              child: RouteDetailFormContainer(
                                formKey: _formKey,
                                onSendRouteUpdateMessage:
                                    onSendRouteUpdateMessage,
                                numberOfCities: _cities.length,
                                onRouteStartSearch: findNearestStartCity,
                                onRouteEndSearch: findNearestEndCity,
                                color: color,
                                selectSearchArea: selectSerachArea,
                                saveRoute: saveRoute,
                                radiusInKM: radiusInKM,
                                nameController: _nameController,
                                routeNumberController: _routeNumberController,
                                nearestEnd: endCity,
                                nearestStart: startCity,
                                onSubmit: onSubmitRequested,
                                createUpdate: createOrUpdate,
                                routeName: routeName,
                                routeColor: routeColor,
                                pleaseEnterRouteName: pleaseEnterRouteName,
                                routeEnd: routeEnd,
                                routeStart: routeStart,
                                tapBelowToStart: tapBelowToStart,
                                onColorSelected: (c, s) {
                                  setState(() {
                                    color = c;
                                    colorString = s;
                                  });
                                },
                                onRefresh: (radius) {
                                  radiusInKM = radius;
                                  _getCities();
                                },
                              ),
                            ),
                            SizedBox(
                              width: (width / 2) - 80,
                              child: ImageGrid(crossAxisCount: 3),
                            ),
                          ],
                        );
                      });
                    },
                  ),
                  _showTheFuckingSearch && _cities.isNotEmpty
                      ? Positioned(
                          bottom: 8.0,
                          left: leftPadding,
                          right: leftPadding,
                          child: SizedBox(
                            width: 460,
                            height: 600,
                            child: CitySearch(
                              title: findStartCity ? startOfRoute : endOfRoute,
                              onCitySelected: (c) {
                                pp('.... city at start: ${c.name}');
                                if (findEndCity) {
                                  endCity = c;
                                }
                                if (findStartCity) {
                                  startCity = c;
                                }
                                _setRouteName();
                                setState(() {
                                  _showTheFuckingSearch = false;
                                });
                              },
                              cities: _cities,
                              onCityAdded: (c) {
                                pp('$mm ... city added: ${c.name}');
                                _getCities();
                              },
                            ),
                          ))
                      : const SizedBox(),
                  busy
                      ? Positioned(
                          child: Center(
                          child: TimerWidget(
                              title: 'Finding cities, towns and places ...',
                              isSmallSize: false),
                        ))
                      : gapW32,
                  sending
                      ? Positioned(
                      child: Center(
                        child: TimerWidget(
                            title: 'Adding route to database',
                            isSmallSize: false),
                      ))
                      : gapW32,
                ],
              ),
            )));
  }
}
