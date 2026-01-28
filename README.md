# SignSpeak Live MVP Prototype

A Flutter recreation of a high-fidelity Sign Language Translation interface. This project is currently an **Active MVP Prototype**.

## Development Status

*   ✅ **Phase 1: Foundation** (Complete)
*   ✅ **Phase 5: UI/UX** (Complete)
*   ✅ **Phase 2: Vision Pipeline** (Complete)
*   🚀 **Phase 3: Gemini Integration** (Prototype Ready)

## Features

*   ✅ **Real-time Sign Language Recognition:** Leveraging ML Kit for pose detection to interpret sign language gestures. (**Integrated**)
*   ✅ **Text-to-Speech (TTS):** Converts translated text into audible speech for seamless communication. (**Ready**)
*   ✅ **Visual Debugging / Skeleton Overlay:** Real-time pose landmark visualization ("Cyber-Noir" style) overlaid on the camera feed. (**Complete**)
*   ✅ **Glassmorphic UI & Animations:** A modern, translucent UI design featuring animated typing indicators. (**Active**)
*   **Custom Camera Interface:** Specialized camera implementation for optimal frame capture and processing.
*   **Camera Controls:** Seamlessly switch between front and back cameras with the Flip Camera feature.
*   **Immersive Camera Viewport:** Includes a MediaPipe overlay simulation to demonstrate hand tracking capabilities.
*   **Real-time Scanning Animation:** Engaging visual feedback simulating active scanning processes.
*   **Responsive Layout:** Fluidly adapts to different screen sizes, optimized for mobile devices.

## Tech Stack

*   **Flutter**
*   **Key Packages:**
    *   `phosphor_flutter`
    *   `flutter_animate`
    *   `google_fonts`
    *   `google_mlkit_pose_detection`

## Project Structure

The project follows a feature-first and layered architecture:

*   `assets/`: For images, models, and fonts.
*   `lib/config/`: Configuration and constants.
*   `lib/models/`: Data models (e.g., `RecognitionResult`).
*   `lib/services/`: Business logic (Camera, ML, TTS).
*   `lib/utils/`: Helper utilities.
*   `lib/widgets/`: UI components organized by feature (`camera`, `interaction`, `common`).

## Setup Instructions

Ensure you have the Flutter SDK installed and set up.

1.  **Configure Environment Variables**
    *   Copy `.env.example` to a new file named `.env` in the project root:
        ```bash
        cp .env.example .env
        ```
    *   Open `.env` and add your Gemini API key:
        ```
        GEMINI_API_KEY=your_actual_api_key_here
        ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the Application**
    ```bash
    flutter run
    ```

## Testing

This project includes unit and widget tests. To run them:

```bash
flutter test
```

For specific test files:
```bash
flutter test test/services/camera_service_test.dart
flutter test test/widgets/camera/camera_viewport_test.dart
```

### Coverage
- **Camera Service**: Tests camera initialization, flipping, and error handling.
- **Camera Viewport**: Tests camera preview rendering and overlay integration.
- **Interaction Area**: Tests chat input, typing indicators, and message history.
- **ML Service**: Tests pose detection initialization, image processing flow, and resource management.
- **Image Utils**: Tests conversion of camera frames to ML Kit input format and rotation logic.
- **Landmark Utils**: Tests conversion of pose landmarks to normalized JSON format for Gemini integration.

## Screenshots

*(Screenshots of the application interface will be placed here)*
