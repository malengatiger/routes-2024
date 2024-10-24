import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/data/ticket.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:routes_2024/ui/association/ticket_editor.dart';

class TicketMaker extends StatefulWidget {
  const TicketMaker({super.key, required this.association});

  final lib.Association association;

  @override
  TicketMakerState createState() => TicketMakerState();
}

class TicketMakerState extends State<TicketMaker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<lib.Route> routes = [];
  List<Ticket> tickets = [];
  ListApiDog listApi = GetIt.instance<ListApiDog>();
  bool busy = false;
  static const mm = '✳️✳️✳️ TicketMaker ✳️';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  void _getData() async {
    setState(() {
      busy = true;
    });

    try {
      await _getRoutes();
      await _getTickets();
    } catch (e, s) {
      pp('$mm $e\n$s');
      if (mounted) {
        showErrorToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  Future _getRoutes() async {
    routes = await listApi.getAssociationRoutes(
        widget.association.associationId!, false);
  }

  Future _getTickets() async {
    tickets =
        await listApi.getAssociationTickets(widget.association.associationId!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Ticket? selectedTicket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                tickets.isEmpty
                    ? Center(
                        child: Text(
                          'No tickets created yet',
                          style: myTextStyle(
                              fontSize: 20, weight: FontWeight.w900),
                        ),
                      )
                    : Column(
                        children: [
                          Text(
                            'Association Tickets',
                            style: myTextStyle(
                                weight: FontWeight.w900, fontSize: 24),
                          ),
                          gapH32,
                          Expanded(
                            child: AssociationTicketList(
                                tickets: tickets,
                                onTicket: (t) {
                                  setState(() {
                                    selectedTicket = t;
                                  });
                                },
                                height: 800),
                          ),
                        ],
                      ),
                TicketEditor(
                  association: widget.association,
                  routes: routes,
                  onTicketCreated: (t) {
                    pp('$mm onTicketCreated; 🍎${t.toJson()}🍎');
                    tickets.insert(0, t);
                    setState(() {});
                  },
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}

class AssociationTicketList extends StatefulWidget {
  const AssociationTicketList(
      {super.key,
      required this.tickets,
      required this.onTicket,
      required this.height});

  final List<Ticket> tickets;
  final Function(Ticket) onTicket;
  final double height;

  @override
  State<AssociationTicketList> createState() => _AssociationTicketListState();
}

class _AssociationTicketListState extends State<AssociationTicketList> {
  bool _showTicketRoutes = false;

  int? _showTicketRoutesIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: widget.height,
      width: 600,
      child: ListView.builder(
          itemCount: widget.tickets.length,
          itemBuilder: (_, index) {
            var ticket = widget.tickets[index];
            var mType = '';
            switch (ticket.ticketType) {
              case TicketType.oneTrip:
                mType = 'One Trip';
                break;
              case TicketType.daily:
                mType = 'Daily';
                break;
              case TicketType.monthly:
                mType = 'Monthly';
                break;
              case TicketType.weekly:
                mType = 'Weekly';
                break;
              case TicketType.annual:
                mType = 'Annual';
                break;

              default:
                mType = 'One Trip';
            }
            return GestureDetector(
                onTap: () {
                  widget.onTicket(ticket);
                },
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Card(
                              elevation: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  '${ticket.qrCodeUrl}',
                                  height: 120,
                                  width: 120,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    pp(' routes tapped, should show list ');
                                    setState(() {
                                      _showTicketRoutes = true;
                                      _showTicketRoutesIndex = index;
                                    });
                                  },
                                  child: Card(
                                    elevation: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TicketElement(
                                        label: 'Ticket Routes',
                                        text: '${ticket.ticketRoutes!.length}',
                                        textColor: Colors.blue,
                                        onTap: () {},
                                      ),
                                    ),
                                  ),
                                ),
                                gapH32,
                                TicketElement(
                                  label: 'Ticket Value',
                                  text: '${ticket.value!}',
                                  onTap: () {},
                                ),
                                TicketElement(
                                  label: 'Ticket Type',
                                  text: mType,
                                  onTap: () {},
                                ),
                                TicketElement(
                                  label: 'Number of Trips',
                                  text: '${ticket.numberOfTrips!}',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_showTicketRoutes &&
                            _showTicketRoutesIndex == index)
                          SizedBox(
                            height: _getHeight(ticket),
                            width: 400,
                            child: Card(
                              elevation: 8,
                              child: Column(
                                children: [
                                  gapH12,
                                  Text('Ticket is valid on these route(s)', style: myTextStyle(weight: FontWeight.w900),),
                                  gapH8,
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: ListView.builder(
                                          itemCount: ticket.ticketRoutes!.length,
                                          itemBuilder: (_, index) {
                                            var tr = ticket.ticketRoutes![index];
                                            return Row(
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: myTextStyle(
                                                        weight: FontWeight.w900,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                gapW32,
                                                Text(
                                                  '${tr.routeName}',
                                                  style: myTextStyle(fontSize: 12),
                                                ),
                                              ],
                                            );
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ));
          }),
    );
  }

  double _getHeight(Ticket ticket) {
    if (ticket.ticketRoutes!.length < 5.0) {
      return ticket.ticketRoutes!.length * 48.0;
    }
    if (ticket.ticketRoutes!.length < 15.0) {
      return ticket.ticketRoutes!.length * 40;
    }
    return ticket.ticketRoutes!.length * 28;
  }
}

class AssociationRouteList extends StatelessWidget {
  const AssociationRouteList(
      {super.key,
      required this.routes,
      required this.onRoute,
      required this.height,
      required this.isDropDown});

  final List<lib.Route> routes;
  final Function(lib.Route) onRoute;
  final double height;
  final bool isDropDown;

  @override
  Widget build(BuildContext context) {
    if (isDropDown) {
      List<DropdownMenuItem<lib.Route>> items = [];
      int index = 0;
      for (var route in routes) {
        items.add(
          DropdownMenuItem(
            value: route,
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  color: getColor(route.color!),
                  child: Center(
                    child: Text('${index + 1}'),
                  ),
                ),
                gapW32,
                Text('${route.name}'),
              ],
            ),
          ),
        );
      }
      return DropdownButton<lib.Route>(
          hint: Text('Add Route to Ticket'),
          items: items,
          onChanged: (route) {
            if (route != null) {
              onRoute(route);
            }
          });
    }
    return SizedBox(
      height: height,
      child: ListView.builder(itemBuilder: (_, index) {
        var route = routes[index];
        return GestureDetector(
          onTap: () {
            onRoute(route);
          },
          child: Card(
            elevation: 8,
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  color: getColor(route.color!),
                  child: Center(
                    child: Text('${index + 1}'),
                  ),
                ),
                gapW32,
                Text('${route.name}'),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class TicketElement extends StatelessWidget {
  const TicketElement(
      {super.key,
      required this.label,
      required this.text,
      required this.onTap,
      this.textColor});

  final String label, text;
  final Color? textColor;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          gapW32,
          Text(
            text,
            style: myTextStyle(
                weight: FontWeight.w900,
                fontSize: 20,
                color: textColor ?? Colors.black),
          ),
        ],
      ),
    );
  }
}
