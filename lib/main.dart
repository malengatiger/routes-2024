import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasie_transie_library/bloc/register_services.dart';
import 'package:kasie_transie_library/bloc/theme_bloc.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/theme.dart';
import 'package:kasie_transie_library/utils/prefs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:get_it/get_it.dart';
import 'firebase_options.dart';
import 'intro/kasie_intro.dart';
import 'intro/splash_page.dart';
late FirebaseApp firebaseApp;
fb.User? fbAuthedUser;
const mx = '🔵🔵🔵🔵 🍅 KasieTransie RouteBuilder : main  🍅 🔵🔵';
late ColorAndLocale colorAndLocale;
Future<void>
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pp('\n\n$mx DefaultFirebaseOptions.currentPlatform: '
      '\n\n${DefaultFirebaseOptions.currentPlatform.toString()}\n\n');
  //
  firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  pp('$mx'
      ' Firebase App has been initialized: 🅿️${firebaseApp.name}, checking for authed current user\n');

  fbAuthedUser = fb.FirebaseAuth.instance.currentUser;
  if (fbAuthedUser != null) {
    //TODO: REMOVE after test ....

    pp('$mx fbAuthUser: ${fbAuthedUser!.uid}');
    pp("$mx .... fbAuthUser is cool! ......  🥬🥬🥬 on to the party!! \n ${await fbAuthedUser?.getIdToken()}");
  } else {
    pp('$mx fbAuthUser: is null.  😈👿 Need to sign up or in. Authenticate the app!');
  }
  try {
    await RegisterServices.register();
    themeBloc = GetIt.instance<ThemeBloc>();
  } catch (e) {
    pp(e);
  }
  Prefs prefs = GetIt.instance<Prefs>();
  colorAndLocale = prefs.getColorAndLocale();

  me = prefs.getUser();
  if (me != null) {
    myPrettyJsonPrint(me!.toJson());
  }

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    PhoneAuthProvider(),
  ]);

  runApp(const ProviderScope(child: KasieTransieApp()));
}

temporarySignOut(Prefs prefs) async {
  //TODO: REMOVE after test ....
  prefs.removeUser();
 await  fb.FirebaseAuth.instance.signOut();
  pp('\n\n$mx  😈 👿cached User and Firebase creds cleaned up for testing. 🌶 REMOVE when done! 🌶 \n\n');

}
int themeIndex = 0;
lib.User? me;
late ThemeBloc themeBloc;
class KasieTransieApp extends ConsumerWidget {
  const KasieTransieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: themeBloc.localeAndThemeStream,
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
                primaryColor: Colors.teal,
                primaryColorDark: Colors.teal.shade900,
                primaryColorLight: Colors.teal.shade300,
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
