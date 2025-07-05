// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    // ▼▼▼ 1단계에서 열어 둔 Firebase 웹페이지의 값을 여기에 붙여넣으세요 ▼▼▼
    apiKey: "AIzaSyARlsgDRQkl_ZubwMfi5sftWn2r8Uo8ulc",
    // Firebase 페이지의 apiKey 값
    appId: "1:1075298230474:web:b4cdcb3cf539e90722d433",
    // Firebase 페이지의 appId 값
    messagingSenderId: "1075298230474", // Firebase 페이지의 messagingSenderId 값
    projectId: "blingbling-app",
    // Firebase 페이지의 projectId 값
    storageBucket:
        "blingbling-app.appspot.com", // Firebase 페이지의 storageBucket 값
    // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
  );
}
