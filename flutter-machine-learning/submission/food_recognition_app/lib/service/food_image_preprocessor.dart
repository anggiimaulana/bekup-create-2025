import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../utils/image_utils.dart';

/// Utility class untuk memastikan preprocessing yang konsisten
/// antara kamera dan galeri
class FoodImagePreprocessor {
  static const int MODEL_INPUT_WIDTH = 224;
  static const int MODEL_INPUT_HEIGHT = 224;
  static const int MODEL_INPUT_CHANNELS = 3;

  /// Preprocess CameraImage untuk real-time inference (dari kamera)
  static List<List<List<num>>> preprocessCameraImage(
    CameraImage cameraImage,
    List<int> inputShape,
  ) {
    try {
      img.Image? image = ImageUtils.convertCameraImage(cameraImage);
      if (image == null) {
        throw Exception('Failed to convert camera image');
      }

      // Resize sesuai input shape model
      img.Image imageInput = img.copyResize(
        image,
        width: inputShape[1], 
        height: inputShape[2],
        interpolation: img.Interpolation.linear,
      );

      // Rotasi untuk Android
      if (Platform.isAndroid) {
        imageInput = img.copyRotate(imageInput, angle: 90);
      }

      // Gunakan RAW pixel values (0-255) seperti versi yang bekerja
      final imageMatrix = List.generate(
        imageInput.height,
        (y) => List.generate(imageInput.width, (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        }),
      );

      return imageMatrix;
    } catch (e) {
      rethrow;
    }
  }

  /// Preprocess File Image untuk galeri inference
  static List<List<List<num>>> preprocessFileImage(
    img.Image image, {
    int? targetWidth,
    int? targetHeight,
  }) {
    try {
      final width = targetWidth ?? MODEL_INPUT_WIDTH;
      final height = targetHeight ?? MODEL_INPUT_HEIGHT;

      // Resize ke dimensi yang sama dengan preprocessing kamera
      final resizedImage = img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: img.Interpolation.linear,
      );

      // Pastikan format RGB
      final rgbImage = resizedImage.convert(numChannels: MODEL_INPUT_CHANNELS);

      // Gunakan struktur data yang PERSIS SAMA dengan kamera
      final imageMatrix = List.generate(
        rgbImage.height,
        (y) => List.generate(rgbImage.width, (x) {
          final pixel = rgbImage.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b]; 
        }),
      );

      return imageMatrix;
    } catch (e) {
      rethrow;
    }
  }

  /// Load image dari file dan preprocess
  static Future<List<List<List<num>>>?> loadAndPreprocessFile(
    File imageFile, {
    int? targetWidth,
    int? targetHeight,
  }) async {
    try {
      // Validasi file
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      // Load image
      final image = await img.decodeImageFile(imageFile.path);
      if (image == null) {
        throw Exception('Failed to decode image file');
      }

      // Preprocess dengan metode yang sama
      return preprocessFileImage(
        image,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
    } catch (e) {
      return null;
    }
  }

  /// Validasi apakah imageMatrix sudah benar
  static bool validateImageMatrix(List<List<List<num>>> imageMatrix) {
    try {
      if (imageMatrix.isEmpty) return false;
      if (imageMatrix[0].isEmpty) return false;
      if (imageMatrix[0][0].isEmpty) return false;

      final height = imageMatrix.length;
      final width = imageMatrix[0].length;
      final channels = imageMatrix[0][0].length;

      // Validasi dimensi standar model food recognition
      if (height != MODEL_INPUT_HEIGHT ||
          width != MODEL_INPUT_WIDTH ||
          channels != MODEL_INPUT_CHANNELS) {
        log(
          'WARNING: Matrix dimensions differ from expected ${MODEL_INPUT_HEIGHT}x${MODEL_INPUT_WIDTH}x${MODEL_INPUT_CHANNELS}',
        );
      }

      // Validasi range pixel values (harus 0-255 untuk RAW values)
      for (int y = 0; y < height && y < 10; y++) {
        // Sample check first 10 rows
        for (int x = 0; x < width && x < 10; x++) {
          // Sample check first 10 columns
          for (int c = 0; c < channels; c++) {
            final value = imageMatrix[y][x][c];
            if (value < 0 || value > 255) {
              return false;
            }
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get info dari imageMatrix
  static Map<String, dynamic> getMatrixInfo(List<List<List<num>>> imageMatrix) {
    if (imageMatrix.isEmpty) {
      return {'error': 'Empty matrix'};
    }

    final height = imageMatrix.length;
    final width = imageMatrix.isEmpty ? 0 : imageMatrix[0].length;
    final channels = imageMatrix.isEmpty || imageMatrix[0].isEmpty
        ? 0
        : imageMatrix[0][0].length;

    // Sample pixel values
    List<num> samplePixels = [];
    if (height > 0 && width > 0 && channels > 0) {
      samplePixels = List.from(imageMatrix[0][0]);
    }

    return {
      'dimensions': '${height}x${width}x${channels}',
      'height': height,
      'width': width,
      'channels': channels,
      'samplePixel': samplePixels,
      'isValidSize':
          height == MODEL_INPUT_HEIGHT &&
          width == MODEL_INPUT_WIDTH &&
          channels == MODEL_INPUT_CHANNELS,
    };
  }
}
