import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'package:story_app/utils/constansts.dart';

class MapPickerScreen extends StatefulWidget {
  final ValueChanged<LatLng> onConfirm;
  final VoidCallback onBack;

  const MapPickerScreen({
    super.key,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String _address = '';
  bool _isLoadingAddress = false;

  final LatLng _defaultPosition = const LatLng(-6.2088, 106.8456); // Jakarta

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedPosition = latLng;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

      _getAddressFromLatLng(latLng);
    } catch (e) {
      _showError('Failed to get current location: ${e.toString()}');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoadingAddress = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
          _isLoadingAddress = false;
        });
      }
    } catch (_) {
      setState(() {
        _address =
            'Lat: ${position.latitude.toStringAsFixed(4)}, '
            'Lng: ${position.longitude.toStringAsFixed(4)}';
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _getAddressFromLatLng(position);
  }

  void _confirmLocation() {
    if (_selectedPosition != null) {
      widget.onConfirm(_selectedPosition!);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.primaryColor),
          onPressed: widget.onBack,
        ),
        title: Text(
          l10n.pickLocation,
          style: const TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedPosition != null)
            IconButton(
              icon: const Icon(Icons.check, color: AppConstants.primaryColor),
              onPressed: _confirmLocation,
              tooltip: l10n.confirmLocation,
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _defaultPosition,
              zoom: 12,
            ),
            onTap: _onMapTap,
            markers: _selectedPosition != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedPosition!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                    ),
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _selectedPosition != null ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isLoadingAddress
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.loadingAddress),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.selectedLocation,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _address.isEmpty
                                  ? l10n.tapToSelectedLocation
                                  : _address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'myLocation',
              onPressed: _getCurrentLocation,
              backgroundColor: AppConstants.surfaceColor,
              child: const Icon(
                Icons.my_location,
                color: AppConstants.primaryColor,
              ),
            ),
          ),

          if (_selectedPosition != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle),
                    const SizedBox(width: 8),
                    Text(
                      l10n.confirmLocation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
