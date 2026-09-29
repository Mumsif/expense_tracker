
// ignore_for_file: type=lint
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
    apiKey: 'AIza' 'SyC_64ZJjorI_uc55gKa9tErFEMwlssj2eQ',
    appId: '1:632967401720:web:32729c25d8af10c3daeb0d',
    messagingSenderId: '632967401720',
    projectId: 'expense-tracker-b7827',
    authDomain: 'expense-tracker-b7827.firebaseapp.com',
    storageBucket: 'expense-tracker-b7827.firebasestorage.app',
    measurementId: 'G-7LDT1YZ46D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIza' 'SyBrQ-hPZ9zNW6oCxOEWeE2zcxi68p8jRHY',
    appId: '1:632967401720:android:61ff4b2a1ffbf4d3daeb0d',
    messagingSenderId: '632967401720',
    projectId: 'expense-tracker-b7827',
    authDomain: 'expense-tracker-b7827.firebaseapp.com',
    storageBucket: 'expense-tracker-b7827.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIza' 'SyDIS2p8ix5XUQ-c_N3I6GCHRmTSQ6DakkE',
    appId: '1:632967401720:ios:9d198372d208f06bdaeb0d',
    messagingSenderId: '632967401720',
    projectId: 'expense-tracker-b7827',
    storageBucket: 'expense-tracker-b7827.firebasestorage.app',
    iosBundleId: 'com.example.expenseTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIza' 'SyDIS2p8ix5XUQ-c_N3I6GCHRmTSQ6DakkE',
    appId: '1:632967401720:ios:9d198372d208f06bdaeb0d',
    messagingSenderId: '632967401720',
    projectId: 'expense-tracker-b7827',
    storageBucket: 'expense-tracker-b7827.firebasestorage.app',
    iosBundleId: 'com.example.expenseTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIza' 'SyC_64ZJjorI_uc55gKa9tErFEMwlssj2eQ',
    appId: '1:632967401720:web:731e1d72e1fbdfdcdaeb0d',
    messagingSenderId: '632967401720',
    projectId: 'expense-tracker-b7827',
    authDomain: 'expense-tracker-b7827.firebaseapp.com',
    storageBucket: 'expense-tracker-b7827.firebasestorage.app',
    measurementId: 'G-N4LS9DB231',
  );
}
