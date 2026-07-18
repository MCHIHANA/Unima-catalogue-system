import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBpfe4NIB5pAAZdoaJzPRgwN7wgKBkFK7I',
    appId: '1:148666875246:web:c7bf1cce9f1965735f557f',
    messagingSenderId: '148666875246',
    projectId: 'unima-library-system',
    authDomain: 'unima-library-system.firebaseapp.com',
    storageBucket: 'unima-library-system.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpfe4NIB5pAAZdoaJzPRgwN7wgKBkFK7I',
    appId: '1:148666875246:android:c7bf1cce9f1965735f557f',
    messagingSenderId: '148666875246',
    projectId: 'unima-library-system',
    storageBucket: 'unima-library-system.firebasestorage.app',
  );
}
