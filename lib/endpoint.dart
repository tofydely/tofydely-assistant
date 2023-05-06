// ignore_for_file: constant_identifier_names

import 'package:tofydely_assistant/firebase_provider.dart';

enum Endpoint {
  ASSISTANT_GET_RESPONSE,
  ASSISTANT_GET_VOICES;

  String get value {
    enpoint(String endpoint) =>
        '${FirebaseProvider.useFirestoreEmulator ? '${FirebaseProvider.flaskUrl}/' : ''}$endpoint';

    switch (this) {
      case Endpoint.ASSISTANT_GET_RESPONSE:
        return enpoint('assistant_get_response');
      case Endpoint.ASSISTANT_GET_VOICES:
        return enpoint('assistant_get_voices');
    }
  }
}
