import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:tofydely_assistant/function_service.dart';
import 'package:http/http.dart' as http;
import 'firebase_provider.dart';

class Util {
  static flaskBody(dynamic data) => jsonEncode({'data': data});

  static Future<dynamic> request(
    String functioName,
    Map<String, dynamic> data,
  ) async {
    if (!FirebaseProvider.useFirestoreEmulator) {
      final HttpsCallableResult result =
          await FunctionsService.getCallable(functioName).call(data);

      return result.data;
    }

    // Realizar la llamada a la API de recomendaciones con una solicitud POST
    final response = await http.post(
      Uri.parse(functioName),
      headers: {'Content-Type': 'application/json'},
      body: Util.flaskBody(data),
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON
      Map<String, dynamic> res = jsonDecode(response.body);

      return res['data'];
    } else {
      // Si la respuesta no es OK, lanzamos un error
      throw Exception('Failed to load recommendations');
    }
  }
}
