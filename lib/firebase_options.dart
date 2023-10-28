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
    apiKey: 'AIzaSyD0GoZt0P15cmSuwKFZIQWy18ACmWaZEdA',
    appId: '1:218373526971:web:930adc1f6cf16dea95209e',
    messagingSenderId: '218373526971',
    projectId: 'stairbattlecounter',
    authDomain: 'stairbattlecounter.firebaseapp.com',
    storageBucket: 'stairbattlecounter.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA18X7YjvTHHKrxD1myAQ635EFY5nCh1oI',
    appId: '1:218373526971:android:40277b1cc689a41895209e',
    messagingSenderId: '218373526971',
    projectId: 'stairbattlecounter',
    storageBucket: 'stairbattlecounter.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDtvxo-4huD_iiw474atJtS5KXOB14vkRU',
    appId: '1:218373526971:ios:604fffd50ede7c3995209e',
    messagingSenderId: '218373526971',
    projectId: 'stairbattlecounter',
    storageBucket: 'stairbattlecounter.appspot.com',
    iosClientId: '218373526971-d2ctfro4173pediknptuavc68e51i9pi.apps.googleusercontent.com',
    iosBundleId: 'com.example.stairBattleCounter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDtvxo-4huD_iiw474atJtS5KXOB14vkRU',
    appId: '1:218373526971:ios:5745b835f5e1c21295209e',
    messagingSenderId: '218373526971',
    projectId: 'stairbattlecounter',
    storageBucket: 'stairbattlecounter.appspot.com',
    iosClientId: '218373526971-i0o5uvnm3kh096cpt6csh2mt1n9v6lv8.apps.googleusercontent.com',
    iosBundleId: 'com.example.stairBattleCounter.RunnerTests',
  );
}