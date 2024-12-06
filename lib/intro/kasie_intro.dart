import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/widgets/auth/email_auth_container.dart';
import 'package:kasie_transie_library/auth/phone_auth_signin2.dart';
import 'package:kasie_transie_library/bloc/data_api_dog.dart';
import 'package:kasie_transie_library/bloc/list_api_dog.dart';
import 'package:kasie_transie_library/data/data_schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routes_2024/intro/intro_carousel.dart';

import '../ui/assoc_routes.dart';
import '../ui/association_list.dart';
import '../ui/route_data_widget.dart';
import 'intro_page_one.dart';

class KasieIntro extends StatefulWidget {
  const KasieIntro({
    super.key,
  });

  @override
  KasieIntroState createState() => KasieIntroState();
}

class KasieIntroState extends State<KasieIntro>
    with SingleTickerProviderStateMixin {
  final mm = '🦠🦠 KasieIntro 🍎 🦠🦠';
  late AnimationController _controller;
  bool authed = false;
  int currentIndexPage = 0;
  final PageController _pageController = PageController();
  fb.FirebaseAuth firebaseAuth = fb.FirebaseAuth.instance;
  Prefs prefs = GetIt.instance<Prefs>();

  // mrm.User? user;
  String? signInFailed;
  User? user;
  List<Association> associations = [];
  ListApiDog dog = GetIt.instance<ListApiDog>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getAuthenticationStatus();
  }

  void _getAuthenticationStatus() async {
    pp('\n\n$mm _getAuthenticationStatus ....... '
        'check Kasie user');
    user = prefs.getUser();
    if (user == null) {
      pp('$mm NOT AUTHENTICATED! '
          '🌼🌼🌼 ... will clean house in case of authed but no user!!');
      authed = false;
      firebaseAuth.signOut();
      pp('$mm ... the device should be ready for sign in or registration');
      return;
    }
    pp('$mm '
        '🥬🥬🥬auth is DEFINITELY authenticated and OK');
    authed = true;

    if (user!.associationId! == 'ADMIN') {
      associations = await dog.getAssociations(false);
      if (associations.isEmpty) {
        if (mounted) {
          showErrorSnackBar(message: 'No Associations found', context: context);
        }
        return;
      }
      if (mounted) {
        NavigationUtils.navigateTo(
            context: context,
            widget: AssociationList(),
            transitionType: PageTransitionType.leftToRight);
      }
    } else {
      //normal association admin user ....
      var ass = prefs.getAssociation();
      if (ass != null) {
        NavigationUtils.navigateTo(
            context: context,
            widget: RouteDataWidget(association: ass,),
            transitionType: PageTransitionType.leftToRight);
      }
    }

    pp('$mm ... setting state, 💙authed = $authed  💙 ${user!.toJson()} 💙');
    setState(() {});
  }

  onSignInWithEmail() async {
    pp('$mm ...  onSignInWithEmail; ... starting ...');
    bool ok = await NavigationUtils.navigateTo(
        context: context,
        widget: const EmailAuthContainer(),
        transitionType: PageTransitionType.leftToRight);

    pp('$mm ...  onSignInWithEmail; ... back from sign in, result: $ok ...');
    if (ok) {
      onSuccessfulSignIn();
    } else {
      if (mounted) {
        showErrorToast(message: 'Sign in bad, Boss!', context: context);
      }
    }
  }

  onSignInWithPhone() async {
    pp('$mm ... onSignInWithPhone ....');
    DataApiDog dataApiDog = GetIt.instance<DataApiDog>();
    NavigationUtils.navigateTo(
        context: context,
        widget: PhoneAuthSignin(
            onGoodSignIn: () {
              onSuccessfulSignIn();
            },
            onSignInError: () {
              showSnackBar(message: "Sign In failed", context: context);
            }),
        transitionType: PageTransitionType.leftToRight);
  }

  onRegister() {
    pp('$mm ... onRegister ....');
  }

  void onSuccessfulSignIn() {
    var user = prefs.getUser();
    if (user != null) {
      if (user.associationId == 'ADMIN') {
        if (mounted) {
          showOKToast(message: 'Sign in good, Boss!',
              duration: Duration(seconds: 2),
              context: context);
        NavigationUtils.navigateTo(
              context: context,
              widget: const AssociationList(),
              transitionType: PageTransitionType.leftToRight);
        }
      } else {
        if (mounted) {
          showOKToast(message: 'Sign in good, Boss!',
              duration: Duration(seconds: 2),
              context: context);
          NavigationUtils.navigateTo(
              context: context,
              widget:
                  AssociationRoutes(user.associationId!, user.associationName!),
              transitionType: PageTransitionType.leftToRight);
        }
      }
    }
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<IntroPage> getItems(double width) {
    List<int> indexes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    indexes.shuffle();

    return [
      IntroPage(
        title: 'KasieTransie',
        assetPath: 'assets/images/${indexes[0]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'Associations',
        assetPath: 'assets/images/${indexes[1]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'People',
        assetPath: 'assets/images/${indexes[2]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'Marshals',
        assetPath: 'assets/images/${indexes[3]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'Thank You',
        assetPath: 'assets/images/${indexes[4]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'Thank You',
        assetPath: 'assets/images/${indexes[5]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'Thank You',
        assetPath: 'assets/images/${indexes[6]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'Thank You',
        assetPath: 'assets/images/${indexes[8]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'Thank You',
        assetPath: 'assets/images/${indexes[8]}.jpg',
        text: lorem,
        width: width,
      ),
      IntroPage(
        title: 'Thank You',
        assetPath: 'assets/images/${indexes[9]}.jpg',
        text: lorem,
        width: width,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'KasieTransie Association SignIn',
          style: myTextStyleLargeWithColor(context, color),
        ),
      ),
      body: Stack(
        children: [
          ScreenTypeLayout.builder(
            mobile: (_) {
              return BigCarousel(
                items: getItems(360.0),
                onPageChanged: (page) {
                  setState(() {
                    currentIndexPage = page;
                  });
                },
              );
            },
            tablet: (_) {
              return BigCarousel(
                items: getItems(double.infinity),
                onPageChanged: (page) {
                  setState(() {
                    currentIndexPage = page;
                  });
                },
              );
            },
            desktop: (_) {
              return BigCarousel(
                items: getItems(double.infinity),
                onPageChanged: (page) {
                  setState(() {
                    currentIndexPage = page;
                  });
                },
              );
            },
          ),
          Positioned(
            bottom: 2,
            left: 48,
            right: 40,
            child: SizedBox(
              width: 200,
              height: 48,
              child: Card(
                color: Colors.black12,
                shape: getRoundedBorder(radius: 8),
                child: DotsIndicator(
                  dotsCount: 10,
                  position: currentIndexPage,
                  decorator: const DotsDecorator(
                    colors: [
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                    ], // Inactive dot colors
                    activeColors: [
                      Colors.pink,
                      Colors.pink,
                      Colors.pink,
                      Colors.pink,
                      Colors.pink,
                      Colors.pink,
                      Colors.pink,
                      Colors.pink,
                      Colors.pink,
                      Colors.pink,
                    ], // Àctive dot colors
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: authed ? goodItems : signItems,
        onTap: (index) {
          if (user == null) {
            switch (index) {
              case 0:
                onSignInWithPhone();
                break;
              case 1:
                onSignInWithEmail();
            }
          } else {
            switch (index) {
              case 0:
                showToast(message: 'Under Construction', context: context);
                break;
              case 1:
                NavigationUtils.navigateTo(
                    context: context,
                    widget: RouteDataWidget(association: associations[0]),
                    transitionType: PageTransitionType.leftToRight);
            }
          }
        },
      ),
    ));
  }

  List<BottomNavigationBarItem> signItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.phone), label: 'Sign in with Phone'),
    BottomNavigationBarItem(
        icon: Icon(Icons.email), label: 'Sign in with Email'),
  ];
  List<BottomNavigationBarItem> goodItems = [
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    BottomNavigationBarItem(
        icon: Icon(Icons.check_box), label: 'Go To Dashboard'),
  ];
}
