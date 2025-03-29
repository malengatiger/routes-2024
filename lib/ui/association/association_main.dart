import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/ui/association/association_edit.dart';
import 'package:routes_2024/ui/association/example_file_widget.dart';
import 'package:routes_2024/ui/association/routes_edit.dart';
import 'package:routes_2024/ui/association/taxi_activity.dart';
import 'package:routes_2024/ui/association/the_demo.dart';
import 'package:routes_2024/ui/association/ticket_maker.dart';
import 'package:routes_2024/ui/association/users_edit.dart';
import 'package:routes_2024/ui/association/vehicles_edit.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../route_data_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as web;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssociationMain extends StatefulWidget {
  const AssociationMain({super.key, this.association, this.isAdmin});

  final Association? association;
  final bool? isAdmin;

  @override
  AssociationMainState createState() => AssociationMainState();
}

class AssociationMainState extends State<AssociationMain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '️💛️💛️💛 AssociationMain ️💛';

  Prefs prefs = GetIt.instance<Prefs>();

  DataApiDog dataApiDog = GetIt.instance<DataApiDog>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setFirebaseMessaging();
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
        if (widget.association != null) {
          _navigateToRoutes(widget.association!);
        }
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
      case 7:
        NavigationUtils.navigateTo(
            context: context,
            widget: TheDemo(
              association: widget.association!,
              isDemo: widget.isAdmin!,
            ),
            transitionType: PageTransitionType.leftToRight);
        break;
      case 8:
        NavigationUtils.navigateTo(
            context: context,
            widget: TheDemo(
              association: widget.association!,
              isDemo: widget.isAdmin!,
            ),
            transitionType: PageTransitionType.leftToRight);
        break;
      case 6:
        NavigationUtils.navigateTo(
            context: context,
            widget: AssociationTaxiActivity(
              association: widget.association!,
            ),
            transitionType: PageTransitionType.leftToRight);
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

  _navigateToRoutes(Association ass) async {
    NavigationUtils.navigateTo(
        context: context,
        widget: RouteDataWidget(
          association: ass,
        ),
        transitionType: PageTransitionType.leftToRight);
  }

  String? token;

  _setFirebaseMessaging() async {
    pp('$mm ... _setFirebaseMessaging ...!');
    var m = web.FirebaseMessaging.instance;
    token = await m.getToken();
    final fcmToken = await web.FirebaseMessaging.instance.getToken(
        vapidKey:
            "BLksUVvP3uZvFJSOtJMdyHdymY08HtfuEPLTlr1Q4O__Uo9vzbC-reM924TZ3O_zNDos20cIOPKf6vqSx-6YO4A");
    token = fcmToken;
    debugPrint('$mm  ... Firebase token 1: $token ....');
    debugPrint('$mm  ... Firebase token 2: $fcmToken ....');

    debugPrint('$mm  ... Firebase requestPermission ....');
    var perm = await m.requestPermission();

    debugPrint('$mm  ... Firebase registerBackgroundMessageHandler ....');
    dataApiDog.init();
    if (prefs.getAssociation() != null) {
      var userId = fb.FirebaseAuth.instance.currentUser!.uid;
      debugPrint(
        '\n\n\n$mm  ... Firebase Token: $token send to backend .... 😡 userId: $userId',
      );
      var res = await dataApiDog.addAssociationToken(
        token: token!,
        userId: userId,
        associationId: prefs.getAssociation()!.associationId!,
      );

      debugPrint('🔵🔵🔵🔵 AssociationToken: $res');
      _fcmTokenStream();
    }
  }

  Future<web.RemoteMessage> handler(web.RemoteMessage remoteMessage) async {
    pp('\n\n\n$mm message received: $remoteMessage\n\n\n');
    // messageService.addRemoteMessage(remoteMessage);
    return remoteMessage;
  }

  web.FirebaseMessaging messaging = web.FirebaseMessaging.instance;
  String? _token;
  late Stream<String> _tokenStream;

  void _fcmTokenStream() {
    pp('\n\n$mm _fcmTokenStream ...............');
    messaging
        .getToken(
            vapidKey:
                'BLksUVvP3uZvFJSOtJMdyHdymY08HtfuEPLTlr1Q4O__Uo9vzbC-reM924TZ3O_zNDos20cIOPKf6vqSx-6YO4A')
        .then(setToken)
        .catchError((e) {
      pp('$mm 😈😈😈😈😈Error getting FCM token: $e');
      return e;
    });
    _tokenStream = messaging.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  Future<void> setToken(String? value) async {
    pp('$mm 🔵🔵🔵🔵 .... setToken: $value');
    token = value;
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
                      width: (width * 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 8,
                          child: KasieNavigation(
                            width: (width * .3),
                            onTapped: (index) {
                              pp('$mm nav drawer header tapped: $index');
                              this.index = index;
                              getWidget();
                            },
                            isAdmin: widget.isAdmin!,
                          ),
                        ),
                      ),
                    ),
                    gapW32,
                    SizedBox(
                      width: (width * 0.65),
                      child: currentWidget == null
                          ? Container(color: Colors.teal)
                          : Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: currentWidget!,
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
      {super.key,
      required this.width,
      required this.onTapped,
      required this.isAdmin});

  final double width;
  final Function(int) onTapped;
  final bool isAdmin;

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
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                  gapW32,
                  Text(
                    'Manage Staff',
                    style: myTextStyleMediumLarge(context, 18),
                  ),
                ],
              )),
          gapH32,
          GestureDetector(
              onTap: () {
                onTapped(1);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.car_crash_rounded,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                  gapW32,
                  Text(
                    'Manage Vehicles',
                    style: myTextStyleMediumLarge(context, 18),
                  ),
                ],
              )),
          gapH32,
          GestureDetector(
              onTap: () {
                onTapped(3);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.roundabout_right,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                  gapW32,
                  Text(
                    'Manage Routes',
                    style: myTextStyleMediumLarge(context, 18),
                  ),
                ],
              )),
          gapH32,
          GestureDetector(
              onTap: () {
                onTapped(4);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.airplane_ticket,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                  gapW32,
                  Text(
                    'Ticket Maker',
                    style: myTextStyleMediumLarge(context, 18),
                  ),
                ],
              )),
          gapH32,
          gapH32,
          GestureDetector(
              onTap: () {
                onTapped(7);
              },
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.car,
                    size: 36,
                    color: Colors.red,
                  ),
                  gapW32,
                  Text(
                    'Association Taxi Activity',
                    style: myTextStyleBold(fontSize: 28),
                  ),
                ],
              )),
          gapH32,
          GestureDetector(
              onTap: () {
                onTapped(6);
              },
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.taxi,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                  gapW32,
                  Text(
                    'Taxi Activity',
                    style: myTextStyleBold(fontSize: 28),
                  ),
                ],
              )),
          gapH32,
          isAdmin
              ? GestureDetector(
                  onTap: () {
                    onTapped(8);
                  },
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.desktop,
                        size: 36,
                        color: Theme.of(context).primaryColor,
                      ),
                      gapW32,
                      Text(
                        'Demo',
                        style: myTextStyleBold(fontSize: 20),
                      ),
                    ],
                  ))
              : gapW32,
          gapH32,
          gapH32,
          GestureDetector(
              onTap: () {
                onTapped(5);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.folder_copy_rounded,
                    size: 24,
                  ),
                  gapW32,
                  Text(
                    'Example Files',
                    style: myTextStyleMediumLarge(context, 14),
                  ),
                ],
              )),
          gapH32,
        ],
      ),
    );
  }
}
