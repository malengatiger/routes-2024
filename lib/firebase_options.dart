// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAu_HffCDir26M7i7Oh6rWDaro-HXmVbaY',
    appId: '1:167113439249:web:81a80a8fefb89bfc39d9b0',
    messagingSenderId: '167113439249',
    projectId: 'kasie2024',
    authDomain: 'kasie2024.firebaseapp.com',
    storageBucket: 'kasie2024.appspot.com',
    measurementId: 'G-W3SG479DHL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDea0gLkBgTYw0ktxJNF6VrgXeoYztT8as',
    appId: '1:167113439249:android:70c62906d62d24a639d9b0',
    messagingSenderId: '167113439249',
    projectId: 'kasie2024',
    storageBucket: 'kasie2024.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtsSEYj6QgmlQRWuCVAwjirPYChXj0Srs',
    appId: '1:167113439249:ios:879ab2b596f19a4439d9b0',
    messagingSenderId: '167113439249',
    projectId: 'kasie2024',
    storageBucket: 'kasie2024.appspot.com',
    iosClientId: '167113439249-g5olf7grsp94je5q8lua9jl6aiqevkct.apps.googleusercontent.com',
    iosBundleId: 'com.boha.routes2024',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtsSEYj6QgmlQRWuCVAwjirPYChXj0Srs',
    appId: '1:167113439249:ios:4211b4650a988f4e39d9b0',
    messagingSenderId: '167113439249',
    projectId: 'kasie2024',
    storageBucket: 'kasie2024.appspot.com',
    iosClientId: '167113439249-ta4m70r1cdcfe05eb34pl7pujv03e8s0.apps.googleusercontent.com',
    iosBundleId: 'com.boha.routes2024.RunnerTests',
  );
}