import 'dart:developer';
import 'dart:io';

class DebugHelper {
  static void logFileInfo(File? file, {String prefix = 'File'}) {
    if (file == null) {
      log('$prefix: null');
      return;
    }

    log('$prefix Path: ${file.path}');
    log('$prefix Exists: ${file.existsSync()}');

    if (file.existsSync()) {
      try {
        final size = file.lengthSync();
        log('$prefix Size: $size bytes');

        final ext = file.path.split('.').last.toLowerCase();
        log('$prefix Extension: $ext');

        // Check if it's a valid image extension
        const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
        final isValidImage = validExtensions.contains(ext);
        log('$prefix Valid Image: $isValidImage');
      } catch (e) {
        log('$prefix Error reading file info: $e');
      }
    }
  }

  static void logPredictions(
    Map<String, String> predictions, {
    String prefix = 'Predictions',
  }) {
    log('$prefix Count: ${predictions.length}');

    if (predictions.isEmpty) {
      log('$prefix: Empty predictions map!');
      return;
    }

    int index = 1;
    predictions.forEach((key, value) {
      log('$prefix [$index]: $key -> $value');
      index++;
    });
  }

  static void logServiceStatus(dynamic service, String serviceName) {
    log('=== $serviceName Status ===');

    try {
      if (service == null) {
        log('$serviceName: null');
        return;
      }

      // Check if service has isInitialized property
      if (service.hasProperty('isInitialized')) {
        log('$serviceName Initialized: ${service.isInitialized}');
      }

      // Check if service has isLoading property
      if (service.hasProperty('isLoading')) {
        log('$serviceName Loading: ${service.isLoading}');
      }

      // Check if service has errorMessage property
      if (service.hasProperty('errorMessage')) {
        log('$serviceName Error: ${service.errorMessage}');
      }
    } catch (e) {
      log('$serviceName Status Check Error: $e');
    }
  }

  static void logNavigationAttempt(String page, Map<String, dynamic>? params) {
    log('=== Navigation Attempt ===');
    log('Target Page: $page');

    if (params != null) {
      log('Parameters:');
      params.forEach((key, value) {
        log('  $key: $value');
      });
    }
  }

  static void logError(
    String operation,
    dynamic error, {
    StackTrace? stackTrace,
  }) {
    log('=== ERROR in $operation ===');
    log('Error: $error');
    log('Type: ${error.runtimeType}');

    if (stackTrace != null) {
      log('Stack Trace:');
      log(stackTrace.toString());
    }
  }

  // Check if service/object has a property
  static bool hasProperty(dynamic object, String propertyName) {
    try {
      // Use reflection or try-catch to check property
      switch (propertyName) {
        case 'isInitialized':
          return object.isInitialized != null;
        case 'isLoading':
          return object.isLoading != null;
        case 'errorMessage':
          return object.errorMessage != null;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}

// Extension to add property checking
extension ServiceExtension on dynamic {
  bool hasProperty(String propertyName) {
    return DebugHelper.hasProperty(this, propertyName);
  }
}
