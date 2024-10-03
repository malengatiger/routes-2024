import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/ui/dashboard.dart';

class AssociationList extends StatefulWidget {
  const AssociationList({super.key});

  @override
  AssociationListState createState() => AssociationListState();
}

class AssociationListState extends State<AssociationList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '😡😡😡 AssociationList 😡';
  ListApiDog api = GetIt.instance<ListApiDog>();
  List<Association> associations = [];
  bool busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getAssociations(false);
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
      associations = await api.getAssociations(false);
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

  _navigateToDashboard(Association ass) {
    pp('$mm ... _navigateToDashboard ...');
    prefs.saveAssociation(ass);
    NavigationUtils.navigateTo(
        context: context,
        widget: Dashboard(ass),
        transitionType: PageTransitionType.leftToRight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Associations',
          style: myTextStyleLarge(context),
        ),
        actions: [
          IconButton(onPressed: (){
            _getAssociations(true);
          }, icon: Icon(Icons.refresh)),
        ]
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ScreenTypeLayout.builder(mobile: (_){
              return AssociationList();
            }, tablet: (_){
              return AssScaffold(leftWidget: AssociationList(), rightWidget: Container(color:Colors.teal));
            }, desktop: (_){
              return AssScaffold(leftWidget: AssociationList(), rightWidget: Container(color:Colors.blue));
            },),
          ],
        ),
      ),
    );
  }
}

class AssScaffold extends StatelessWidget {
  const AssScaffold({super.key, required this.leftWidget, required this.rightWidget});

  final Widget leftWidget, rightWidget;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: (width / 2) - 24, child: leftWidget),
          SizedBox(width: (width / 2) - 24, child: rightWidget),
        ],
      )
    );
  }
}
