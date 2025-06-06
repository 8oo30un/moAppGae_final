// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDj3Kv6KyzTfNw7bPCPmBTlul8X-a6NEIE',
    appId: '1:1025617527366:web:87a6f96be42872f69fc047',
    messagingSenderId: '1025617527366',
    projectId: 'moappgaefinaltest',
    authDomain: 'moappgaefinaltest.firebaseapp.com',
    storageBucket: 'moappgaefinaltest.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArctR-qwM1AEFIw7s5PbFow5P0TTyQ1Ws',
    appId: '1:1025617527366:android:7a0b9e04482b04fc9fc047',
    messagingSenderId: '1025617527366',
    projectId: 'moappgaefinaltest',
    storageBucket: 'moappgaefinaltest.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbtdRaESjHqfYipW3gXZtgDDW0hp0idGw',
    appId: '1:1025617527366:ios:6c69b8c2813657909fc047',
    messagingSenderId: '1025617527366',
    projectId: 'moappgaefinaltest',
    storageBucket: 'moappgaefinaltest.firebasestorage.app',
    iosClientId: '1025617527366-4hkbab55rupeco1nd8lpf52hgg35a67c.apps.googleusercontent.com',
    iosBundleId: 'com.example.mdc100Series',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCbtdRaESjHqfYipW3gXZtgDDW0hp0idGw',
    appId: '1:1025617527366:ios:6c69b8c2813657909fc047',
    messagingSenderId: '1025617527366',
    projectId: 'moappgaefinaltest',
    storageBucket: 'moappgaefinaltest.firebasestorage.app',
    iosClientId: '1025617527366-4hkbab55rupeco1nd8lpf52hgg35a67c.apps.googleusercontent.com',
    iosBundleId: 'com.example.mdc100Series',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDj3Kv6KyzTfNw7bPCPmBTlul8X-a6NEIE',
    appId: '1:1025617527366:web:05a31055d06a680d9fc047',
    messagingSenderId: '1025617527366',
    projectId: 'moappgaefinaltest',
    authDomain: 'moappgaefinaltest.firebaseapp.com',
    storageBucket: 'moappgaefinaltest.firebasestorage.app',
  );
}
