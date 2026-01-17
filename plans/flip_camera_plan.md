# Plan: Implement Flip Camera Functionality

## Goal
Enable the user to switch between front and back cameras using the existing "Flip Camera" button in the UI.

## Architecture
1.  **CameraService (`lib/services/camera_service.dart`):**
    *   Manage the list of available cameras.
    *   Maintain the current `CameraController`.
    *   Provide methods to `initialize` and `switchCamera`.
    *   Expose the current controller for the UI to consume.

2.  **CameraViewport (`lib/widgets/camera/camera_viewport.dart`):**
    *   Replace the placeholder image with a live `CameraPreview`.
    *   Initialize the camera on startup.
    *   Provide a public method `flipCamera()` that calls `CameraService` and rebuilds the UI.

3.  **InteractionArea (`lib/widgets/interaction/interaction_area.dart`):**
    *   Accept a `VoidCallback? onFlipCamera` parameter.
    *   Trigger this callback when the existing "arrowsClockwise" button is pressed.

4.  **HomeScreen (`lib/screens/home_screen.dart`):**
    *   Use a `GlobalKey` to access the `CameraViewport` state.
    *   Pass a callback to `InteractionArea` that triggers the `flipCamera` method on the `CameraViewport`.

## Steps

### 1. Implement CameraService
*   **File:** `lib/services/camera_service.dart`
*   **Action:**
    *   Import `camera` package.
    *   Add `List<CameraDescription> _cameras`.
    *   Add `CameraController? _controller`.
    *   Implement `Future<void> initialize()`: Load cameras, select the first one, initialize controller.
    *   Implement `Future<void> switchCamera()`: Dispose current controller, switch index, initialize new controller.
    *   Getter for `controller`.

### 2. Update InteractionArea
*   **File:** `lib/widgets/interaction/interaction_area.dart`
*   **Action:**
    *   Add `final VoidCallback? onFlipCamera;` to the constructor.
    *   Update the `IconButton` for flip camera (line ~225) to call `widget.onFlipCamera?.call()`.

### 3. Update CameraViewport
*   **File:** `lib/widgets/camera/camera_viewport.dart`
*   **Action:**
    *   Change `_CameraViewportState` to `CameraViewportState` (public) so it can be accessed via GlobalKey.
    *   In `initState`, call `CameraService.initialize()` and `setState` when ready.
    *   In `build`, replacing `Image.network` with `CameraPreview(_cameraService.controller)`.
    *   Add `Future<void> flipCamera()` method: Calls `CameraService.switchCamera()` and `setState`.

### 4. Wire up HomeScreen
*   **File:** `lib/screens/home_screen.dart`
*   **Action:**
    *   Create `final GlobalKey<CameraViewportState> _cameraKey = GlobalKey();`.
    *   Assign this key to `CameraViewport`.
    *   Pass `onFlipCamera: () => _cameraKey.currentState?.flipCamera()` to `InteractionArea`.

## Verification
*   Verify app builds.
*   Verify camera permission prompt appears (if not already granted).
*   Verify camera preview starts.
*   Verify clicking the flip button switches the camera.
