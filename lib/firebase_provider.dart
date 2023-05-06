import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:tofydely_assistant/firebase_options.dart';

class FirebaseProvider {
  static const region = 'southamerica-east1';
  static const emulatorHost = '192.168.100.63';
  static const flaskPort = 3000;
  static const bool useFirestoreEmulator = false;

  static final functions = FirebaseFunctions.instanceFor(
    app: Firebase.app(),
    region: FirebaseProvider.region,
  );

  static const int numRecomendations = 5;

  static String get flaskUrl => 'http://$emulatorHost:$flaskPort';

  static FirebaseApp? firebaseApp;

  Future<FirebaseApp> initialize() async {
    final init = await Firebase.initializeApp(options: currentPlatform);

    if (useFirestoreEmulator) {
      debugPrint('Using Firestore emulator');
      functions.useFunctionsEmulator(emulatorHost, 5001);
    }

    firebaseApp = init;

    return init;
  }

  static FirebaseOptions get currentPlatform {
    return DefaultFirebaseOptions.currentPlatform;
  }
}
