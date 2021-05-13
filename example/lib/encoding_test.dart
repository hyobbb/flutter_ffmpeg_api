import 'package:ffmpeg_api/ffmpeg_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'encoding_result.dart';

class EncodingTest extends StatefulWidget {
  final String inputPath;
  static const String route = '/test';

  EncodingTest(this.inputPath);

  @override
  _EncodingTestState createState() => _EncodingTestState();
}

class _EncodingTestState extends State<EncodingTest> {
  final ImagePicker _imagePicker = ImagePicker();
  final FFmpegAPI _api = FFmpegAPI();
  String? outputName;
  bool generateThumbnail = true;
  String? thumbnailName;
  bool includeAudio = true;
  Resolution resolution = Resolution.Medium;
  List<OverlayParameter>? overlays;

  bool isRunning = false;

  String msg = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encoding Test'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _deleteFile();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  _stringMenu('output', (value) {
                    setState(() {
                      outputName = value;
                    });
                  }),
                  _dropDown(),
                  _toggleMenu('audio', includeAudio, (value) {
                    setState(() {
                      includeAudio = value;
                    });
                  }),
                  _toggleMenu('thumbnail', generateThumbnail, (value) {
                    setState(() {
                      generateThumbnail = value;
                    });
                  }),
                  _stringMenu('thumbnail name', (value) {
                    setState(() {
                      thumbnailName = value;
                    });
                  }),
                  TextButton(
                    onPressed: () async {
                      final path = await _getImage();
                      if (path != null) {
                        setState(() {
                          if (overlays == null) {
                            overlays = [OverlayParameter(path)];
                          } else {
                            overlays!.add(OverlayParameter(path));
                          }
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Choose Overlay Image'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      constraints:
                          BoxConstraints(minWidth: 300, minHeight: 100),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Text(msg),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isRunning)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.4),
                child: AbsorbPointer(
                  absorbing: isRunning,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _api.cancelTask();
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: () async {
          try {
            final result = await _api.encodeVideo(
              EncodingOption(
                inputPath: widget.inputPath,
                generateThumbnail: generateThumbnail,
                includeAudio: includeAudio,
                resolution: resolution,
                outputName: outputName,
                thumbnailName: thumbnailName,
                overlays: overlays,
              ),
            );
            Navigator.of(context).pushReplacementNamed(
                EncodingResultScreen.route,
                arguments: result);
          } catch (e, s) {
            setState(() {
              msg = e.toString();
            });
          }
        },
      ),
    );
  }

  void _deleteFile() {
    final file = File(widget.inputPath);
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }
  }

  Widget _stringMenu(
    String label,
    ValueChanged<String> onChanged, {
    TextInputType? type,
  }) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      onEditingComplete: () {
        primaryFocus?.unfocus();
      },
      keyboardType: type ?? TextInputType.name,
      onChanged: onChanged,
    );
  }

  Widget _toggleMenu(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Text(label),
        const SizedBox(
          width: 20,
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _dropDown() {
    return Row(
      children: [
        Text('Resolution'),
        const SizedBox(
          width: 20,
        ),
        DropdownButton<String>(
          value: res[resolution],
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? value) {
            print(value);
            if (value == 'low') {
              resolution = Resolution.Low;
            } else if (value == 'medium') {
              resolution = Resolution.Low;
            } else if (value == 'high') {
              resolution = Resolution.High;
            }
          },
          items: <String>[
            'low',
            'medium',
            'high',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<String?> _getImage() async {
    return await _imagePicker
        .getImage(source: ImageSource.gallery)
        .then((value) => value?.path);
  }

  final Map<Resolution, String> res = {
    Resolution.Low: 'low',
    Resolution.Medium: 'medium',
    Resolution.High: 'high',
  };
}
