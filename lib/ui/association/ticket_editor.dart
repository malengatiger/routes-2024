import 'dart:convert';
import 'dart:typed_data' as typed;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/cloud_storage_bloc.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/ticket.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/ui/association/ticket_maker.dart';
import 'package:badges/badges.dart' as bd;
import 'package:uuid/uuid.dart';

import '../../library/qr_code_generation.dart';

class TicketEditor extends StatefulWidget {
  const TicketEditor(
      {super.key,
      required this.association,
      required this.routes,
      required this.onTicketCreated});

  final lib.Association association;
  final List<lib.Route> routes;
  final Function(Ticket) onTicketCreated;

  @override
  State<TicketEditor> createState() => _TicketEditorState();
}

class _TicketEditorState extends State<TicketEditor> {
  TextEditingController valueController = TextEditingController();
  TextEditingController tripsController = TextEditingController();
  lib.Route? route;
  List<lib.Route> selectedRoutes = [];

  String ticketType = '';
  String data = 'Heita daar!';
  bool busy = false;
  bool isValidOnAllRoutes = false;
  DataApiDog dataApi = GetIt.instance<DataApiDog>();

  void _updateData() {
    String mJson = jsonEncode(widget.association.toJson());
    data = '$mJson ticketType: $ticketType routes: ${selectedRoutes.length}';
    setState(() {});
  }

  Widget _getTicketTypeDropDown() {
    List<DropdownMenuItem<int>> items = [];
    items.add(DropdownMenuItem(value: 0, child: Text('One Trip')));
    items.add(DropdownMenuItem(value: 1, child: Text("Daily")));
    items.add(DropdownMenuItem(value: 2, child: Text('Weekly')));
    items.add(DropdownMenuItem(value: 3, child: Text('Monthly')));
    items.add(DropdownMenuItem(value: 4, child: Text('Annual')));

    return DropdownButton<int>(
        hint: Text('Select Ticket Type'),
        items: items,
        onChanged: (item) {
          if (item != null) {
            switch (item) {
              case 0:
                ticketType = 'One Trip';
                break;
              case 1:
                ticketType = 'Daily';
                break;
              case 2:
                ticketType = 'Weekly';
                break;
              case 3:
                ticketType = 'Monthly';
                break;
              case 4:
                ticketType = 'Annual';
                break;
            }
            _updateData();
          }
        });
  }

  var key = GlobalKey<FormState>();

  Ticket? _currentTicket;
  Prefs prefs = GetIt.instance<Prefs>();
  int maxRoutes = 12;
  _onSubmit() async {
    pp('$mm ... submit ticket');
    if (!key.currentState!.validate()) {
      return;
    }
    if (selectedRoutes.isEmpty && !isValidOnAllRoutes) {
      showErrorToast(
          message:
              'Please add one or more routes to the ticket or make the ticket valid on all routes',
          context: context);
      return;
    }
    var user = prefs.getUser();
    List<TicketRoute> ticketRoutes = [];
    TicketType mType = TicketType.oneTrip;

    switch (ticketType) {
      case 'One Trip':
        mType = TicketType.oneTrip;
        break;
      case 'Weekly':
        mType = TicketType.weekly;
        break;
      case 'Monthly':
        mType = TicketType.monthly;
        break;
      case 'Daily':
        mType = TicketType.daily;
        break;
      case 'Annual':
        mType = TicketType.annual;
        break;
    }

    var numberOfTrips = 0;
    if (tripsController.text.isNotEmpty) {
      numberOfTrips = int.parse(tripsController.text);
    }
    if (ticketType == 'One Trip') {
      numberOfTrips = 1;
    } else {
      if (numberOfTrips == 0) {
        showErrorToast(
            message:
                'Please enter the number of trips possible for this ticket',
            context: context);
        return;
      }
      if (ticketType == 'Daily') {
        if (numberOfTrips < 2) {
          showToast(message: 'Use the One Trip ticket type', context: context);
          return;
        }
      }
      if (ticketType == 'Weekly') {
        if (numberOfTrips < 7) {
          showToast(
              message: 'The number of trips in a week should be at least 7',
              context: context);
          return;
        }
      }
      if (ticketType == 'Monthly') {
        if (numberOfTrips < 20) {
          showToast(
              message: 'The number of trips in a month should be at least 20',
              context: context);
          return;
        }
      }
      if (ticketType == 'Annual') {
        if (numberOfTrips < 200) {
          showToast(
              message: 'The number of trips in a year should be at least 200',
              context: context);
          return;
        }
      }
    }
    if (isValidOnAllRoutes) {
      pp('$mm Ticket is valid on all routes');
    } else {
      for (var r in selectedRoutes) {
        ticketRoutes.add(TicketRoute(
            routeId: r.routeId,
            routeName: r.name,
            startCityName: r.routeStartEnd!.startCityName,
            endCityName: r.routeStartEnd!.endCityName));
      }
    }
    try {
      _currentTicket = Ticket(
          ticketId: Uuid().v4(),
          associationId: widget.association.associationId!,
          userId: user!.userId,
          associationName: widget.association.associationName!,
          value: double.parse(valueController.text),
          numberOfTrips: numberOfTrips,
          ticketRoutes: ticketRoutes,
          created: DateTime.now().toUtc().toIso8601String(),
          validOnAllRoutes: isValidOnAllRoutes,
          ticketType: mType);

      setState(() {
        busy = true;
      });

      _currentTicket = await dataApi.addTicket(_currentTicket!);
      var msg = 'Ticket added OK and valid for ';
      if (isValidOnAllRoutes) {
        msg = '$msg all routes';
      } else {
        msg = '$msg ${ticketRoutes.length} routes';
      }
      pp('$mm $msg');
      if (mounted) {
        showOKToast(message: msg, context: context);
      }
      widget.onTicketCreated(_currentTicket!);
    } catch (e, s) {
      pp('$e\n$s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }
  CloudStorageBloc csb = GetIt.instance<CloudStorageBloc>();
  List<typed.Uint8List> images = [];


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        ScreenTypeLayout.builder(
          mobile: (ctx) {
            return Container(
              color: Colors.yellow,
            );
          },
          tablet: (ctx) {
            return Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: (width / 2),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Taxi Ticket Creator',
                          style: myTextStyle(
                              weight: FontWeight.w900, fontSize: 20),
                        ),
                        gapH16,
                        _getTicketTypeDropDown(),
                        gapH16,
                        Text(
                          ticketType,
                          style: myTextStyle(
                              weight: FontWeight.w900, fontSize: 28),
                        ),
                        gapH16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Ticket is valid on all routes'),
                            gapW32,
                            Switch(
                                value: isValidOnAllRoutes,
                                onChanged: (w) {
                                  setState(() {
                                    isValidOnAllRoutes = w;
                                    selectedRoutes.clear();
                                  });
                                }),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isValidOnAllRoutes
                                ? gapW32
                                : AssociationRouteList(
                                    routes: widget.routes,
                                    onRoute: (r) {
                                      if (selectedRoutes.contains(r)) {
                                        selectedRoutes.remove(r);
                                        setState(() {
                                          route = null;
                                        });
                                        _updateData();
                                        return;
                                      }
                                      if (selectedRoutes.length < maxRoutes) {
                                        selectedRoutes.insert(0, r);
                                        setState(() {
                                          route = r;
                                        });
                                        _updateData();
                                      } else {
                                        showErrorToast(
                                            message:
                                                'Route limit of $maxRoutes has been reached.\n A QR code cannot be created with more routes}',
                                            context: context);
                                      }
                                    },
                                    height: 600,
                                    isDropDown: true),
                          ],
                        ),
                        gapH16,
                        gapH16,
                        selectedRoutes.isEmpty
                            ? Center(
                                child: Text(
                                  isValidOnAllRoutes
                                      ? 'Ticket is valid on all routes'
                                      : 'No selected routes yet',
                                  style: myTextStyle(
                                      fontSize: 24, weight: FontWeight.w900),
                                ),
                              )
                            : Expanded(
                                child: SizedBox(
                                width: (width / 2),
                                child: bd.Badge(
                                  position: bd.BadgePosition.topEnd(
                                      top: -20, end: 20),
                                  badgeStyle: bd.BadgeStyle(
                                    padding: EdgeInsets.all(12),
                                    elevation: 16.0,
                                  ),
                                  badgeContent: Text(
                                    '${selectedRoutes.length}',
                                    style: myTextStyle(color: Colors.white),
                                  ),
                                  child: ListView.builder(
                                      itemCount: selectedRoutes.length,
                                      itemBuilder: (_, index) {
                                        var r = selectedRoutes[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0, vertical: 4),
                                          child: Card(
                                            elevation: 4,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    color: getColor(r.color!),
                                                    child: Center(
                                                      child: Text(
                                                        '${index + 1}',
                                                        style: myTextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  gapW32,
                                                  Text(
                                                    '${r.name}',
                                                    style: myTextStyle(
                                                        weight:
                                                            FontWeight.w900),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              )),
                        SizedBox(
                          height: 320,
                          width: 400,
                          child: Center(
                            child: Form(
                              key: key,
                              child: Column(
                                children: [
                                  gapH32,
                                  ticketType == 'One Trip'
                                      ? gapH4
                                      : TextFormField(
                                          controller: tripsController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: false, decimal: true),
                                          style: myTextStyle(
                                              fontSize: 28,
                                              weight: FontWeight.w900),
                                          decoration: InputDecoration(
                                            label: Text('Number of Trips'),
                                            labelStyle: myTextStyle(
                                                fontSize: 18,
                                                weight: FontWeight.w900),
                                          ),
                                        ),
                                  gapH16,
                                  TextFormField(
                                    controller: valueController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            signed: false, decimal: true),
                                    style: myTextStyle(
                                        fontSize: 36,
                                        weight: FontWeight.w900,
                                        color: Colors.green),
                                    decoration: InputDecoration(
                                      label: Text('Ticket Value'),
                                      labelStyle: myTextStyle(
                                          fontSize: 18,
                                          weight: FontWeight.w900),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter value of ticket';
                                      }
                                      return null;
                                    },
                                  ),
                                  gapH32,
                                  SizedBox(
                                    width: 400,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            elevation:
                                                WidgetStatePropertyAll(8.0),
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Theme.of(context)
                                                        .primaryColor)),
                                        onPressed: () {
                                          _onSubmit();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            'Submit New Ticket',
                                            style: myTextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static const mm = '💚💚💚Ticket Editor  💚';
}
