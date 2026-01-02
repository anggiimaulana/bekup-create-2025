import 'dart:convert';

class UploadResponse {
  final bool error;
  final String message;

  UploadResponse({required this.error, required this.message});

  factory UploadResponse.fromMap(Map<String, dynamic> map) {
    return UploadResponse(
      error: map['error'] ?? false,
      message: map['message'] ?? '',
    );
  }

  factory UploadResponse.fromJson(String source) {
    final Map<String, dynamic> map = json.decode(source);
    return UploadResponse.fromMap(map);
  }
}
