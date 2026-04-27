import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageService {
  static const int profileWidth = 300;
  static const int profileHeight = 300;
  static const int qualityJpg = 92;
  static const int eventWidth = 1024;
  static const int eventHeight = 1024;

  static Future<File?> compressProfileImage(File originalFile) async {
    return _compress(originalFile, profileWidth, profileHeight);
  }

  static Future<File?> compressEventImage(File originalFile) async {
    return _compress(originalFile, eventWidth, eventHeight);
  }

  static Future<File?> _compress(File originalFile, int maxWidth, int maxHeight) async {
    try {
      final originalBytes = await originalFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) return originalFile;

      final newSize = _calculateSize(originalImage.width, originalImage.height, maxWidth, maxHeight);

      final resizedImage = img.copyResize(
        originalImage,
        width: newSize.width,
        height: newSize.height,
        interpolation: img.Interpolation.linear,
      );

      final compressedBytes = img.encodeJpg(resizedImage, quality: qualityJpg);

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(targetPath)..writeAsBytesSync(compressedBytes);

      return compressedFile;
    } catch (e) {
      debugPrint("Error comprimiendo imagen: $e");
      return originalFile;
    }
  }

  static _Size _calculateSize(int originalW, int originalH, int maxW, int maxH) {
    final ratioW = maxW / originalW;
    final ratioH = maxH / originalH;
    var ratio = ratioW < ratioH ? ratioW : ratioH;
    if (ratio > 1.0) ratio = 1.0;
    return _Size((originalW * ratio).toInt(), (originalH * ratio).toInt());
  }
}

class _Size {
  final int width;
  final int height;
  _Size(this.width, this.height);
}