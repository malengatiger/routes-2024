import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/bloc/sem_cache.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

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

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 48.0, vertical: 1.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (_showIndex == index) {
                                      setState(() {
                                        _showIndex = null;
                                        _showActions = false;
                                      });
                                    } else {
                                      setState(() {
                                        _showActions = true;
                                        _showIndex = index;
                                      });
                                    }
                                  },
                                  child: Card(
                                    elevation: elevation,
                                    child: Column(
                                      children: [
                                        ListTile(
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
                                        _showActions && _showIndex == index
                                            ? gapH16
                                            : gapH32,
                                        if (_showActions && _showIndex == index)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 16,
                                                top: 8,
                                                bottom: 8),
                                            child: Card(
                                              elevation: 12,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    IconButton(
                                                        tooltip:
                                                            'Display Route Information',
                                                        onPressed: () {
                                                          prefs.saveRoute(rt);
                                                          widget
                                                              .showRouteDetails(
                                                                  rt);
                                                        },
                                                        icon: Icon(Icons.book,
                                                            color: Colors.amber
                                                                .shade700)),
                                                    IconButton(
                                                        tooltip:
                                                            'Show Route Map',
                                                        onPressed: () {
                                                          prefs.saveRoute(rt);
                                                          widget
                                                              .navigateToMapViewer(
                                                                  rt);
                                                        },
                                                        icon: Icon(Icons.map,
                                                            color:
                                                                Colors.green)),
                                                    IconButton(
                                                        tooltip:
                                                            'Update Route Landmarks',
                                                        onPressed: () {
                                                          prefs.saveRoute(rt);
                                                          widget
                                                              .navigateToLandmarks(
                                                                  rt);
                                                        },
                                                        icon: Icon(
                                                            Icons
                                                                .back_hand_sharp,
                                                            color:
                                                                Colors.indigo)),
                                                    IconButton(
                                                        tooltip:
                                                            'Update Route Mapping',
                                                        onPressed: () {
                                                          prefs.saveRoute(rt);
                                                          widget
                                                              .navigateToCreatorMap(
                                                                  rt);
                                                        },
                                                        icon: Icon(
                                                            Icons
                                                                .roundabout_right,
                                                            color: Colors.red)),
                                                    IconButton(
                                                        tooltip:
                                                            'Send System Route Update Message',
                                                        onPressed: () {
                                                          prefs.saveRoute(rt);
                                                          widget
                                                              .onSendRouteUpdateMessage(
                                                                  rt);
                                                        },
                                                        icon: Icon(Icons.send,
                                                            color:
                                                                Colors.blue)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (_showActions && _showIndex == index)
                                          gapH32
                                      ],
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

  bool _showActions = false;
  int? _showIndex;
}
