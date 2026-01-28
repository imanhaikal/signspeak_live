import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class GenerativeModelClient {
  Future<String?> generateContent(Iterable<Content> content);
}

class RealGenerativeModelClient implements GenerativeModelClient {
  final GenerativeModel _model;
  RealGenerativeModelClient(this._model);

  @override
  Future<String?> generateContent(Iterable<Content> content) async {
    final response = await _model.generateContent(content);
    return response.text;
  }
}

class GeminiService {
  late GenerativeModelClient _client;
  final GenerativeModelClient? _injectedClient;
  static const String _systemInstructionText =
      "You are a sign language interpreter. Your task is to interpret sign language landmarks into English text. Provide the translation directly.";

  GeminiService({GenerativeModelClient? client}) : _injectedClient = client;

  Future<void> initialize() async {
    if (_injectedClient != null) {
      _client = _injectedClient;
      return;
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_systemInstructionText),
    );
    _client = RealGenerativeModelClient(model);
  }

  Future<String> interpretSign(String landmarkJson) async {
    try {
      final content = [Content.text(landmarkJson)];
      final text = await _client.generateContent(content);
      return text ?? '';
    } catch (e) {
      return 'Error interpreting sign: $e';
    }
  }
}
