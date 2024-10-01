import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:page_transition/page_transition.dart';
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
    _getAssociations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _getAssociations() async {
    pp('$mm ..................... getting associations ...');
    setState(() {
      busy = true;
    });
    try {
      associations = await api.getAssociations(true);
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
      ),
      body: SafeArea(
        child: Stack(
          children: [
            busy
                ? Center(
                    child: SizedBox(
                      width: 400,
                      height: 400,
                      child: Text(
                        'No Associations Yet',
                        style: myTextStyleMediumLarge(context, 32),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView.builder(
                        itemCount: associations.length,
                        itemBuilder: (_, index) {
                          var ass = associations[index];
                          return GestureDetector(
                            onTap: () {
                              _navigateToDashboard(ass);
                            },
                            child: Card(
                              elevation: 8,
                              child: ListTile(
                                leading: const Icon(Icons.ac_unit),
                                title: Text(ass.associationName!,
                                    style: myTextStyleMediumBold(context)),
                                subtitle: Text(
                                  ass.countryName == null
                                      ? ''
                                      : ass.countryName!,
                                  style: myTextStyleSmall(context),
                                ),
                              ),
                            ),
                          );
                        }),
                  )
          ],
        ),
      ),
    );
  }
}
