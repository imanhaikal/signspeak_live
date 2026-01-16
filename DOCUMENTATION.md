# SignSpeak Live: MVP Prototype Documentation

## 1. Project Overview
SignSpeak Live is a high-fidelity mobile prototype designed to demonstrate the user experience of a real-time Sign Language Translation application. This MVP focuses on the visual interface, animations, and user flow for a "Deaf User" to "Hearing Staff" service counter scenario.

**Current Status:** High-Fidelity UI Prototype (Simulated Logic)

## 2. Architecture
The application follows a standard Flutter widget composition model, centered around a layered `Stack` layout to mimic an Augmented Reality (AR) experience.

**Widget Tree:**
`HomeScreen`
 └── `Scaffold` (Void Black Background)
      └── `Stack`
           ├── `CameraViewport` (Video Feed + AR Overlays)
           └── `InteractionArea` (Chat UI + Controls)

## 3. Module Details

### 3.1 Camera Viewport (`lib/widgets/camera_viewport.dart`)
This widget simulates the computer vision layer of the application.

*   **Video Feed**: Uses a placeholder network image (`Image.network`) to represent the camera stream.
*   **SkeletonPainter**:
    *   A custom `CustomPainter` that draws a static hand skeleton (landmarks and connections) to simulate MediaPipe hand tracking visualization.
    *   Draws joints (`drawCircle`) and connections (`drawLine`) using semi-transparent white paints.
*   **ScanLine Animation**:
    *   Uses an `AnimationController` (3s duration, repeating) and `AnimatedBuilder`.
    *   Moves a `FractionallySizedBox` vertically across the screen to simulate an active scanning process.
*   **Status Indicators**:
    *   **BIM (MY)**: Indicates the currently active sign language model.
    *   **GEMINI VISION ACTIVE**: A pulsating indicator (using `flutter_animate` effects: Fade & Scale) showing that the AI vision model is "processing" input.

### 3.2 Interaction Area (`lib/widgets/interaction_area.dart`)
This widget handles the communication interface between the user and the system.

*   **Glassmorphism**:
    *   The "User Message" bubble uses `BackdropFilter` with `ImageFilter.blur` and a semi-transparent white color (`AppColors.glassWhite`) to create a frosted glass effect over the underlying camera feed.
*   **Chat UI**:
    *   Displays a hardcoded conversation flow ("Live Session").
    *   **User Message**: "I need to renew my identification card..." (Simulated translation).
    *   **Staff Message**: "I can help with that..." (Simulated speech-to-text).
*   **Typing Indicator**:
    *   A row of three dots that animate sequentially (`.scale` with delay) to indicate system activity.
*   **Controls**:
    *   **Microphone**: A central button with an expanding "Pulse Ring" animation (`AnimationController`) to invite voice input.
    *   **Secondary Actions**: Keyboard input and Camera flip/refresh buttons.

## 4. Theming (`lib/theme/app_theme.dart`)
The app utilizes a specialized dark theme to enhance contrast and readability in various lighting conditions.

*   **Color Palette**:
    *   **Void Black** (`#000000`): Main background to blend with camera borders.
    *   **SignSpeak Green** (`#22C55E`): Primary accent color for success states and active indicators.
    *   **Glass White**: Semi-transparent white for overlays.
*   **Typography**:
    *   **Inter**: Used for all text elements to ensure clean, modern legibility.
    *   Styles defined in `AppTextStyles` (Body, Header, Caption).

## 5. Testing Strategy
The project employs Widget Testing to verify UI components and their initial states.

*   **Mocking Network Images**:
    *   Uses the `network_image_mock` package to prevent 404 errors during tests when rendering `Image.network` widgets in `CameraViewport`.
*   **Key Test Cases**:
    *   **`camera_viewport_test.dart`**: Verifies the presence of status badges ("GEMINI VISION ACTIVE") and header icons.
    *   **`interaction_area_test.dart`**: Confirms that specific chat messages are rendered and that control buttons (Mic, Keyboard) are present.

## 6. Future Improvements
To transition this prototype into a functional product, the following steps are required:

1.  **MediaPipe Integration**: Replace `SkeletonPainter` with real-time `google_mlkit_pose_detection` or `mediapipe` flutter plugin data.
2.  **Real-Time Backend**: Connect the `CameraService` to the Gemini API (multimodal) to send actual video frames for translation.
3.  **State Management**: Implement Riverpod or Bloc to handle actual chat messages and application state instead of hardcoded widgets.
4.  **Speech-to-Text**: Integrate the device's native Speech-to-Text API for the "Hearing Staff" input.
