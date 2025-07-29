import 'package:flutter/material.dart';
import 'package:food_recognition_app/controller/image_classification_provider.dart';
import 'package:food_recognition_app/widget/camera_view.dart';
import 'package:food_recognition_app/widget/classification_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Image Classification',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigasi yang lebih aman
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const _CameraBody(),
    );
  }
}

class _CameraBody extends StatefulWidget {
  const _CameraBody();

  @override
  State<_CameraBody> createState() => _CameraBodyState();
}

class _CameraBodyState extends State<_CameraBody>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;
  String _initializationError = '';
  bool _isDisposed = false;
  bool _isInitializing = false;

  // Keep alive untuk mencegah rebuild yang tidak perlu
  @override
  bool get wantKeepAlive => true;

  Future<bool> checkAndRequestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await checkAndRequestCameraPermission()) {
        // Tampil dialog atau go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission required')),
        );
        Navigator.of(context).pop();
        return;
      }
      // lanjut inisialisasi camera
      _initializeService();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes dengan lebih hati-hati
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _pauseClassification();
        break;
      case AppLifecycleState.resumed:
        if (_isInitialized && !_isDisposed) {
          _resumeClassification();
        }
        break;
      case AppLifecycleState.detached:
        _cleanup();
        break;
      default:
        break;
    }
  }

  void _pauseClassification() {
    // Hentikan sementara klasifikasi tanpa dispose
    if (_isInitialized && !_isDisposed) {
      debugPrint('Classification paused');
    }
  }

  void _resumeClassification() {
    // Resume klasifikasi
    if (_isInitialized && !_isDisposed && mounted) {
      debugPrint('Classification resumed');
    }
  }

  Future<void> _initializeService() async {
    if (_isDisposed || _isInitializing) return;

    setState(() {
      _isInitializing = true;
      _initializationError = '';
    });

    try {
      final readViewmodel = context.read<ImageClassificationViewmodel>();
      await readViewmodel.initialize();

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
          _isInitializing = false;
        });
        debugPrint('Camera service initialized successfully');
      }
    } catch (e) {
      debugPrint('Error initializing camera service: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _initializationError = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _cleanup() async {
    if (_isDisposed) return;

    debugPrint('Starting camera cleanup...');
    _isDisposed = true;

    try {
      if (_isInitialized) {
        final readViewmodel = context.read<ImageClassificationViewmodel>();
        await readViewmodel.close();
        debugPrint('Camera service closed successfully');
      }
    } catch (e) {
      debugPrint('Error during camera cleanup: $e');
    }
  }

  Future<bool> _onWillPop() async {
    // Cleanup sebelum pop, tapi jangan tunggu terlalu lama
    if (!_isDisposed) {
      _cleanup();
    }
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Cleanup async tanpa await untuk mencegah blocking
    // if (!_isDisposed) {
    //   _cleanup();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Builder(
        builder: (context) {
          // Error state
          if (_initializationError.isNotEmpty) {
            return _buildErrorState();
          }

          // Loading state
          if (!_isInitialized || _isInitializing) {
            return _buildLoadingState();
          }

          // Success state - camera view
          return _buildCameraView();
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Camera Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check camera permissions and try again.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _retryInitialization,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing Camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Loading AI model, please wait',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera view
        CameraView(
          onImage: (cameraImage) async {
            // Safety check sebelum klasifikasi
            if (!_isDisposed && _isInitialized && mounted) {
              try {
                final readViewmodel = context
                    .read<ImageClassificationViewmodel>();
                await readViewmodel.runClassification(cameraImage);
              } catch (e) {
                debugPrint('Classification error: $e');
                // Jangan crash app, just log error
              }
            }
          },
        ),

        // Classification results overlay
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Consumer<ImageClassificationViewmodel>(
            builder: (_, updateViewmodel, __) {
              final classifications = updateViewmodel.classifications.entries;

              if (classifications.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Text(
                    'Point camera at food to classify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Classification Results:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...classifications.map(
                        (classification) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClassificationItem(
                            item: classification.key,
                            value:
                                '${(classification.value * 100).toStringAsFixed(1)}%',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _retryInitialization() {
    if (!_isDisposed && mounted) {
      setState(() {
        _initializationError = '';
        _isInitialized = false;
        _isInitializing = false;
      });
      _initializeService();
    }
  }
}
