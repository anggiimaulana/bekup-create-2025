import 'dart:io';
import 'dart:typed_data';
import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  /// Convert CameraImage to Image object
  static img.Image? convertCameraImage(CameraImage cameraImage) {
    try {
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToImage(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.nv21) {
        return _convertNV21ToImage(cameraImage);
      }
    } catch (e) {
      log('Error converting camera image: $e');
    }
    return null;
  }

  /// Convert YUV420 format to Image
  static img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;

    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex =
            uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * cameraImage.planes[0].bytesPerRow + x;

        final yp = cameraImage.planes[0].bytes[index];
        final up = cameraImage.planes[1].bytes[uvIndex];
        final vp = cameraImage.planes[2].bytes[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    return image;
  }

  /// Convert BGRA8888 format to Image
  static img.Image _convertBGRA8888ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final Uint8List bytes = cameraImage.planes[0].bytes;

    return img.Image.fromBytes(
      width: width,
      height: height,
      bytes: bytes.buffer,
      format: img.Format.uint8,
      numChannels: 4,
    );
  }

  /// Convert NV21 format to Image
  static img.Image _convertNV21ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final Uint8List yuv420sp = cameraImage.planes[0].bytes;

    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = width * height + (y ~/ 2) * width + (x & ~1);

        final int Y = yuv420sp[yIndex] & 0xFF;
        final int V = yuv420sp[uvIndex] & 0xFF;
        final int U = yuv420sp[uvIndex + 1] & 0xFF;

        int r = (Y + 1.13983 * (V - 128)).round();
        int g = (Y - 0.39465 * (U - 128) - 0.58060 * (V - 128)).round();
        int b = (Y + 2.03211 * (U - 128)).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    return image;
  }

  /// Load and decode image from file path (recommended for gallery images)
  static Future<img.Image?> loadImageFromFile(File imageFile) async {
    try {
      log('Loading image from file: ${imageFile.path}');

      // Validate file
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      // Use decodeImageFile for better memory management
      final image = await img.decodeImageFile(imageFile.path);
      if (image == null) {
        throw Exception('Failed to decode image - unsupported format');
      }

      log('Image loaded successfully: ${image.width}x${image.height}');
      return image;
    } catch (e) {
      log('Error loading image from file: $e');
      return null;
    }
  }

  /// Load and decode image from bytes (alternative method)
  static Future<img.Image?> loadImageFromBytes(Uint8List bytes) async {
    try {
      log('Loading image from bytes: ${bytes.length} bytes');

      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image from bytes');
      }

      log('Image loaded from bytes: ${image.width}x${image.height}');
      return image;
    } catch (e) {
      log('Error loading image from bytes: $e');
      return null;
    }
  }

  /// Resize image to specific dimensions with aspect ratio preservation option
  static img.Image resizeImage(
    img.Image image,
    int width,
    int height, {
    bool maintainAspectRatio = false,
    img.Interpolation interpolation = img.Interpolation.linear,
  }) {
    try {
      if (maintainAspectRatio) {
        return resizeImageMaintainAspectRatio(
          image,
          width,
          height,
          interpolation: interpolation,
        );
      }

      return img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: interpolation,
      );
    } catch (e) {
      log('Error resizing image: $e');
      rethrow;
    }
  }

  /// Resize image while maintaining aspect ratio
  static img.Image resizeImageMaintainAspectRatio(
    img.Image image,
    int targetWidth,
    int targetHeight, {
    img.Interpolation interpolation = img.Interpolation.linear,
  }) {
    try {
      final double aspectRatio = image.width / image.height;
      final double targetAspectRatio = targetWidth / targetHeight;

      int newWidth, newHeight;

      if (aspectRatio > targetAspectRatio) {
        // Image is wider than target
        newWidth = targetWidth;
        newHeight = (targetWidth / aspectRatio).round();
      } else {
        // Image is taller than target
        newHeight = targetHeight;
        newWidth = (targetHeight * aspectRatio).round();
      }

      return img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: interpolation,
      );
    } catch (e) {
      log('Error resizing image with aspect ratio: $e');
      rethrow;
    }
  }

  /// Prepare image for ML model (224x224 RGB normalization)
  static img.Image preprocessForFoodModel(img.Image image) {
    try {
      log('Preprocessing image for food model: ${image.width}x${image.height}');

      // Resize to model requirements (224x224)
      final resized = img.copyResize(
        image,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );

      // Ensure RGB format (3 channels)
      final rgbImage = resized.convert(numChannels: 3);

      log(
        'Image preprocessed to: ${rgbImage.width}x${rgbImage.height}, channels: ${rgbImage.numChannels}',
      );
      return rgbImage;
    } catch (e) {
      log('Error preprocessing image for model: $e');
      rethrow;
    }
  }

  /// Normalize image pixels to [0, 1] range for ML input
  static List<List<List<double>>> normalizeImagePixels(img.Image image) {
    try {
      return List.generate(
        image.height,
        (y) => List.generate(image.width, (x) {
          final pixel = image.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      );
    } catch (e) {
      log('Error normalizing image pixels: $e');
      rethrow;
    }
  }

  /// Convert image to Float32List for TensorFlow Lite input
  static Float32List imageToFloat32List(img.Image image) {
    try {
      final inputSize = image.width * image.height * 3; // RGB channels
      final input = Float32List(inputSize);
      int index = 0;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // Normalize to [0.0, 1.0]
          input[index++] = pixel.r / 255.0;
          input[index++] = pixel.g / 255.0;
          input[index++] = pixel.b / 255.0;
        }
      }

      return input;
    } catch (e) {
      log('Error converting image to Float32List: $e');
      rethrow;
    }
  }

  /// Convert image file to normalized pixel array for ML processing
  static Future<List<List<List<double>>>> preprocessImageFile(
    File imageFile,
    int targetWidth,
    int targetHeight,
  ) async {
    try {
      final image = await loadImageFromFile(imageFile);
      if (image == null) {
        throw Exception('Failed to load image from file');
      }

      final resizedImage = resizeImage(image, targetWidth, targetHeight);
      return normalizeImagePixels(resizedImage);
    } catch (e) {
      log('Error preprocessing image file: $e');
      rethrow;
    }
  }

  /// Save image to file with quality control
  static Future<File> saveImageToFile(
    img.Image image,
    String path, {
    int quality = 85,
  }) async {
    try {
      final bytes = img.encodeJpg(image, quality: quality);
      final file = File(path);
      await file.writeAsBytes(bytes);

      log('Image saved to: $path (${bytes.length} bytes)');
      return file;
    } catch (e) {
      log('Error saving image to file: $e');
      rethrow;
    }
  }

  /// Crop image to specified rectangle
  static img.Image cropImage(
    img.Image image,
    int x,
    int y,
    int width,
    int height,
  ) {
    try {
      return img.copyCrop(image, x: x, y: y, width: width, height: height);
    } catch (e) {
      log('Error cropping image: $e');
      rethrow;
    }
  }

  /// Get image format information
  static Map<String, dynamic> getImageInfo(img.Image image) {
    return {
      'width': image.width,
      'height': image.height,
      'channels': image.numChannels,
      'format': image.format.toString(),
      'aspectRatio': image.width / image.height,
    };
  }

  /// Validate image file format
  static bool isValidImageFormat(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    const supportedFormats = ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'webp'];
    return supportedFormats.contains(extension);
  }

  /// Check if image format is supported by camera conversion
  static bool isSupportedCameraFormat(ImageFormatGroup format) {
    return format == ImageFormatGroup.yuv420 ||
        format == ImageFormatGroup.bgra8888 ||
        format == ImageFormatGroup.nv21;
  }

  /// Get file size in human readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Validate image file before processing
  static Future<bool> validateImageFile(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        log('Image file does not exist: ${imageFile.path}');
        return false;
      }

      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        log('Image file is empty: ${imageFile.path}');
        return false;
      }

      // Check file extension
      if (!isValidImageFormat(imageFile.path)) {
        log('Unsupported image format: ${imageFile.path}');
        return false;
      }

      // Try to load the image to verify it's a valid image
      final image = await loadImageFromFile(imageFile);
      if (image == null) {
        log('Failed to decode image file: ${imageFile.path}');
        return false;
      }

      log('Image file validation passed: ${imageFile.path}');
      return true;
    } catch (e) {
      log('Error validating image file: $e');
      return false;
    }
  }
}
