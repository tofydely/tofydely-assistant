import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_provider.dart';

class FunctionsService {
  static HttpsCallable getCallable(String functioName) {
    // FirebaseAuth auth = FirebaseAuth.instance;

    // await auth.currentUser!.getIdToken(true);

    // return FirebaseProvider.functions.httpsCallable(functioName);
    return _getCallable(functioName);
  }

  static HttpsCallable _getCallable(String functioName) {
    final instance = FirebaseFunctions.instanceFor(
      app: FirebaseProvider.firebaseApp,
      region: 'southamerica-east1',
    );

    return instance.httpsCallable(
      functioName,
    );
  }
}
