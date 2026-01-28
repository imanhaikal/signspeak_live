# SignSpeak Live: MVP Documentation

## 1. Project Overview
SignSpeak Live is a real-time Sign Language Translation application designed to bridge communication gaps between Deaf and hearing individuals. The application leverages on-device Machine Learning to interpret sign language gestures and converts them into spoken text, while simultaneously transcribing spoken words into text for the Deaf user.

**Current Status:** Phase 3: Gemini Integration (Prototype Ready)

## 2. Directory Structure
The project adopts a feature-first and layered architecture to ensure scalability and maintainability:

*   `lib/`
    *   `config/`: App-wide constants and configuration.
    *   `models/`: Data models (e.g., `RecognitionResult`) for structured data passing.
    *   `screens/`: High-level screen containers (e.g., `HomeScreen`).
    *   `services/`: Core business logic and external integrations (`CameraService`, `MLService`, `TtsService`).
    *   `theme/`: Application design system and styling.
    *   `utils/`: Helper functions (e.g., `image_utils.dart`, `landmark_utils.dart`).
    *   `widgets/`: Reusable UI components organized by domain (`camera`, `interaction`, `common`).

## 3. Architecture
The application is built on a clear separation of concerns, dividing responsibilities between the User Interface, Business Logic, and Data Models.

### 3.1 Logical Layer (Services)
The core functionality is encapsulated within dedicated service classes:
*   **`CameraService`**: Manages the `CameraController` lifecycle. Responsibilities include:
    *   **Initialization**: Requesting permissions and setting up the initial camera.
    *   **Controller Management**: Creating and disposing of the `CameraController`.
    *   **Switching**: Handling the logic to toggle between front and back cameras.
*   **`MLService`**: Manages the integration with Google ML Kit's Pose Detection. It handles:
    *   **Initialization**: Setting up the `PoseDetector` in stream mode.
    *   **Inference**: Processing video frames to detect and extract human pose landmarks (x, y, z coordinates).
    *   **Data Formatting**: utilizing `LandmarkUtils` to normalize and serialize landmarks for API consumption.
    *   **Resource Management**: Properly disposing of the detector to prevent memory leaks.
*   **`TtsService`**: Handles Text-to-Speech synthesis, converting translated sign language text into audible speech.

### 3.2 Data Layer (Models)
*   **`RecognitionResult`**: A standardized model representing the output of the ML detection, containing the label, confidence score, and bounding box coordinates (`rect`).

### 3.3 UI Layer (Widgets)
The visual interface follows a composition model using a layered `Stack` layout to support Augmented Reality (AR) features.

**Widget Tree:**
`HomeScreen`
 └── `Scaffold` (Void Black Background)
      └── `Stack`
           ├── `CameraViewport` (Camera Feed + Skeleton Overlay/Visual Debugging)
           └── `InteractionArea` (Chat UI + Controls)

### 3.4 State Management
The application uses a hybrid approach for state management suited for the MVP:
*   **GlobalKey Pattern**: The `HomeScreen` uses a `GlobalKey<CameraViewportState>` to directly invoke the `flipCamera()` method on the `CameraViewport` when the flip button in `InteractionArea` is pressed. This avoids complex state management boilerplate for this specific hardware interaction.
*   **ValueNotifiers**: Used for high-frequency updates like the "Live Translation" text to avoid full widget tree rebuilds.

### 3.5 Performance & Optimization
*   **ML Inference Throttling**: `CameraViewport` limits frame processing to ~10 FPS to reduce CPU load and prevent UI jank.
*   **API Rate Limiting**: `HomeScreen` implements a strict 2-second debounce/throttle mechanism for `GeminiService` calls to manage API costs and latency.

## 4. Module Details

### 4.1 Camera Viewport (`lib/widgets/camera/`)
Handles the rendering of the live camera feed and AR overlays.
*   **`CameraViewport`**:
    *   **Live Preview**: Initializes the `CameraService` and renders the standard `CameraPreview` widget.
    *   **Flip Logic**: Contains the `flipCamera()` method which triggers the service to switch cameras and updates the UI state.
*   **`PosePainter`**: Visualizes detection results (e.g., skeletal landmarks and connections) over the camera feed using a custom painter. Replaces the placeholder `BoundingBoxOverlay`.
*   **Status Indicators**: Visual cues for active ML processing (e.g., "GEMINI VISION ACTIVE" or model status).

### 4.2 Interaction Area (`lib/widgets/interaction/`)
Handles the communication interface between the user and the system.
*   **`InteractionArea`**: The main container for the chat and controls.
*   **Glassmorphism**: Uses `BackdropFilter` and semi-transparent colors to create a modern, unobtrusive overlay.
*   **Live Translation Display**: Shows real-time interpretation results above the chat history.
*   **Chat UI**: Displays the bi-directional conversation (transcribed speech and translated signs).
*   **Controls**: Microphone input, keyboard toggle, and **Camera Flip**. The flip action is delegated to the parent widget via a callback function, maintaining loose coupling.

### 4.3 Utilities (`lib/utils/`)
Helper classes to streamline complex operations and ensure data consistency.
*   **`LandmarkUtils`**:
    *   **Normalization**: Converts absolute pixel coordinates (x, y) into relative coordinates (0.0 - 1.0) based on the input image resolution. This ensures the model receives resolution-independent data.
    *   **Serialization**: Transforms the `PoseLandmark` map into a standardized JSON string structure containing `type`, `x`, `y`, `z`, and `likelihood` for efficient API transmission.
*   **`ImageUtils`**:
    *   **Format Conversion**: Converts platform-specific `CameraImage` formats (YUV_420_888 on Android, BGRA8888 on iOS) into ML Kit's `InputImage` format.
    *   **Rotation Handling**: Maps device sensor orientation to ML Kit's `InputImageRotation`.

## 5. Theming (`lib/theme/app_theme.dart`)
The app utilizes a specialized dark theme to enhance contrast and readability in various lighting conditions.

*   **Color Palette**:
    *   **Void Black** (`#000000`): Main background to blend with camera borders.
    *   **SignSpeak Green** (`#22C55E`): Primary accent color for success states and active indicators.
    *   **Glass White**: Semi-transparent white for overlays.
*   **Typography**:
    *   **Inter**: Used for all text elements to ensure clean, modern legibility.

## 6. Testing Strategy
We employ a comprehensive testing strategy to ensure reliability:
*   **`CameraServiceTest`**: Unit tests for camera initialization, permission handling, and camera switching logic.
*   **`CameraViewportTest`**: Widget tests verifying that the camera preview initializes and the flip method invokes the correct service calls.
*   **`InteractionAreaTest`**: Widget tests ensuring the flip button and other controls trigger their respective callbacks.
*   **`HomeScreenTest`**: Integration tests validating that the `InteractionArea` correctly triggers the `CameraViewport` flip action via the `GlobalKey`.
*   **`PosePainterTest`**: Widget tests validating the custom painting logic, ensuring skeletal landmarks are drawn correctly based on input poses.
*   **`ImageUtilsTest`**: Unit tests verifying the accurate conversion of Flutter `CameraImage` formats to ML Kit `InputImage` formats, including rotation mapping and format handling.
*   **`LandmarkUtilsTest`**: Unit tests verifying the correct normalization and JSON serialization of pose landmarks, ensuring data integrity for API requests.
*   **`LatencyManagementTest`**: Integration tests verifying the API throttling logic and live UI updates.

## 7. Future Improvements
To transition this MVP into a fully functional product, the following steps are prioritized:

1.  **Gemini Integration**: Connect the `MLService` output (landmarks) to the Gemini API for sign interpretation.
2.  **Service Implementation**: Complete the implementation of `MLService` (Pose Detection) and `TtsService`.
3.  **State Management**: Implement a reactive state management solution (e.g., Riverpod or Bloc) to connect the Services with the UI.
4.  **Real-Time Backend**: Connect the `CameraService` to external APIs (like Gemini Multimodal) if cloud-based inference is required.

