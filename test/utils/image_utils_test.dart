import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signspeak_live/utils/image_utils.dart';

class MockCameraImage extends Mock implements CameraImage {}

class MockPlane extends Mock implements Plane {}

class MockImageFormat extends Mock implements ImageFormat {}

void main() {
  group('ImageUtils', () {
    late MockCameraImage mockCameraImage;
    late MockPlane mockPlane;
    late MockImageFormat mockImageFormat;

    // CameraDescription is a simple data class, we can instantiate it directly.
    // If it were abstract or hard to construct, we'd mock it.
    const cameraDescription = CameraDescription(
      name: '0',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    );

    setUp(() {
      mockCameraImage = MockCameraImage();
      mockPlane = MockPlane();
      mockImageFormat = MockImageFormat();

      // Setup default mock behaviors
      when(() => mockCameraImage.planes).thenReturn([mockPlane]);
      when(() => mockCameraImage.width).thenReturn(640);
      when(() => mockCameraImage.height).thenReturn(480);
      when(() => mockCameraImage.format).thenReturn(mockImageFormat);

      when(
        () => mockPlane.bytes,
      ).thenReturn(Uint8List.fromList(List.filled(100, 0)));
      when(() => mockPlane.bytesPerRow).thenReturn(640);

      // raw value for nv21 is 17 (Android) or yuv420 is 35 (iOS).
      // InputImageFormatValue.fromRawValue handles platform specifics.
      // Let's assume Android NV21 for this test as it maps to nv21.
      // Google ML Kit's InputImageFormatValue.fromRawValue checks against int values.
      // NV21 = 17, YV12 = 842094169, YUV_420_888 = 35.
      // Bgra8888 = 1111970369 on iOS?
      // Let's try to match one that works.
      when(() => mockImageFormat.raw).thenReturn(17); // NV21
    });

    test(
      'convertCameraImageToInputImage returns correct InputImage for valid inputs',
      () {
        final inputImage = ImageUtils.convertCameraImageToInputImage(
          mockCameraImage,
          cameraDescription,
        );

        expect(inputImage, isNotNull);
        expect(inputImage!.metadata!.size, equals(const Size(640, 480)));
        expect(
          inputImage.metadata!.rotation,
          equals(InputImageRotation.rotation90deg),
        );
        expect(inputImage.metadata!.format, equals(InputImageFormat.nv21));
        expect(inputImage.metadata!.bytesPerRow, equals(640));
      },
    );

    test(
      'convertCameraImageToInputImage returns null for invalid rotation',
      () {
        const invalidCamera = CameraDescription(
          name: '1',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 45, // Invalid orientation
        );

        final inputImage = ImageUtils.convertCameraImageToInputImage(
          mockCameraImage,
          invalidCamera,
        );

        expect(inputImage, isNull);
      },
    );

    test(
      'convertCameraImageToInputImage returns null for unsupported format',
      () {
        when(() => mockImageFormat.raw).thenReturn(-1); // Unsupported format

        final inputImage = ImageUtils.convertCameraImageToInputImage(
          mockCameraImage,
          cameraDescription,
        );

        expect(inputImage, isNull);
      },
    );

    test('_rotationIntToImageRotation mapping test via public API', () {
      // We test the private mapping by passing different sensor orientations to the public method

      // 0 degrees
      var camera = const CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      );
      var result = ImageUtils.convertCameraImageToInputImage(
        mockCameraImage,
        camera,
      );
      expect(result?.metadata?.rotation, InputImageRotation.rotation0deg);

      // 90 degrees
      camera = const CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );
      result = ImageUtils.convertCameraImageToInputImage(
        mockCameraImage,
        camera,
      );
      expect(result?.metadata?.rotation, InputImageRotation.rotation90deg);

      // 180 degrees
      camera = const CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 180,
      );
      result = ImageUtils.convertCameraImageToInputImage(
        mockCameraImage,
        camera,
      );
      expect(result?.metadata?.rotation, InputImageRotation.rotation180deg);

      // 270 degrees
      camera = const CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 270,
      );
      result = ImageUtils.convertCameraImageToInputImage(
        mockCameraImage,
        camera,
      );
      expect(result?.metadata?.rotation, InputImageRotation.rotation270deg);
    });
  });
}
