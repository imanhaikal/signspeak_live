import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signspeak_live/services/gemini_service.dart';

void main() {
  group('GeminiService Integration', () {
    test('interpretSign returns valid response from API', () async {
      await dotenv.load(fileName: ".env");
      final service = GeminiService();
      await service.initialize();

      // Dummy landmark data (mimicking what the model expects roughly)
      final dummyLandmarks = "Hand landmarks: [x:0.5, y:0.5, z:0.0]";

      final result = await service.interpretSign(dummyLandmarks);

      print('API Response: $result');
      expect(result, isNotEmpty);
      expect(result, isNot(contains('Error')));
    }, skip: true); // Skipped to save quota
  });
}
