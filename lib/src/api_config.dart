import 'dart:ui';

enum Resolution {
  Low, //360p
  Medium, //720p
  High, //1080p
}


class OverlayParameter {
  final String path;
  final Offset offset;

  const OverlayParameter(
    this.path, {
    this.offset = const Offset(0, 0),
  });
}

class EncodingOption {
  final String inputPath;
  final String? outputName;

  final bool generateThumbnail;
  final String? thumbnailName;

  final bool includeAudio;
  final int crf;
  final Resolution resolution;
  final double aspectRatio;

  final List<OverlayParameter>? overlays;

  const EncodingOption({
    required this.inputPath,
    this.generateThumbnail = true,
    this.includeAudio = true,
    this.crf = 23,
    this.resolution = Resolution.Medium,
    this.aspectRatio = 16 / 9,
    this.outputName,
    this.thumbnailName,
    this.overlays,
  });
}

class EncodingResult {
  final String path;
  final String? thumbnailPath;
  final double videoDuration;

  const EncodingResult({
    required this.path,
    required this.videoDuration,
    this.thumbnailPath,
  });
}

class EncodingParameter {
  final EncodingOption option;
  final EncodingResult result;
  final bool needCodec;

  const EncodingParameter({
    required this.option,
    required this.result,
    required this.needCodec,
  });
}