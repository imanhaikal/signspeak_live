import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signspeak_live/services/gemini_service.dart';

class MockGenerativeModelClient extends Mock implements GenerativeModelClient {}

void main() {
  late GeminiService geminiService;
  late MockGenerativeModelClient mockClient;

  setUp(() {
    mockClient = MockGenerativeModelClient();
    geminiService = GeminiService(client: mockClient);
  });

  group('GeminiService', () {
    test('interpretSign returns text when successful', () async {
      // Mock the response directly since our client abstraction returns String?
      when(
        () => mockClient.generateContent(any()),
      ).thenAnswer((_) async => 'Hello');

      await geminiService.initialize();
      final result = await geminiService.interpretSign('dummy_landmarks');

      expect(result, 'Hello');
      verify(() => mockClient.generateContent(any())).called(1);
    });

    test('interpretSign returns error message when exception occurs', () async {
      when(
        () => mockClient.generateContent(any()),
      ).thenThrow(Exception('API Error'));

      await geminiService.initialize();
      final result = await geminiService.interpretSign('dummy_landmarks');

      expect(result, contains('Error interpreting sign: Exception: API Error'));
      verify(() => mockClient.generateContent(any())).called(1);
    });
  });
}
