import 'dart:convert';
import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class LandmarkUtils {
  /// Converts a map of landmarks to a JSON string.
  ///
  /// [landmarks] is the map of landmarks from the Pose object.
  /// [imageSize] is the size of the image, used for normalization.
  static String landmarksToJson(
    Map<PoseLandmarkType, PoseLandmark> landmarks, [
    Size? imageSize,
  ]) {
    final List<Map<String, dynamic>> landmarkList = [];

    // Ensure consistent ordering for the JSON array, although map iteration order is generally preserved in Dart.
    // Iterating through the map provided by ML Kit directly.
    landmarks.forEach((type, landmark) {
      double x = landmark.x;
      double y = landmark.y;
      double z = landmark.z;

      // Normalize if image size is provided
      if (imageSize != null && imageSize.width > 0 && imageSize.height > 0) {
        x = x / imageSize.width;
        y = y / imageSize.height;
      }

      landmarkList.add({
        'type': type.name,
        'x': x,
        'y': y,
        'z': z,
        'likelihood': landmark.likelihood,
      });
    });

    return jsonEncode(landmarkList);
  }
}
