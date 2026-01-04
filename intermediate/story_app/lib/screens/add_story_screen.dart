import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'package:story_app/services/story_provider.dart';
import 'package:story_app/utils/constansts.dart';
import 'package:story_app/widgets/button_widget.dart';
import '../providers/auth_provider.dart';

class AddStoryScreen extends StatefulWidget {
  final VoidCallback onStoryAdded;
  final VoidCallback onBack;

  const AddStoryScreen({
    super.key,
    required this.onStoryAdded,
    required this.onBack,
  });

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  File? _imageFile;

  // STATE BARU: Menggantikan showModalBottomSheet imperatif
  bool _isImagePickerActive = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Animasi agar UX mirip bottom sheet asli
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // LOGIKA DEKLARATIF: Toggle state, bukan push/pop route
  void _toggleImagePicker(bool show) {
    if (show) {
      setState(() => _isImagePickerActive = true);
      _animationController.forward();
    } else {
      _animationController.reverse().then((_) {
        if (mounted) setState(() => _isImagePickerActive = false);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // 1. Tutup dialog dengan mengubah state (Declarative)
    _toggleImagePicker(false);

    // 2. Proses pengambilan gambar
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleUpload() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.imageRequired),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final storyProvider = context.read<StoryProvider>();

      if (authProvider.token == null) return;

      final success = await storyProvider.uploadStory(
        authProvider.token!,
        _imageFile!,
        _descriptionController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.uploadSuccess),
            backgroundColor: AppConstants.successColor,
          ),
        );
        widget.onStoryAdded();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              storyProvider.errorMessage ??
                  AppLocalizations.of(context)!.uploadFailed,
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Gunakan Stack untuk menampung Konten Utama dan Custom Bottom Sheet
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
      body: Stack(
        children: [
          // LAYER 1: KONTEN UTAMA FORM
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    // Trigger state change to SHOW dialog
                    onTap: () => _toggleImagePicker(true),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        border: Border.all(
                          color: AppConstants.textSecondaryColor.withOpacity(
                            0.3,
                          ),
                          width: 2,
                        ),
                      ),
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 64,
                                  color: AppConstants.textSecondaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.selectImage,
                                  style: const TextStyle(
                                    color: AppConstants.textSecondaryColor,
                                    fontSize: 16,
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
                      hintText: 'Tell us about this moment...',
                      filled: true,
                      fillColor: AppConstants.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: const BorderSide(
                          color: AppConstants.primaryColor,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: const BorderSide(
                          color: AppConstants.errorColor,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.descriptionRequired
                        : null,
                  ),
                  const SizedBox(height: 32),
                  Consumer<StoryProvider>(
                    builder: (context, storyProvider, _) {
                      return CustomButton(
                        text: l10n.upload,
                        onPressed: _handleUpload,
                        isLoading: storyProvider.state == StoryState.uploading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // LAYER 2: CUSTOM MODAL OVERLAY (DECLARATIVE)
          if (_isImagePickerActive)
            GestureDetector(
              onTap: () => _toggleImagePicker(false), // Tap outside to close
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // LAYER 3: CUSTOM BOTTOM SHEET UI
          if (_isImagePickerActive)
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
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
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        title: Text(l10n.camera),
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.photo_library_outlined,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        title: Text(l10n.gallery),
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
