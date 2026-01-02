import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../model/upload_response.dart';

class ApiService {
  Future<UploadResponse> uploadDocument(
    List<int> bytes,
    String fileName,
    String description,
  ) async {
    const String url = 'https://story-api.dicoding.dev/v1/stories/guest';

    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    // FILE
    request.files.add(
      http.MultipartFile.fromBytes('photo', bytes, filename: fileName),
    );

    request.fields['description'] = description;

    final http.StreamedResponse response = await request.send();

    final Uint8List responseBytes = await response.stream.toBytes();
    final String responseBody = String.fromCharCodes(responseBytes);

    if (response.statusCode == 201) {
      return UploadResponse.fromJson(responseBody);
    } else {
      // BIAR KELIHATAN ERROR DARI SERVER
      throw Exception(
        'Upload failed '
        '(status: ${response.statusCode}) '
        'response: $responseBody',
      );
    }
  }
}
