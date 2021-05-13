import 'dart:async';
import 'package:ffmpeg_api/ffmpeg_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'encoding_test.dart';
import 'encoding_result.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        iconTheme: IconThemeData(color: Colors.white),
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: EncodingInput.route,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case EncodingInput.route:
            return MaterialPageRoute(builder: (_) => EncodingInput());
          case EncodingResultScreen.route:
            final result = settings.arguments as EncodingResult;
            return MaterialPageRoute(
                builder: (_) => EncodingResultScreen(result),
                settings: RouteSettings(name: settings.name));
          case EncodingTest.route:
            final input = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => EncodingTest(input),
                settings: RouteSettings(name: settings.name));
          default:
            return null;
        }
      },
    );
  }
}

class EncodingInput extends StatefulWidget {
  static const route = '/';

  @override
  _EncodingInputState createState() => _EncodingInputState();
}

class _EncodingInputState extends State<EncodingInput> {
  final ImagePicker _imagePicker = ImagePicker();
  String? path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encoding Test'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final path = await _takeVideo();
                    if(path!=null) {
                      Navigator.pushNamed(context, EncodingTest.route,
                          arguments: path);
                    }
                  },
                  child: Text('Take Video'),
                ),
                TextButton(
                  onPressed: () async {
                    final path = await _getVideo();
                    if(path!=null) {
                      Navigator.pushNamed(context, EncodingTest.route,
                          arguments: path);
                    }
                  },
                  child: Text('From Gallery'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _takeVideo() async {
    return await _imagePicker
        .getVideo(source: ImageSource.camera)
        .then((value) => value?.path);
  }

  Future<String?> _getVideo() async {
    return await _imagePicker
        .getVideo(source: ImageSource.gallery)
        .then((value) => value?.path);
  }
}
