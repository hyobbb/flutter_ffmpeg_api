import 'package:ffmpeg_api/ffmpeg_api.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';

class EncodingResultScreen extends StatefulWidget {
  static const String route = '/result';
  final EncodingResult result;

  const EncodingResultScreen(this.result);

  @override
  _EncodingResultScreenState createState() => _EncodingResultScreenState();
}

class _EncodingResultScreenState extends State<EncodingResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.arrow_drop_down_circle),
                title: const Text('Result'),
                subtitle: Text(
                  widget.result.videoDuration.toString(),
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.result.path,
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PlayVideo(widget.result.path)));
                    },
                    child: const Text('PLAY'),
                  ),
                ],
              ),
              if (widget.result.thumbnailPath != null)
                Image.file(File(widget.result.thumbnailPath!), height: 300,),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayVideo extends StatefulWidget {
  final String path;

  const PlayVideo(this.path, {Key? key}) : super(key: key);

  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  Future<VideoPlayerController> future() async {
    final controller = VideoPlayerController.file(File(widget.path));
    await controller.initialize();
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<VideoPlayerController>(
        future: future(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final controller = snapshot.data!
              ..play()
              ..setLooping(true);
            print(controller.value.aspectRatio);
            return SizedBox.expand(
              child: ClipRect(
                child: OverflowBox(
                  maxHeight: double.infinity,
                  maxWidth: double.infinity,
                  child: SizedBox(
                    width: 1,
                    height: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
