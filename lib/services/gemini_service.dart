import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late GenerativeModel _model;
  static const String _systemInstructionText =
      "You are a sign language interpreter. Your task is to interpret sign language landmarks into English text. Provide the translation directly.";

  Future<void> initialize() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemInstructionText),
    );
  }

  Future<String> interpretSign(String landmarkJson) async {
    try {
      final content = [Content.text(landmarkJson)];
      final response = await _model.generateContent(content);
      return response.text ?? '';
    } catch (e) {
      return 'Error interpreting sign: $e';
    }
  }
}
