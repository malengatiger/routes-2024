import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/image_grid.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/ui/association/association_edit.dart';
import 'package:routes_2024/ui/association/association_main.dart';
import 'package:routes_2024/ui/route_data_widget.dart';
import 'package:badges/badges.dart' as bd;

class AssociationList extends StatefulWidget {
  const AssociationList({super.key});

  @override
  AssociationListState createState() => AssociationListState();
}

class AssociationListState extends State<AssociationList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '😡😡😡AssociationList 😡';
  ListApiDog api = GetIt.instance<ListApiDog>();
  List<Association> associations = [];
  Association? association;
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getAssociations(false);
  }

  _navigateToData(Association ass) async {
    prefs.saveAssociation(ass);
    NavigationUtils.navigateTo(
        context: context,
        widget: AssociationMain(
          association: ass,
        ),
        transitionType: PageTransitionType.leftToRight);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _getAssociations(bool refresh) async {
    pp('$mm ..................... getting associations ... refresh: $refresh');
    setState(() {
      busy = true;
    });
    try {
      associations = await api.getAssociations(refresh);
      associations
          .sort((a, b) => a.associationName!.compareTo(b.associationName!));
      pp('$mm ... getting associations:  🍎 ${associations.length} found.');
    } catch (e) {
      pp('$mm error: $e');
      if (mounted) {
        showErrorSnackBar(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  Prefs prefs = GetIt.instance<Prefs>();

  _navigateToRoutesDash(Association ass) {
    pp('$mm ... _navigateToDashboard ...');
    prefs.saveAssociation(ass);
    NavigationUtils.navigateTo(
        context: context,
        widget: RouteDataWidget(ass),
        transitionType: PageTransitionType.leftToRight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Taxi Associations/Organizations',
            style: myTextStyleLarge(context),
          ),
          actions: [
            IconButton(
                tooltip: 'Add new Taxi Association/Organisation',
                onPressed: () {
                  setState(() {
                    _showEditor = true;
                  });
                },
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                  size: 48,
                )),
            IconButton(
                tooltip: 'Refresh the list of associations/organization',
                onPressed: () {
                  _getAssociations(true);
                },
                icon: Icon(Icons.refresh)),
            gapW32,
          ]),
      body: SafeArea(
        child: Stack(
          children: [
            ScreenTypeLayout.builder(
              mobile: (_) {
                return getWidget();
              },
              tablet: (_) {
                return AssScaffold(
                    leftWidget: getWidget(),
                    rightWidget: ImageGrid(
                      crossAxisCount: 3,
                    ));
              },
              desktop: (_) {
                return AssScaffold(
                    leftWidget: getWidget(),
                    rightWidget: ImageGrid(
                      crossAxisCount: 3,
                    ));
              },
            ),
            _showEditor
                ? Positioned(
                    child: Center(
                    child: Card(
                      elevation: 8,
                      child: SizedBox(
                        width: 600,
                        height: 800,
                        child: AssociationEdit(
                          association: association,
                          onClose: () {
                            setState(() {
                              _showEditor = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ))
                : gapW32,
          ],
        ),
      ),
    );
  }

  bool _showEditor = false;

  Widget getWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: bd.Badge(
        badgeContent: Text('${associations.length}'),
        badgeStyle: bd.BadgeStyle(
          badgeColor: Theme.of(context).primaryColor,
          elevation: 8,
          padding: EdgeInsets.all(20.0),
        ),
        child: ListView.builder(
            itemCount: associations.length,
            itemBuilder: (_, index) {
              var ass = associations[index];
              return GestureDetector(
                  onTap: () {
                    association = ass;
                    _navigateToData(ass);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                              title: Text(
                                ass.associationName!,
                                style: myTextStyleMediumLarge(context, 20),
                              ),
                              subtitle: Text(
                                ass.countryName ?? 'NOT AVAILABLE',
                                style: myTextStyleSmall(context),
                              ),
                              leading: Icon(Icons.car_crash_rounded,
                                  color: Theme.of(context).primaryColor)),
                        )),
                  ));
            }),
      ),
    );
  }
}

class AssScaffold extends StatelessWidget {
  const AssScaffold(
      {super.key, required this.leftWidget, required this.rightWidget});

  final Widget leftWidget, rightWidget;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.symmetric(vertical: 48, horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: (width / 2) - 128, child: leftWidget),
                SizedBox(width: (width / 2) - 48, child: rightWidget),
              ],
            )));
  }
}
