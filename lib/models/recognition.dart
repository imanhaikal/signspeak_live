import 'dart:ui';

class RecognitionResult {
  final String label;
  final double confidence;
  final Rect rect;

  RecognitionResult({
    required this.label,
    required this.confidence,
    required this.rect,
  });
}
