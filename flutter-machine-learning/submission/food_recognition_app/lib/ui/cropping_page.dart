import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CroppingPage extends StatefulWidget {
  final File imageFile;

  const CroppingPage({super.key, required this.imageFile});

  @override
  State<CroppingPage> createState() => _CroppingPageState();
}

class _CroppingPageState extends State<CroppingPage> {
  bool _isAnalyzing = false;
  Rect? _cropRect;
  GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Crop Image', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Image display area
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Image.file(
                          widget.imageFile,
                          key: _imageKey,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Error loading image',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Enhanced crop overlay with proper scaling
                        ResizableCropOverlay(
                          imageFile: widget.imageFile,
                          containerSize: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          onCropChanged: (rect) {
                            setState(() {
                              _cropRect = rect;
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Drag the crop area to move it, or drag the corner handles to resize. Tap Analyze when ready.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Analyze button
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isAnalyzing ? null : _analyzeCroppedImage,
                    child: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Analyze',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeCroppedImage() async {
    setState(() => _isAnalyzing = true);

    try {
      final originalBytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(originalBytes)!;

      final crop = _cropRect;
      if (crop == null) throw 'Crop area is not set';

      // Crop image menggunakan koordinat yang sudah di-scale
      final cropped = img.copyCrop(
        originalImage,
        x: crop.left.round(),
        y: crop.top.round(),
        width: crop.width.round(),
        height: crop.height.round(),
      );

      final croppedBytes = img.encodeJpg(cropped);

      // Save to temp file
      final tempPath =
          '${Directory.systemTemp.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final croppedFile = await File(tempPath).writeAsBytes(croppedBytes);

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Crop failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }
}

class ResizableCropOverlay extends StatefulWidget {
  final File imageFile;
  final Size containerSize;
  final Function(Rect cropRect)? onCropChanged;

  const ResizableCropOverlay({
    super.key,
    required this.imageFile,
    required this.containerSize,
    this.onCropChanged,
  });

  @override
  State<ResizableCropOverlay> createState() => _ResizableCropOverlayState();
}

class _ResizableCropOverlayState extends State<ResizableCropOverlay> {
  Rect _cropRect = const Rect.fromLTWH(50, 50, 200, 200);
  Rect _imageDisplayRect = Rect.zero;

  // Original image dimensions
  late Size _originalImageSize;

  // Untuk tracking drag operation
  bool _isDraggingCrop = false;
  bool _isResizing = false;
  ResizeHandle? _activeHandle;
  Offset? _startDragPos;
  Rect? _startCropRect;

  // Ukuran handle
  static const double handleSize = 20.0;
  static const double minCropSize = 50.0;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null) {
        _originalImageSize = Size(
          image.width.toDouble(),
          image.height.toDouble(),
        );
        _calculateImageDisplayRect();
        _initializeCropRect();
      }
    } catch (e) {
      print('Error loading image dimensions: $e');
    }
  }

  void _calculateImageDisplayRect() {
    if (_originalImageSize == Size.zero) return;

    final containerSize = widget.containerSize;
    final imageAspectRatio =
        _originalImageSize.width / _originalImageSize.height;
    final containerAspectRatio = containerSize.width / containerSize.height;

    double displayWidth, displayHeight;
    double offsetX = 0, offsetY = 0;

    if (imageAspectRatio > containerAspectRatio) {
      // Image is wider than container
      displayWidth = containerSize.width;
      displayHeight = displayWidth / imageAspectRatio;
      offsetY = (containerSize.height - displayHeight) / 2;
    } else {
      // Image is taller than container
      displayHeight = containerSize.height;
      displayWidth = displayHeight * imageAspectRatio;
      offsetX = (containerSize.width - displayWidth) / 2;
    }

    _imageDisplayRect = Rect.fromLTWH(
      offsetX,
      offsetY,
      displayWidth,
      displayHeight,
    );
  }

  void _initializeCropRect() {
    if (_imageDisplayRect == Rect.zero) return;

    // Initialize crop rect in the center of the displayed image with reasonable size
    final centerX = _imageDisplayRect.left + _imageDisplayRect.width / 2;
    final centerY = _imageDisplayRect.top + _imageDisplayRect.height / 2;
    final cropSize = (_imageDisplayRect.width * 0.6).clamp(
      minCropSize,
      _imageDisplayRect.width,
    );

    setState(() {
      _cropRect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: cropSize,
        height: cropSize,
      );
    });

    // Notify parent with scaled coordinates
    _notifyParentWithScaledCoordinates();
  }

  void _notifyParentWithScaledCoordinates() {
    if (_imageDisplayRect == Rect.zero || _originalImageSize == Size.zero)
      return;

    // Convert UI coordinates to original image coordinates
    final scaleX = _originalImageSize.width / _imageDisplayRect.width;
    final scaleY = _originalImageSize.height / _imageDisplayRect.height;

    final relativeRect = Rect.fromLTWH(
      _cropRect.left - _imageDisplayRect.left,
      _cropRect.top - _imageDisplayRect.top,
      _cropRect.width,
      _cropRect.height,
    );

    final scaledRect = Rect.fromLTWH(
      (relativeRect.left * scaleX).clamp(0, _originalImageSize.width),
      (relativeRect.top * scaleY).clamp(0, _originalImageSize.height),
      (relativeRect.width * scaleX).clamp(1, _originalImageSize.width),
      (relativeRect.height * scaleY).clamp(1, _originalImageSize.height),
    );

    widget.onCropChanged?.call(scaledRect);
  }

  void _onPanStart(DragStartDetails details) {
    _startDragPos = details.localPosition;
    _startCropRect = _cropRect;

    // Check if user is dragging a resize handle
    final handle = _getHandleAtPosition(details.localPosition);
    if (handle != null) {
      setState(() {
        _isResizing = true;
        _activeHandle = handle;
      });
    } else if (_cropRect.contains(details.localPosition)) {
      // User is dragging the crop area itself
      setState(() {
        _isDraggingCrop = true;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startDragPos == null ||
        _startCropRect == null ||
        _imageDisplayRect == Rect.zero)
      return;

    final currentPos = details.localPosition;
    final offset = currentPos - _startDragPos!;

    if (_isResizing && _activeHandle != null) {
      _handleResize(offset);
    } else if (_isDraggingCrop) {
      _handleMove(offset);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDraggingCrop = false;
      _isResizing = false;
      _activeHandle = null;
      _startDragPos = null;
      _startCropRect = null;
    });
  }

  void _handleMove(Offset offset) {
    final newRect = _startCropRect!.shift(offset);

    // Constrain the movement to stay within image display bounds
    final constrainedRect = Rect.fromLTWH(
      newRect.left.clamp(
        _imageDisplayRect.left,
        _imageDisplayRect.right - newRect.width,
      ),
      newRect.top.clamp(
        _imageDisplayRect.top,
        _imageDisplayRect.bottom - newRect.height,
      ),
      newRect.width,
      newRect.height,
    );

    setState(() {
      _cropRect = constrainedRect;
    });
    _notifyParentWithScaledCoordinates();
  }

  void _handleResize(Offset offset) {
    var newRect = _startCropRect!;

    switch (_activeHandle!) {
      case ResizeHandle.topLeft:
        newRect = Rect.fromLTRB(
          newRect.left + offset.dx,
          newRect.top + offset.dy,
          newRect.right,
          newRect.bottom,
        );
        break;
      case ResizeHandle.topRight:
        newRect = Rect.fromLTRB(
          newRect.left,
          newRect.top + offset.dy,
          newRect.right + offset.dx,
          newRect.bottom,
        );
        break;
      case ResizeHandle.bottomLeft:
        newRect = Rect.fromLTRB(
          newRect.left + offset.dx,
          newRect.top,
          newRect.right,
          newRect.bottom + offset.dy,
        );
        break;
      case ResizeHandle.bottomRight:
        newRect = Rect.fromLTRB(
          newRect.left,
          newRect.top,
          newRect.right + offset.dx,
          newRect.bottom + offset.dy,
        );
        break;
    }

    // Constrain the new rect to minimum size and image display bounds
    final constrainedRect = Rect.fromLTWH(
      newRect.left.clamp(
        _imageDisplayRect.left,
        _imageDisplayRect.right - minCropSize,
      ),
      newRect.top.clamp(
        _imageDisplayRect.top,
        _imageDisplayRect.bottom - minCropSize,
      ),
      newRect.width.clamp(minCropSize, _imageDisplayRect.right - newRect.left),
      newRect.height.clamp(minCropSize, _imageDisplayRect.bottom - newRect.top),
    );

    setState(() {
      _cropRect = constrainedRect;
    });
    _notifyParentWithScaledCoordinates();
  }

  ResizeHandle? _getHandleAtPosition(Offset position) {
    const tolerance = handleSize / 2;

    // Check each corner handle
    final topLeft = Offset(_cropRect.left, _cropRect.top);
    final topRight = Offset(_cropRect.right, _cropRect.top);
    final bottomLeft = Offset(_cropRect.left, _cropRect.bottom);
    final bottomRight = Offset(_cropRect.right, _cropRect.bottom);

    if ((position - topLeft).distance <= tolerance) {
      return ResizeHandle.topLeft;
    } else if ((position - topRight).distance <= tolerance) {
      return ResizeHandle.topRight;
    } else if ((position - bottomLeft).distance <= tolerance) {
      return ResizeHandle.bottomLeft;
    } else if ((position - bottomRight).distance <= tolerance) {
      return ResizeHandle.bottomRight;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_imageDisplayRect == Rect.zero) {
      return const SizedBox(); // Don't show overlay until we have image dimensions
    }

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Semi-transparent overlay covering entire container
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
            ),

            // Clear crop area (show original image through this area)
            Positioned(
              left: _cropRect.left,
              top: _cropRect.top,
              child: Container(
                width: _cropRect.width,
                height: _cropRect.height,
                color: Colors.transparent,
              ),
            ),

            // Crop border
            Positioned(
              left: _cropRect.left,
              top: _cropRect.top,
              child: Container(
                width: _cropRect.width,
                height: _cropRect.height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),

            // Grid lines (rule of thirds)
            Positioned(
              left: _cropRect.left,
              top: _cropRect.top,
              child: Container(
                width: _cropRect.width,
                height: _cropRect.height,
                child: CustomPaint(painter: GridPainter()),
              ),
            ),

            // Resize handles
            ..._buildResizeHandles(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResizeHandles() {
    return [
      // Top-left handle
      _buildHandle(
        ResizeHandle.topLeft,
        _cropRect.left - handleSize / 2,
        _cropRect.top - handleSize / 2,
      ),
      // Top-right handle
      _buildHandle(
        ResizeHandle.topRight,
        _cropRect.right - handleSize / 2,
        _cropRect.top - handleSize / 2,
      ),
      // Bottom-left handle
      _buildHandle(
        ResizeHandle.bottomLeft,
        _cropRect.left - handleSize / 2,
        _cropRect.bottom - handleSize / 2,
      ),
      // Bottom-right handle
      _buildHandle(
        ResizeHandle.bottomRight,
        _cropRect.right - handleSize / 2,
        _cropRect.bottom - handleSize / 2,
      ),
    ];
  }

  Widget _buildHandle(ResizeHandle handle, double left, double top) {
    final isActive = _activeHandle == handle;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: handleSize,
        height: handleSize,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white,
          border: Border.all(
            color: isActive ? Colors.white : Colors.blue,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(handleSize / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

enum ResizeHandle { topLeft, topRight, bottomLeft, bottomRight }

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    // Vertical lines (rule of thirds)
    final thirdWidth = size.width / 3;
    canvas.drawLine(
      Offset(thirdWidth, 0),
      Offset(thirdWidth, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(thirdWidth * 2, 0),
      Offset(thirdWidth * 2, size.height),
      paint,
    );

    // Horizontal lines (rule of thirds)
    final thirdHeight = size.height / 3;
    canvas.drawLine(
      Offset(0, thirdHeight),
      Offset(size.width, thirdHeight),
      paint,
    );
    canvas.drawLine(
      Offset(0, thirdHeight * 2),
      Offset(size.width, thirdHeight * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
