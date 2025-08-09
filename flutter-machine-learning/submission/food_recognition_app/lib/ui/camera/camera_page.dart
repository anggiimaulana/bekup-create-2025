import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:food_recognition_app/controller/ml/ml_service_manager.dart';
import 'package:food_recognition_app/controller/image/image_classification_provider.dart';
import 'package:food_recognition_app/widget/camera_view.dart';
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
          'Camera Classification',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
  bool _isReady = false;
  String _statusMessage = 'Checking services...';
  String? _errorMessage;
  bool _isDisposed = false;

  Timer? _classificationTimer;
  CameraImage? _latestCameraImage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServicesAndStart();
    });
  }

  Future<void> _checkServicesAndStart() async {
    if (_isDisposed) return;

    try {
      // Check camera permission first
      if (!await checkAndRequestCameraPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission required')),
        );
        Navigator.of(context).pop();
        return;
      }

      // Check ML services status
      final mlManager = context.read<MLServiceManager>();

      if (!mlManager.isInitialized) {
        setState(() {
          _statusMessage = 'AI model not ready. Loading in background...';
        });

        // Wait for services to be ready (with timeout)
        await _waitForMLServices();
      }

      // Services ready, start camera
      if (!_isDisposed && mounted) {
        await _startCameraClassification();
      }
    } catch (e) {
      debugPrint('Error in _checkServicesAndStart: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _waitForMLServices() async {
    final mlManager = context.read<MLServiceManager>();

    // If still initializing, wait for it
    if (mlManager.isInitializing) {
      setState(() {
        _statusMessage =
            'Loading AI model... ${(mlManager.initProgress * 100).toStringAsFixed(0)}%';
      });

      // Listen to initialization progress
      late StreamSubscription subscription;
      subscription = Stream.periodic(const Duration(milliseconds: 500))
          .asyncMap((_) => mlManager)
          .listen((manager) {
            if (!mounted || _isDisposed) {
              subscription.cancel();
              return;
            }

            if (manager.isInitialized) {
              subscription.cancel();
              _startCameraClassification();
            } else if (manager.isInitializing) {
              setState(() {
                _statusMessage =
                    '${manager.currentStep} ${(manager.initProgress * 100).toStringAsFixed(0)}%';
              });
            } else if (manager.errorMessage != null) {
              subscription.cancel();
              setState(() {
                _errorMessage =
                    'Failed to load AI model: ${manager.errorMessage}';
              });
            }
          });

      // Timeout after 30 seconds
      Timer(const Duration(seconds: 30), () {
        subscription.cancel();
        if (!_isDisposed && mounted && !mlManager.isInitialized) {
          setState(() {
            _errorMessage = 'Timeout loading AI model. Please restart the app.';
          });
        }
      });

      return;
    }

    // Services should be ready
    if (!mlManager.isInitialized) {
      throw Exception('ML services not initialized and not initializing');
    }
  }

  Future<void> _startCameraClassification() async {
    if (_isDisposed || !mounted) return;

    try {
      setState(() {
        _statusMessage = 'Starting camera...';
      });

      // Delay ringan biar UI stabil dulu sebelum load kamera
      await Future.delayed(const Duration(milliseconds: 300));

      final viewModel = context.read<ImageClassificationViewmodel>();

      if (!viewModel.isInitialized) {
        await viewModel.initialize();
      }

      setState(() {
        _isReady = true;
      });

      _classificationTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _runClassification(),
      );

      debugPrint('Camera classification started successfully');
    } catch (e) {
      debugPrint('Error starting camera classification: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _errorMessage = 'Failed to start camera: $e';
        });
      }
    }
  }

  Future<void> _runClassification() async {
    if (_isDisposed || !_isReady || !mounted || _latestCameraImage == null) {
      return;
    }

    try {
      final viewModel = context.read<ImageClassificationViewmodel>();
      await viewModel.runClassification(_latestCameraImage!);
    } catch (e) {
      debugPrint('Classification error: $e');
      // Don't show error to user for classification errors
    }
  }

  Future<bool> checkAndRequestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Color _getConfidenceColor(double value) {
    final percent = value * 100;
    if (percent >= 85) return Colors.green;
    if (percent >= 50) return Colors.orange;
    if (percent > 0) return Colors.red;
    return Colors.grey;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _classificationTimer?.cancel();
        break;
      case AppLifecycleState.resumed:
        if (_isReady && !_isDisposed && mounted) {
          _classificationTimer ??= Timer.periodic(
            const Duration(seconds: 1),
            (_) => _runClassification(),
          );
        }
        break;
      case AppLifecycleState.detached:
        _cleanup();
        break;
      default:
        break;
    }
  }

  Future<void> _cleanup() async {
    if (_isDisposed) return;

    debugPrint('Cleaning up camera resources...');
    _isDisposed = true;
    _classificationTimer?.cancel();
  }

  Future<bool> _onWillPop() async {
    _cleanup();
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Builder(
        builder: (context) {
          // Error state
          if (_errorMessage != null) {
            return _buildErrorState();
          }

          // Loading state
          if (!_isReady) {
            return _buildLoadingState();
          }

          // Camera ready state
          return Stack(
            children: [
              // Kamera View
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isReady ? 1 : 0,
                child: _buildCameraView(),
              ),

              // Loading Overlay
              if (!_isReady) Positioned.fill(child: _buildLoadingState()),

              // Error Overlay
              if (_errorMessage != null)
                Positioned.fill(child: _buildErrorState()),
            ],
          );
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
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isReady = false;
                    });
                    _checkServicesAndStart();
                  },
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Preparing Camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        CameraView(
          onImage: (cameraImage) {
            _latestCameraImage = cameraImage;
          },
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Consumer<ImageClassificationViewmodel>(
            builder: (_, viewModel, __) {
              final classifications = viewModel.classifications.entries;

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
                      ...classifications.map((classification) {
                        final percent = classification.value * 100;
                        final color = _getConfidenceColor(classification.value);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            border: Border.all(color: color),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  classification.key,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${percent.toStringAsFixed(1)}%',
                                style: TextStyle(color: color, fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }),
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
}
