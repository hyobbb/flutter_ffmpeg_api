import 'package:ffmpeg_api/src/api_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ffmpeg_api/ffmpeg_api.dart';

void main() {
  final encoder = FFmpegAPI();
  test('result test', () async {
    final option = EncodingOption(inputPath: 'test_path');
    var result;
    try {
      result = await encoder.encodeVideo(option);
    } catch (e,s) {
      result = e.toString();
    }
    expect(result, 'Invalid input');
  });
}
