
import 'dart:ui';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import '../core/services/storage_services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Global {
  static late StorageServices storageServices;

  static Future init() async {
    await dotenv.load(fileName: ".env");


    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    storageServices = await StorageServices().init();

  }
}
