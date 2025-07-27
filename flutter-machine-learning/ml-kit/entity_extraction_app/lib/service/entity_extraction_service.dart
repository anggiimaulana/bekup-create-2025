import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class EntityExtractionService {
  static final _language = EntityExtractorLanguage.english;
  final _modelManager = EntityExtractorModelManager();
  final _entityExtractor = EntityExtractor(language: _language);

  EntityExtractionService() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    await downloadModel();
  }

  Future<void> downloadModel() async {
    try {
      final isModelDownloaded = await _modelManager.isModelDownloaded(
        _language.name,
      );

      if (!isModelDownloaded) {
        print('Downloading entity extraction model...');
        await _modelManager.downloadModel(_language.name);
        print('Model downloaded successfully');
      }
    } catch (e) {
      print('Error downloading model: $e');
      rethrow;
    }
  }

  Future<List<EntityAnnotation>> extractEntity(String text) async {
    try {
      // Pastikan model sudah terdownload
      await downloadModel();
      final annotateText = await _entityExtractor.annotateText(text);
      return annotateText;
    } catch (e) {
      print('Error extracting entities: $e');
      return [];
    }
  }

  Future<void> close() async {
    try {
      await _entityExtractor.close();
    } catch (e) {
      print('Error closing entity extractor: $e');
    }
  }
}
