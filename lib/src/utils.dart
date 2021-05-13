import 'package:ffmpeg_api/src/api_config.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_ffmpeg/stream_information.dart';
import 'package:path/path.dart';

bool needCodec(MediaInformation info) {
  var result = false;
  if (info.getStreams() != null) {
    List<StreamInformation> streams = info.getStreams()!;
    if (streams.isNotEmpty) {
      for (var stream in streams) {
        if (stream.getAllProperties()['codec_type'] == 'video') {
          if (stream.getAllProperties()['codec_name'] != 'h264') {
            result = true;
            break;
          }
        }
      }
    }
    return result;
  } else {
    return result;
  }
}

double getDuration(MediaInformation info) {
  final duration = double.tryParse(info.getMediaProperties()?['duration']);
  if (duration == null) {
    throw 'invalid duration';
  }
  return duration;
}

String generateOutputPath(String input, String extension, String? outputName) {
  var name = outputName ?? basename(withoutExtension(input)) + 'encoded';
  var pathList = input.split('/');
  return pathList.sublist(0, pathList.length - 1).join('/') +
      '/$name.$extension';
}

List<String> generateEncodingArgument(EncodingParameter parameter) {
  final option = parameter.option;
  final input = option.inputPath;
  final result = parameter.result;

  List<String> args = [];
  var arg = '-y -i $input ';

  if (option.overlays != null) {
    var overlays = option.overlays!;
    overlays.forEach((overlay) => arg += '-i ${overlay.path} ');
    arg += '-filter_complex ';
    if (overlays.length == 1) {
      var overlay = overlays.first;
      arg += '"[0:v][1:v]overlay=${overlay.offset.dx}:${overlay.offset.dy}" ';
    } else {
      for (var i = 0; i < overlays.length; i++) {
        var overlay = overlays[i];
        if (i == 0) {
          arg +=
              '"[$i][${i + 1}]overlay=${overlay.offset.dx}:${overlay.offset.dy}[v$i]';
        } else {
          arg +=
              '[v${i - 1}][${i + 1}]overlay=${overlay.offset.dx}:${overlay.offset.dy}[v$i]';
        }
        if (i != overlays.length - 1) {
          arg += ';';
        } else {
          arg += '" ';
        }
      }
      arg += '-map "[v${overlays.length - 1}]" ';
    }
  }

  if (option.includeAudio) {
    arg += '-an ';
  }

  final Map<Resolution, int> _res = {
    Resolution.High: 1080,
    Resolution.Medium: 720,
    Resolution.Low: 360,
  };

  if (parameter.needCodec) {
    arg +=
        '-c:v libx264 -crf ${option.crf} -s ${_res[option.resolution] ?? 720}x${((_res[option.resolution] ?? 720) * option.aspectRatio).toInt()} -preset superfast -max_muxing_queue_size 9999 ';
  } else {
    arg +=
        '-s ${_res[option.resolution] ?? 720}x${((_res[option.resolution] ?? 720) * option.aspectRatio).toInt()} -preset superfast -max_muxing_queue_size 9999 ';
  }

  args.add(arg + result.path);

  if (result.thumbnailPath != null) {
    args.add(
        '-y -i ${result.path} -vframes 1 -ss 1 ${result.thumbnailPath}');
  }
  return args;
}
