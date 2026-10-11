import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC90nKBZWrOPEPZKv2kEHI4DYYEAiki3DY',
    appId: '1:43386700569:android:68c3a57346a8fa91767b88',
    messagingSenderId: '43386700569',
    projectId: 'news-flutter-flask',
    storageBucket: 'news-flutter-flask.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC90nKBZWrOPEPZKv2kEHI4DYYEAiki3DY',
    appId: '1:43386700569:web:68c3a57346a8fa91767b88',
    messagingSenderId: '43386700569',
    projectId: 'news-flutter-flask',
    storageBucket: 'news-flutter-flask.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC90nKBZWrOPEPZKv2kEHI4DYYEAiki3DY',
    appId: '1:43386700569:ios:68c3a57346a8fa91767b88',
    messagingSenderId: '43386700569',
    projectId: 'news-flutter-flask',
    storageBucket: 'news-flutter-flask.firebasestorage.app',
  );
}
