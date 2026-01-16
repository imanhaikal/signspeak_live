# SignSpeak Live: MVP Documentation

## 1. Project Overview
SignSpeak Live is a real-time Sign Language Translation application designed to bridge communication gaps between Deaf and hearing individuals. The application leverages on-device Machine Learning to interpret sign language gestures and converts them into spoken text, while simultaneously transcribing spoken words into text for the Deaf user.

**Current Status:** Functional MVP Architecture (UI + Service Logic Stubs)

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
*   **`CameraService`**: Responsible for initializing the camera, handling permissions, and managing the video stream.
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
           ├── `CameraViewport` (Camera Feed + AR/Bounding Box Overlays)
           └── `InteractionArea` (Chat UI + Controls)

## 4. Module Details

### 4.1 Camera Viewport (`lib/widgets/camera/`)
Simulates or renders the computer vision layer.
*   **`CameraViewport`**: Main container for the camera feed.
*   **`BoundingBoxOverlay`**: Visualizes detection results (e.g., hand tracking landmarks or bounding boxes) over the camera feed.
*   **Status Indicators**: Visual cues for active ML processing (e.g., "GEMINI VISION ACTIVE" or model status).

### 4.2 Interaction Area (`lib/widgets/interaction/`)
Handles the communication interface between the user and the system.
*   **Glassmorphism**: Uses `BackdropFilter` and semi-transparent colors to create a modern, unobtrusive overlay.
*   **Chat UI**: Displays the bi-directional conversation (transcribed speech and translated signs).
*   **Controls**: Microphone input with pulse animations, keyboard toggle, and camera controls.

## 5. Theming (`lib/theme/app_theme.dart`)
The app utilizes a specialized dark theme to enhance contrast and readability in various lighting conditions.

*   **Color Palette**:
    *   **Void Black** (`#000000`): Main background to blend with camera borders.
    *   **SignSpeak Green** (`#22C55E`): Primary accent color for success states and active indicators.
    *   **Glass White**: Semi-transparent white for overlays.
*   **Typography**:
    *   **Inter**: Used for all text elements to ensure clean, modern legibility.

## 6. Future Improvements
To transition this MVP into a fully functional product, the following steps are prioritized:

1.  **Service Implementation**: Flesh out the `TODO` stubs in `CameraService`, `MLService`, and `TtsService` with actual logic (CameraX, TFLite/Mediapipe, Flutter TTS).
2.  **MediaPipe/ML Kit Integration**: Fully integrate `google_mlkit_pose_detection` or equivalent for real-time skeletal tracking.
3.  **State Management**: Implement a reactive state management solution (e.g., Riverpod or Bloc) to connect the Services with the UI.
4.  **Real-Time Backend**: Connect the `CameraService` to external APIs (like Gemini Multimodal) if cloud-based inference is required.
