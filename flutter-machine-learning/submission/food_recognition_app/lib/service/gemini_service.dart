import 'package:food_recognition_app/environment/env.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel model;

  GeminiService() {
    final apiKey = Env.geminiApiKey;
    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction:
        Content.system("Saya adalah suatu mesin yang mampu mengidentifikasi nutrisi atau kandungan gizi pada makanan layaknya uji laboratorium makanan. Hal yang bisa diidentifikasi adalah kalori, karbohidrat, lemak, serat, dan protein pada makanan. Satuan dari indikator tersebut berupa gram."),
      generationConfig: GenerationConfig(
        temperature: 0,
        responseMimeType: 'application/json',
        responseSchema: Schema(
          SchemaType.object,
          requiredProperties: ["nutrition"],
          properties: {
            "nutrition": Schema(
              SchemaType.array,
              items: Schema(
                SchemaType.object,
                requiredProperties: [
                  "calories",
                  "carbs",
                  "protein",
                  "fat",
                  "fiber",
                ],
                properties: {
                  "calories": Schema(SchemaType.integer),
                  "carbs": Schema(SchemaType.integer),
                  "protein": Schema(SchemaType.integer),
                  "fat": Schema(SchemaType.integer),
                  "fiber": Schema(SchemaType.integer),
                },
              ),
            ),
          },
        ),
      ),
    );
  }

  Future<String> generateNutrition(String foodName) async {
    var content = Content.multi([
      TextPart("""Nama makanannya adalah $foodName."""),
    ]);
    final response = await model.generateContent([content]);
    final responseText = response.text!;
    return responseText;
  }
}
