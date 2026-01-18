import 'dart:io';
import 'dart:ui';
// import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ImageUtils {
  static InputImage? convertCameraImageToInputImage(
    CameraImage cameraImage,
    CameraDescription camera,
  ) {
    final allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    final InputImageRotation? imageRotation = _rotationIntToImageRotation(
      camera.sensorOrientation,
    );

    if (imageRotation == null) return null;

    final rawFormat = cameraImage.format.raw;
    // ignore: avoid_print
    print('Camera format raw: $rawFormat');

    InputImageFormat? inputImageFormat = InputImageFormatValue.fromRawValue(
      rawFormat as int,
    );

    // Force map YUV_420_888 (35) to NV21 on Android, as ML Kit might prefer NV21
    // or to ensure consistency with the requirement.
    if (isAndroid && rawFormat == 35) {
      inputImageFormat = InputImageFormat.nv21;
    }

    if (inputImageFormat == null) {
      if (isAndroid) {
        // YUV_420_888 = 35
        if (rawFormat == 35) {
          inputImageFormat = InputImageFormat.nv21;
        } else if (rawFormat == 17) {
          // NV21 = 17
          inputImageFormat = InputImageFormat.nv21;
        }
      } else if (isIOS) {
        // BGRA8888 = 1111970369
        if (rawFormat == 1111970369) {
          inputImageFormat = InputImageFormat.bgra8888;
        }
      }
    }

    if (inputImageFormat == null) return null;

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: cameraImage.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
  }

  @visibleForTesting
  static bool? isAndroidOverride;

  static bool get isAndroid => isAndroidOverride ?? Platform.isAndroid;

  @visibleForTesting
  static bool? isIOSOverride;

  static bool get isIOS => isIOSOverride ?? Platform.isIOS;

  static InputImageRotation? _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return null;
    }
  }
}
