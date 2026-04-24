import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static const int targetWidth = 800;   // Ancho máximo para imagenes de eventos
  static const int targetHeight = 800;  // Alto máximo
  static const int quality = 85;        // Calidad 85%

  // Para imágenes de perfil (200x200)
  static const int profileWidth = 200;
  static const int profileHeight = 200;

  // Comprime y redimensiona una imagen para eventos
  static Future<File?> compressEventImage(File originalFile) async {
    return _compressImage(originalFile, targetWidth, targetHeight);
  }

  // Comprime y redimensiona una imagen de perfil
  static Future<File?> compressProfileImage(File originalFile) async {
    return _compressImage(originalFile, profileWidth, profileHeight);
  }

  static Future<File?> _compressImage(File originalFile, int width, int height) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: width,
        minHeight: height,
        rotate: 0,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint("Error comprimiendo imagen: $e");
      return originalFile; // fallback
    }
  }

  // Para Web (Uint8List)
  static Future<Uint8List?> compressBytes(Uint8List bytes, {int width = targetWidth, int height = targetHeight}) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: width,
        minHeight: height,
      );
      return result;
    } catch (e) {
      debugPrint("Error comprimiendo bytes: $e");
      return bytes;
    }
  }
}