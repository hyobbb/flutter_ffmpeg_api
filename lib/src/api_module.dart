import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'api_config.dart';
import 'utils.dart';

class FFmpegAPI {
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();
  final FlutterFFprobe _ffprobe = FlutterFFprobe();

  Future<EncodingResult> encodeVideo(EncodingOption option) async {
    var param = await _preset(option);
    if(param!=null) {
      var arguments = generateEncodingArgument(param);
      var result = 0;
      for(var arg in arguments) {
        result += await _ffmpeg.execute(arg);
      }
      if (result == 0) {
        return param.result;
      } else {
        throw 'Fail to encode video';
      }
    } else {
      throw 'Invalid input';
    }
  }

  void cancelTask() {
    _ffmpeg.cancel();
  }

  Future<EncodingParameter?> _preset(EncodingOption option) async {
    try {
      final info = await _ffprobe.getMediaInformation(option.inputPath);
      final duration = getDuration(info);
      return EncodingParameter(
        option: option,
        result: EncodingResult(
          path: generateOutputPath(option.inputPath, 'mp4', option.outputName),
          videoDuration: duration,
          thumbnailPath: option.generateThumbnail
              ? generateOutputPath(option.inputPath, 'png', option.thumbnailName)
              : null,
        ),
        needCodec: needCodec(info),
      );
    } catch (e, s) {
      return null;
    }
  }
}
