import 'dart:io';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

// todo-02: create a class
class FirebaseMlService {
  // todo-03: add a function to load a model from firebase
  Future<File> loadModel() async {
    final instance = FirebaseModelDownloader.instance;
    final model = await instance.getModel(
      "food_prediction",
      FirebaseModelDownloadType.localModel,
      FirebaseModelDownloadConditions(
        iosAllowsCellularAccess: true,
        iosAllowsBackgroundDownloading: false,
        androidChargingRequired: false,
        androidWifiRequired: false,
        androidDeviceIdleRequired: false,
      ),
    );
    return model.file;
  }
}
