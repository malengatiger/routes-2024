import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_library/bloc/theme_bloc.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/emojis.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/theme.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:get_it/get_it.dart';
import 'package:routes_2024/library/register.dart';
import 'firebase_options.dart';
import 'intro/kasie_intro.dart';
import 'intro/splash_page.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

import 'library/firebase_messaging_handler.dart';

late FirebaseApp firebaseApp;
fb.User? fbAuthedUser;
const mx = '🔵🔵🔵🔵 🍅 KasieTransie Association Administrator : main  🍅 🔵🔵';
late ColorAndLocale colorAndLocale;
const bucket = 'gs://kasie-transie-4.appspot.com';
Prefs prefs = GetIt.instance<Prefs>();
FirebaseMessagingHandler firebaseMessagingHandler = GetIt.instance<FirebaseMessagingHandler>();

Future<void> main() async {
  pp('\n\n\n$mx .... app starting, right at the top!\n\n');
  WidgetsFlutterBinding.ensureInitialized();
  pp('\n\n$mx DefaultFirebaseOptions.currentPlatform: '
      '\n\n${DefaultFirebaseOptions.currentPlatform.toString()}\n\n');
  //
  // SET PERSISTENCE *BEFORE* INITIALIZING FIREBASE

  firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  pp('$mx'
      ' Firebase App has been initialized: 🅿️${firebaseApp.name}, checking for authed current user\n');

  fbAuthedUser = fb.FirebaseAuth.instance.currentUser;
  if (fbAuthedUser != null) {
    pp('$mx fbAuthUser: ${fbAuthedUser!.uid}');
    pp("$mx .... fbAuthUser is cool! ......  🥬🥬🥬 on to the party!! \n ${await fbAuthedUser?.getIdToken()}");
  } else {
    pp('$mx fbAuthUser: is null.  😈👿 Need to sign up or in. Authenticate the app!');
  }
  try {
    final fbs = storage.FirebaseStorage.instanceFor(
        app: firebaseApp,
        bucket: bucket);
    pp('$mx 🌸🌸 FirebaseStorage: 🍎🍎 ${fbs.toString()}');
    await RegisterServices.register(firebaseStorage: fbs);
    kasieThemeManager = GetIt.instance<KasieThemeManager>();
  } catch (e,s) {
    pp('$e $s');
  }
  String? token;
  if (fbAuthedUser != null) {
    token = await fbAuthedUser!.getIdToken();
  }
  if (token != null) {
    pp('$mx 🌸🌸 Firebase id token 🍎🍎\n\n $token\n\n');
  } else {
    pp('$mx getAuthToken has fallen down. ${E.redDot}${E.redDot}${E.redDot}  '
        ' Firebase id token not found 🍎');
  }

  firebaseMessagingHandler.initialize();
  colorAndLocale = prefs.getColorAndLocale();

  me = prefs.getUser();
  if (me != null) {
    myPrettyJsonPrint(me!.toJson());
  }

  runApp(const KasieTransieApp());
}

int themeIndex = 0;
lib.User? me;
late KasieThemeManager kasieThemeManager;

class KasieTransieApp extends StatelessWidget {
  const KasieTransieApp({super.key});

  @override
  Widget build(BuildContext context) {
    kasieThemeManager = GetIt.instance<KasieThemeManager>();
    return StreamBuilder(
        stream: kasieThemeManager.localeAndThemeStream,
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            pp(' 🔵 🔵 🔵'
                'build: theme index has been set to ${snapshot.data!.themeIndex}'
                '  and locale == ${snapshot.data!.locale.toString()}');
            themeIndex = snapshot.data!.themeIndex;
          } else {
            themeIndex = colorAndLocale.themeIndex;
          }

          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'KasieTransie',
              theme: ThemeData(
                colorScheme: MaterialTheme.lightScheme(),
                useMaterial3: true,
                primaryColor: Colors.indigo,
                primaryColorDark: Colors.indigo.shade900,
                primaryColorLight: Colors.indigo.shade300,
              ),

              // theme: themeBloc.getTheme(themeIndex).darkTheme,
              // darkTheme: themeBloc.getTheme(themeIndex).darkTheme,
              // themeMode: ThemeMode.system,
              home: AnimatedSplashScreen(
                splash: const SplashWidget(),
                animationDuration: const Duration(milliseconds: 2000),
                curve: Curves.easeInCirc,
                splashIconSize: 160.0,
                nextScreen: const KasieIntro(),
                splashTransition: SplashTransition.fadeTransition,
                pageTransitionType: PageTransitionType.leftToRight,
                backgroundColor: Colors.teal.shade900,
              ));
        });
  }
}
