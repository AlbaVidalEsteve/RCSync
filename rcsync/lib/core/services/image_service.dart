import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// Top-level function required by compute() — runs in a separate isolate
Uint8List? _processImage(Map<String, dynamic> params) {
  final bytes    = params['bytes']    as Uint8List;
  final maxWidth = params['maxWidth'] as int;
  final maxHeight= params['maxHeight']as int;
  final quality  = params['quality']  as int;

  final image = img.decodeImage(bytes);
  if (image == null) return null;

  var ratio = (maxWidth  / image.width).clamp(0.0, 1.0);
  final rH  = (maxHeight / image.height).clamp(0.0, 1.0);
  if (rH < ratio) ratio = rH;

  final resized = img.copyResize(
    image,
    width:  (image.width  * ratio).toInt(),
    height: (image.height * ratio).toInt(),
    interpolation: img.Interpolation.linear,
  );
  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
}

class ImageService {
  static const int profileWidth  = 300;
  static const int profileHeight = 300;
  static const int qualityJpg    = 92;
  static const int eventWidth    = 1024;
  static const int eventHeight   = 1024;

  static Future<File?> compressProfileImage(File originalFile) =>
      _compress(originalFile, profileWidth, profileHeight);

  static Future<File?> compressEventImage(File originalFile) =>
      _compress(originalFile, eventWidth, eventHeight);

  static Future<File?> _compress(File originalFile, int maxWidth, int maxHeight) async {
    try {
      final originalBytes = await originalFile.readAsBytes();

      // CPU-intensive work runs in a background isolate, freeing the UI thread
      final compressedBytes = await compute(_processImage, {
        'bytes':     originalBytes,
        'maxWidth':  maxWidth,
        'maxHeight': maxHeight,
        'quality':   qualityJpg,
      });

      if (compressedBytes == null) return originalFile;

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await File(path).writeAsBytes(compressedBytes);
    } catch (e) {
      debugPrint('Error comprimiendo imagen: $e');
      return originalFile;
    }
  }
}
