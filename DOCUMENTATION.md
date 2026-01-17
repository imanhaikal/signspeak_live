# SignSpeak Live: MVP Documentation

## 1. Project Overview
SignSpeak Live is a real-time Sign Language Translation application designed to bridge communication gaps between Deaf and hearing individuals. The application leverages on-device Machine Learning to interpret sign language gestures and converts them into spoken text, while simultaneously transcribing spoken words into text for the Deaf user.

**Current Status:** Phase 2: Vision Pipeline (Active Development)

## 2. Directory Structure
The project adopts a feature-first and layered architecture to ensure scalability and maintainability:

*   `lib/`
    *   `config/`: App-wide constants and configuration.
    *   `models/`: Data models (e.g., `RecognitionResult`) for structured data passing.
    *   `screens/`: High-level screen containers (e.g., `HomeScreen`).
    *   `services/`: Core business logic and external integrations (`CameraService`, `MLService`, `TtsService`).
    *   `theme/`: Application design system and styling.
    *   `utils/`: Helper functions (e.g., `image_utils.dart`).
    *   `widgets/`: Reusable UI components organized by domain (`camera`, `interaction`, `common`).

## 3. Architecture
The application is built on a clear separation of concerns, dividing responsibilities between the User Interface, Business Logic, and Data Models.

### 3.1 Logical Layer (Services)
The core functionality is encapsulated within dedicated service classes:
*   **`CameraService`**: Manages the `CameraController` lifecycle. Responsibilities include:
    *   **Initialization**: Requesting permissions and setting up the initial camera.
    *   **Controller Management**: Creating and disposing of the `CameraController`.
    *   **Switching**: Handling the logic to toggle between front and back cameras.
*   **`MLService`**: Manages the loading of Machine Learning models (e.g., TFLite) and performing inference on video frames to detect signs.
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

## 4. Module Details

### 4.1 Camera Viewport (`lib/widgets/camera/`)
Handles the rendering of the live camera feed and AR overlays.
*   **`CameraViewport`**:
    *   **Live Preview**: Initializes the `CameraService` and renders the standard `CameraPreview` widget.
    *   **Flip Logic**: Contains the `flipCamera()` method which triggers the service to switch cameras and updates the UI state.
*   **`BoundingBoxOverlay`**: Visualizes detection results (e.g., hand tracking landmarks or bounding boxes) over the camera feed.
*   **Status Indicators**: Visual cues for active ML processing (e.g., "GEMINI VISION ACTIVE" or model status).

### 4.2 Interaction Area (`lib/widgets/interaction/`)
Handles the communication interface between the user and the system.
*   **`InteractionArea`**: The main container for the chat and controls.
*   **Glassmorphism**: Uses `BackdropFilter` and semi-transparent colors to create a modern, unobtrusive overlay.
*   **Chat UI**: Displays the bi-directional conversation (transcribed speech and translated signs).
*   **Controls**: Microphone input, keyboard toggle, and **Camera Flip**. The flip action is delegated to the parent widget via a callback function, maintaining loose coupling.

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

## 7. Future Improvements
To transition this MVP into a fully functional product, the following steps are prioritized:

1.  **Gemini Integration**: Connect the `MLService` output (landmarks) to the Gemini API for sign interpretation.
2.  **Service Implementation**: Complete the implementation of `MLService` (Pose Detection) and `TtsService`.
3.  **State Management**: Implement a reactive state management solution (e.g., Riverpod or Bloc) to connect the Services with the UI.
4.  **Real-Time Backend**: Connect the `CameraService` to external APIs (like Gemini Multimodal) if cloud-based inference is required.

