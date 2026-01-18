import 'dart:convert';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:signspeak_live/utils/landmark_utils.dart';

void main() {
  group('LandmarkUtils', () {
    test(
      'landmarksToJson converts landmarks to JSON correctly without normalization',
      () {
        final landmarks = {
          PoseLandmarkType.nose: PoseLandmark(
            type: PoseLandmarkType.nose,
            x: 100.0,
            y: 200.0,
            z: 10.0,
            likelihood: 0.9,
          ),
        };

        final jsonString = LandmarkUtils.landmarksToJson(landmarks);
        final List<dynamic> decoded = jsonDecode(jsonString);

        expect(decoded.length, 1);
        expect(decoded[0]['type'], 'nose');
        expect(decoded[0]['x'], 100.0);
        expect(decoded[0]['y'], 200.0);
        expect(decoded[0]['z'], 10.0);
        expect(decoded[0]['likelihood'], 0.9);
      },
    );

    test(
      'landmarksToJson converts landmarks to JSON correctly with normalization',
      () {
        final landmarks = {
          PoseLandmarkType.leftWrist: PoseLandmark(
            type: PoseLandmarkType.leftWrist,
            x: 100.0,
            y: 200.0,
            z: 10.0,
            likelihood: 0.9,
          ),
        };

        const imageSize = Size(1000.0, 500.0);
        final jsonString = LandmarkUtils.landmarksToJson(landmarks, imageSize);
        final List<dynamic> decoded = jsonDecode(jsonString);

        expect(decoded.length, 1);
        expect(decoded[0]['type'], 'leftWrist');
        expect(decoded[0]['x'], 0.1); // 100 / 1000
        expect(decoded[0]['y'], 0.4); // 200 / 500
        expect(decoded[0]['z'], 10.0);
        expect(decoded[0]['likelihood'], 0.9);
      },
    );

    test('landmarksToJson handles empty landmarks', () {
      final landmarks = <PoseLandmarkType, PoseLandmark>{};
      final jsonString = LandmarkUtils.landmarksToJson(landmarks);
      final List<dynamic> decoded = jsonDecode(jsonString);

      expect(decoded, isEmpty);
    });

    test('landmarksToJson handles zero dimensions in imageSize gracefully', () {
      final landmarks = {
        PoseLandmarkType.nose: PoseLandmark(
          type: PoseLandmarkType.nose,
          x: 100.0,
          y: 200.0,
          z: 10.0,
          likelihood: 0.9,
        ),
      };

      const imageSize = Size(0, 0);
      final jsonString = LandmarkUtils.landmarksToJson(landmarks, imageSize);
      final List<dynamic> decoded = jsonDecode(jsonString);

      // Should not normalize (divide by zero protection)
      expect(decoded[0]['x'], 100.0);
      expect(decoded[0]['y'], 200.0);
    });
  });
}
