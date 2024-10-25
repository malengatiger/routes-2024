import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/widgets/scanners/qrcode_generator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/ui/association/association_edit.dart';
import 'package:routes_2024/ui/association/example_file_widget.dart';
import 'package:routes_2024/ui/association/routes_edit.dart';
import 'package:routes_2024/ui/association/ticket_maker.dart';
import 'package:routes_2024/ui/association/users_edit.dart';
import 'package:routes_2024/ui/association/vehicles_edit.dart';

import '../route_data_widget.dart';
import '../route_list.dart';

class AssociationMain extends StatefulWidget {
  const AssociationMain({super.key, this.association});

  final Association? association;

  @override
  AssociationMainState createState() => AssociationMainState();
}

class AssociationMainState extends State<AssociationMain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '️💛️💛️💛 AssociationMain ️💛';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    if (widget.association == null) {
      currentWidget = AssociationEdit(
        onClose: () {},
      );
    } else {
      currentWidget = AssociationEdit(
        association: widget.association,
        onClose: () {},
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int index = 0;
  Widget? currentWidget;

  getWidget() {
    pp('$mm getting current widget : $index');
    late Widget mWidget;
    switch (index) {
      case 0:
        if (widget.association != null) {
          currentWidget = UsersEdit(
            association: widget.association!,
          );
        }
        break;
      case 1:
        if (widget.association != null) {
          currentWidget = VehiclesEdit(
            association: widget.association!,
          );
        }
        break;
      case 2:
        currentWidget = RoutesEdit();
        break;
      case 3:
        _navigateToRoutes();
        break;

      case 4:
        NavigationUtils.navigateTo(
            context: context,
            widget: TicketMaker(association: widget.association!),
            transitionType: PageTransitionType.leftToRight);
        break;

      case 5:
        currentWidget = ExampleFileWidget();
        break;

      default:
        currentWidget = Container(
          color: Colors.indigo,
          child: Center(
            child: Text('WTF?'),
          ),
        );
    }

    setState(() {});
  }

  _navigateToRoutes() async {
    NavigationUtils.navigateTo(
        context: context,
        widget: RouteDataWidget(widget.association!),
        transitionType: PageTransitionType.leftToRight);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.association == null
                ? 'Association Data Manager'
                : widget.association!.associationName!,
            style: myTextStyle(
                fontSize: 24,
                weight: FontWeight.w900,
                color: Theme.of(context).primaryColor),
          ),
        ),
        body: SafeArea(
            child: Stack(
          children: [
            ScreenTypeLayout.builder(
              mobile: (_) {
                return Container(color: Colors.grey);
              },
              tablet: (_) {
                return Container(color: Colors.purple);
              },
              desktop: (_) {
                return Row(
                  children: [
                    SizedBox(
                      width: (width / 2) - 460,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 8,
                          child: KasieNavigation(
                              width: (width / 2) - 160,
                              onTapped: (index) {
                                pp('$mm nav drawer header tapped: $index');
                                this.index = index;
                                getWidget();
                              }),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (width / 2) + 400,
                      child: currentWidget == null
                          ? Container(color: Colors.teal)
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Card(elevation: 8, child: currentWidget!),
                            ),
                    ),
                  ],
                );
              },
            )
          ],
        )));
  }
}

class KasieNavigation extends StatelessWidget {
  const KasieNavigation(
      {super.key, required this.width, required this.onTapped});

  final double width;
  final Function(int) onTapped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
              height: 140,
              child: Column(
                children: [
                  Image.asset(
                    'assets/ktlogo_red.png',
                    width: 160,
                    height: 100,
                  ),
                  Text('Association Data',
                      style: myTextStyleMediumLarge(context, 28))
                ],
              )),
          gapH32,
          gapH32,
          GestureDetector(
            onTap: () {
              onTapped(0);
            },
            child: ListTile(
              leading: Icon(Icons.people,
                  size: 36, color: Theme.of(context).primaryColor),
              title: Text('Staff', style: myTextStyle(weight: FontWeight.w900, fontSize: 18)),
            ),
          ),
          gapH32,
          GestureDetector(
            onTap: () {
              onTapped(1);
            },
            child: ListTile(
              leading: Icon(
                Icons.car_crash_rounded,
                size: 36,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Vehicles', style: myTextStyle(weight: FontWeight.w900, fontSize: 18),),
            ),
          ),
          // gapH32,
          // GestureDetector(
          //   onTap: () {
          //     onTapped(2);
          //   },
          //   child: ListTile(
          //     leading: Icon(
          //       Icons.airplane_ticket,
          //       size: 36,
          //       color: Theme.of(context).primaryColor,
          //     ),
          //     title: Text('Commuter Tickets', style: myTextStyle(weight: FontWeight.w900, fontSize: 18)),
          //   ),
          // ),
          gapH32,
          GestureDetector(
            onTap: () {
              onTapped(3);
            },
            child: ListTile(
              leading: Icon(
                Icons.roundabout_right,
                size: 36,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Routes', style: myTextStyle(weight: FontWeight.w900, fontSize: 18)),
            ),
          ),

          gapH32,
          GestureDetector(
            onTap: () {
              onTapped(4);
            },
            child: ListTile(
              leading: Icon(
                Icons.airplane_ticket,
                size: 36, color: Theme.of(context).primaryColor,
              ),
              title: Text('Ticket Maker', style: myTextStyle(weight: FontWeight.w900, fontSize: 18)),
            ),
          ),
          gapH32,
          gapH32,
          GestureDetector(
            onTap: () {
              onTapped(5);
            },
            child: ListTile(
              leading: Icon(
                Icons.folder_copy_rounded,
                size: 36,
              ),
              title: Text('Example upload Files'),
            ),
          ),
          gapH32,
        ],
      ),
    );
  }
}
