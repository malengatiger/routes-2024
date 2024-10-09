import 'package:flutter/material.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/ui/association/association_edit.dart';
import 'package:routes_2024/ui/association/routes_edit.dart';
import 'package:routes_2024/ui/association/users_edit.dart';
import 'package:routes_2024/ui/association/vehicles_edit.dart';

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
      currentWidget = AssociationEdit();
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
    pp('$mm getting widget : $index');
    late Widget mWidget;
    switch (index) {
      case 0:
        currentWidget = AssociationEdit();
        break;
      case 1:
        currentWidget = UsersEdit();
        break;
      case 2:
        currentWidget = VehiclesEdit();
        break;
      case 3:
        currentWidget = RoutesEdit();
        break;
      default:
        currentWidget = Container(color: Colors.teal);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Association Data Manager'),
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
              height: 200,
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
          GestureDetector(
            onTap: () {
              onTapped(0);
            },
            child: ListTile(
              leading: Icon(Icons.home),
              title: Text('Create Association'),
            ),
          ),
          gapH32,
          GestureDetector(
            onTap: () {
              onTapped(1);
            },
            child: ListTile(
              leading: Icon(Icons.people),
              title: Text('Manage Association Staff'),
            ),
          ),
          gapH32,
          GestureDetector(
            onTap: () {
              onTapped(2);
            },
            child: ListTile(
              leading: Icon(Icons.car_crash_rounded),
              title: Text('Manage Association Vehicles'),
            ),
          ),
          gapH32,
          GestureDetector(
            onTap: () {
              onTapped(3);
            },
            child: ListTile(
              leading: Icon(Icons.roundabout_right),
              title: Text('Manage Association Routes'),
            ),
          ),
        ],
      ),
    );
  }
}
