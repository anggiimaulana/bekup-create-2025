import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';
import 'package:transcript_app/env/env.dart';

class GeminiService {
  late final GenerativeModel model;

  GeminiService() {
    final apiKey = Env.geminiApiKey;
    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0,
        responseMimeType: 'application/json',
        responseSchema: Schema(
          SchemaType.object,
          requiredProperties: ["segments"],
          properties: {
            "segments": Schema(
              SchemaType.array,
              items: Schema(
                SchemaType.object,
                requiredProperties: ["speaker", "timecode", "caption"],
                properties: {
                  "speaker": Schema(SchemaType.string),
                  "timecode": Schema(SchemaType.string),
                  "caption": Schema(SchemaType.string),
                },
              ),
            ),
          },
        ),
      ),
    );
  }

  Future<String> generateTranscript(File file) async {
    var content = Content.multi([
      TextPart(
        """Bisakah Anda menyalin wawancara ini, dalam format timecode (MM:SS), nama pembicara, caption? Jika Anda mengenali nama pembicara, gunakan nama tersebut. Jika tidak, gunakan pembicara A, pembicara B, dst.""",
      ),
      DataPart(lookupMimeType(file.path)!, file.readAsBytesSync()),
    ]);

    final response = await model.generateContent([content]);
    print("Token: ${response.usageMetadata?.totalTokenCount}");

    final responseText = response.text!;
    print("ResponseText: $responseText");

    return responseText;
  }
}
