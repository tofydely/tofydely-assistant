import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:tofydely_assistant/endpoint.dart';
import 'package:tofydely_assistant/firebase_provider.dart';
import 'package:tofydely_assistant/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await FirebaseProvider().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tofy Dely's Assistant",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Tofy Dely's Assistant"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Voice> voces = [];

  String? _vozSeleccionada;

  final TextEditingController _role = TextEditingController();
  final TextEditingController _prompt = TextEditingController();

  @override
  void initState() {
    super.initState();

    _role.text =
        'Eres un asistente virtual de Tofy Dely. Escribe tus respuestas en menos de 10 palabras.';
    _prompt.text = 'Cómo te llamas?';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _obtenerVoces();
    });
  }

  // add method obtenerVoces() before build()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(hintText: 'Rol'),
            maxLines: null,
            controller: _role,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: DropdownButton<String>(
              value: _vozSeleccionada,
              hint: const Text('Selecciona una voz'),
              onChanged: (String? newValue) {
                setState(() {
                  _vozSeleccionada = newValue;
                });
              },
              items: voces.map<DropdownMenuItem<String>>((Voice value) {
                return DropdownMenuItem<String>(
                  value: value.id,
                  child: Text(value.name),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Escribe un mensaje'),
            maxLines: null,
            controller: _prompt,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                _enviarMensaje();
              },
              child: const Text('Enviar'),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _obtenerVoces() async {
    final res = await Util.request(
      Endpoint.ASSISTANT_GET_VOICES.value,
      {
        'user_id': 'aqui_va_el_id_del_usuario',
      },
    );

    print((e ?? '-> error nulo').toString());

    setState(() {
      voces = Voice.fromJsonList(res);
    });
  }

  Future<dynamic> _enviarMensaje() async {
    if (_vozSeleccionada == null ||
        _prompt.text.isEmpty ||
        _role.text.isEmpty) {
      return;
    }

    await Util.request(
      Endpoint.ASSISTANT_GET_RESPONSE.value,
      {
        'user_id': 'aqui_va_el_id_del_usuario',
        "prompt": _prompt.text,
        "voice_id": _vozSeleccionada,
        "role": _role.text
      },
    ).then((res) {
      print("Respondió...");

      _playBase64Mp3(res);
    }).catchError((e) {
      print((e ?? '-> error nulo').toString());
    });
  }
}

class Voice {
  final String id;
  final String name;

  Voice({required this.id, required this.name});

  // from json
  factory Voice.fromJson(Map<String, dynamic> json) {
    return Voice(
      id: json['voice_id'],
      name: json['name'],
    );
  }

  // from list of json
  static List<Voice> fromJsonList(List<dynamic> jsonList) {
    final List<Voice> voces = [];

    for (final voz in jsonList) {
      voces.add(Voice.fromJson(voz));
    }

    return voces;
  }
}

Future<File> _decodeAndSaveBase64Mp3(String base64String) async {
  // Decodifica el String base64
  Uint8List mp3Bytes = base64Decode(base64String);

  // Obtiene el directorio temporal del dispositivo
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;

  // Guarda el archivo mp3 en el directorio temporal
  File mp3File = File('$tempPath/output.mp3');
  await mp3File.writeAsBytes(mp3Bytes);

  return mp3File;
}

void _playBase64Mp3(String base64String) async {
  // Convierte el String base64 a un archivo mp3 si no está en la plataforma web
  String audioUrl;
  if (kIsWeb) {
    // Utiliza el String base64 directamente como URL en la plataforma web
    audioUrl = 'data:audio/mp3;base64,$base64String';
  } else {
    File mp3File = await _decodeAndSaveBase64Mp3(base64String);
    audioUrl = mp3File.path;
  }

  // Crea una instancia de AudioPlayer
  AudioPlayer audioPlayer = AudioPlayer();

  // Establece la URL del archivo de audio
  await audioPlayer.setUrl(audioUrl);

  // Reproduce el archivo mp3
  await audioPlayer.play();
}
