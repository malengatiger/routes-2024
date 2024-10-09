import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:routes_2024/ui/route_editor.dart';

class RouteListWidget extends StatefulWidget {
  const RouteListWidget(
      {super.key,
      required this.navigateToMapViewer,
      required this.navigateToLandmarks,
      required this.navigateToCreatorMap,
      required this.onSendRouteUpdateMessage,
      required this.onCalculateDistances,
      required this.showRouteDetails,
      required this.onCreateNewRoute,
      this.currentRoute,
      required this.association});

  final Function(lib.Route) navigateToMapViewer;
  final Function(lib.Route) navigateToLandmarks;
  final Function(lib.Route) navigateToCreatorMap;
  final Function(lib.Route) onSendRouteUpdateMessage;
  final Function(lib.Route) onCalculateDistances;
  final Function(lib.Route) showRouteDetails;
  final Function onCreateNewRoute;
  final lib.Route? currentRoute;
  final lib.Association association;

  @override
  State<RouteListWidget> createState() => _RouteListWidgetState();
}

class _RouteListWidgetState extends State<RouteListWidget> {
  final Prefs prefs = GetIt.instance<Prefs>();
  final ListApiDog listApiDog = GetIt.instance<ListApiDog>();
  final SemCache semCache = GetIt.instance<SemCache>();

  static const mm = '🎽🎽🎽 RouteListWidget 🎽';

  List<FocusedMenuItem> _getMenuItems(lib.Route route, BuildContext context) {
    //prefs.saveRoute(route);
    List<FocusedMenuItem> list = [];

    list.add(FocusedMenuItem(
        title: Text('Display Route Details',
            style: myTextStyleMediumBlack(context)),
        // backgroundColor: Theme.of(context).primaryColor,
        trailingIcon: Icon(
          Icons.map,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          prefs.saveRoute(route);
          widget.showRouteDetails(route);
        }));
    //
    list.add(FocusedMenuItem(
        title: Text('View Route Map', style: myTextStyleMediumBlack(context)),
        // backgroundColor: Theme.of(context).primaryColor,
        trailingIcon: Icon(
          Icons.map,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          prefs.saveRoute(route);
          widget.navigateToMapViewer(route);
        }));
    //
    list.add(FocusedMenuItem(
        title: Text('Route Landmarks', style: myTextStyleMediumBlack(context)),
        trailingIcon: Icon(
          Icons.water_damage_outlined,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          prefs.saveRoute(route);
          widget.navigateToLandmarks(route);
        }));
    //
    list.add(FocusedMenuItem(
        title: Text('Update Route', style: myTextStyleMediumBlack(context)),
        // backgroundColor: Theme.of(context).primaryColor,
        trailingIcon: Icon(
          Icons.edit,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          prefs.saveRoute(route);
          widget.navigateToCreatorMap(route);
        }));

    list.add(FocusedMenuItem(
        title: Text('Send Route Update Message',
            style: myTextStyleMediumBlack(context)),
        // backgroundColor: Theme.of(context).primaryColor,
        trailingIcon: Icon(
          Icons.send,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          prefs.saveRoute(route);
          widget.onSendRouteUpdateMessage(route);
        }));
    return list;
  }

  List<lib.Route> mRoutes = [];
  @override
  void initState() {
    super.initState();
    _setRoutes();
  }

  _setRoutes() async {
    mRoutes = await listApiDog.getAssociationRoutes(
        widget.association.associationId!, true);

    await Future.delayed(Duration(milliseconds: 20));
    pp('$mm mRoutes: ${mRoutes.length}, setting state ...');
    setState(() {});
  }

  _onCreateRoute() async {
    pp('... _onCreateRoute ... ');
    widget.onCreateNewRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        elevation: 2,
        shape: getRoundedBorder(radius: 16),
        child: Column(
          children: [
            SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    gapW32,
                    Center(
                      child: Text(
                        'Taxi Routes',
                        style: myTextStyleMediumLarge(context, 36),
                      ),
                    ),
                    IconButton(
                        tooltip: 'Create new Route',
                        onPressed: () {
                          _onCreateRoute();
                        },
                        icon: Icon(Icons.add)),
                    gapW32,
                  ],
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: bd.Badge(
                  position: bd.BadgePosition.topEnd(end: 12, top: -20),
                  badgeContent: Text(
                    '${mRoutes.length}',
                    style: TextStyle(color: Colors.white),
                  ),
                  badgeStyle: const bd.BadgeStyle(
                      padding: EdgeInsets.all(16), elevation: 16),
                  child: StreamBuilder<List<lib.Route>>(
                      stream: listApiDog.routeStream,
                      builder: (ctx, snapshot) {
                        pp('$mm .... build method executing ...');
                        if (snapshot.hasData) {
                          mRoutes = snapshot.data!;
                          pp('$mm stream has returned: ${mRoutes.length}');
                        }
                        return ListView.builder(
                            itemCount: mRoutes.length,
                            itemBuilder: (ctx, index) {
                              var elevation = 6.0;
                              final rt = mRoutes.elementAt(index);

                              return FocusedMenuHolder(
                                menuOffset: 24,
                                duration: const Duration(milliseconds: 300),
                                menuItems: _getMenuItems(rt, context),
                                animateMenuItems: true,
                                openWithTap: true,
                                onPressed: () {
                                  pp('💛️️ tapped FocusedMenuHolder ...');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 48.0, vertical: 1.0),
                                  child: Card(
                                    shape: getRoundedBorder(radius: 16),
                                    elevation: elevation,
                                    child: ListTile(
                                      leading: Container(
                                        height: 24,
                                        width: 24,
                                        color: getColor(rt.color!),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style:
                                                myTextStyleMediumLargeWithColor(
                                                    context,
                                                    rt.color == 'white'
                                                        ? Colors.black
                                                        : Colors.white,
                                                    14),
                                          ),
                                        ),
                                      ),
                                      title: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          '${rt.name}',
                                          style: myTextStyleMediumLarge(
                                              context, 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
