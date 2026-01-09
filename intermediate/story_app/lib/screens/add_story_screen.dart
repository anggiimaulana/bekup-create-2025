import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:story_app/config/flavor_config.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'package:story_app/providers/auth_provider.dart';
import 'package:story_app/providers/story_provider.dart';
import 'package:story_app/utils/constansts.dart';
import 'package:story_app/widgets/button_widget.dart';

class AddStoryScreen extends StatefulWidget {
  final VoidCallback onStoryAdded;
  final VoidCallback onBack;
  final VoidCallback onPickLocation;
  final LatLng? selectedLocation;

  const AddStoryScreen({
    super.key,
    required this.onStoryAdded,
    required this.onBack,
    required this.onPickLocation,
    required this.selectedLocation,
  });

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  File? _imageFile;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppConstants.textSecondaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.selectImage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppConstants.primaryColor,
                    ),
                    title: Text(l10n.camera),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _pickImageFromCamera();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library_outlined,
                      color: AppConstants.primaryColor,
                    ),
                    title: Text(l10n.gallery),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _pickImageFromGallery();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleUpload() async {
    if (_imageFile == null) {
      _showError(AppLocalizations.of(context)!.imageRequired);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();

    if (authProvider.token == null) return;

    final success = await storyProvider.uploadStory(
      authProvider.token!,
      _imageFile!,
      _descriptionController.text.trim(),
      lat: widget.selectedLocation?.latitude,
      lon: widget.selectedLocation?.longitude,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.uploadSuccess),
          backgroundColor: AppConstants.successColor,
        ),
      );
      widget.onStoryAdded();
    } else {
      _showError(
        storyProvider.errorMessage ??
            AppLocalizations.of(context)!.uploadFailed,
      );
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
    final canAddLocation = FlavorConfig.instance.canAddLocation;
    final location = widget.selectedLocation;

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
          l10n.addStory,
          style: const TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    border: Border.all(
                      color: AppConstants.textSecondaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 64,
                              color: AppConstants.textSecondaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.selectImage,
                              style: const TextStyle(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? l10n.descriptionRequired
                    : null,
              ),
              const SizedBox(height: 24),
              if (canAddLocation)
                ListTile(
                  tileColor: AppConstants.surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  leading: Icon(
                    location != null
                        ? Icons.location_on
                        : Icons.location_on_outlined,
                    color: AppConstants.primaryColor,
                  ),
                  title: Text(
                    location != null
                        ? l10n.selectedLocation
                        : l10n.unselectedLocation,
                  ),
                  subtitle: location != null
                      ? Text(
                          'Lat: ${location.latitude.toStringAsFixed(4)}, '
                          'Lng: ${location.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 12),
                        )
                      : Text(l10n.tapToSelectedLocation),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: widget.onPickLocation,
                ),
              const SizedBox(height: 24),
              Consumer<StoryProvider>(
                builder: (_, storyProvider, __) {
                  return CustomButton(
                    text: l10n.upload,
                    isLoading: storyProvider.state == StoryState.uploading,
                    onPressed: _handleUpload,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
